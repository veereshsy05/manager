
# This configuration creates and manages workspaces in Terraform Cloud /
# Enterprise. Workspace variables and resources are configured in seperate git repository (managed)

variable "tf_organization" {
  description = "The Terraform Cloud or Enterprise organization under which all operations should be performed."
  type = string
}
/*
variable "vcs_repo_identifier" {
  type = string
}
*/
variable "org_user_email" {
  type = string
}

variable "org_var_set" {
  type = string
}


variable "vcs_token_id" {
  description = "The VCS token should correspond to an API token that can create OAuth clients."
  type = string
  default = ""
}

variable "vars_mapped_by_workspace_name" {
    description = <<-EOT
    This is the map of workspaces and variables. A workspace is created for each
    top level key and then variables are set on the workspace.
    EOT
    type = any
}
variable "default_var_sensitive" {
  description = "By default, variables being set in managed workspaces will be non-sensitive"
  default = false
  type = bool
}

data "tfe_organization_membership" "org" {
 organization = var.tf_organization
 email =        var.org_user_email
}
data "tfe_variable_set" "var_set" {
  name         = var.org_var_set
  organization = data.tfe_organization_membership.org.organization
}

data "tfe_variables" "variable_list" {
  variable_set_id = data.tfe_variable_set.var_set.id
}

data "tfe_oauth_client" "gh" {
  #organization     = data.tfe_organization_membership.org.organization
  #service_provider = "github"
  oauth_client_id =  var.vcs_token_id # != "" ? var.vcs_token_id : data.tfe_variables.variable_list.variables[index(data.tfe_variables.variable_list.variables.*.name,"VCS_TOKEN_ID")].value 
}


/*
output "ws_variables" {
    value = var.vars_mapped_by_workspace_name
}
*/


locals {
  #   [{
  #     ws            = ws_name
  #     var_key       = name
  #     var_value     = value
  #     var_category  = string
  #     var_hcl       = true/false
  #     var_sensitive = true/false
  #     ws_id         = <tfe_workspace>.id
  #   }...]
  ws_variables = flatten([
    for ws_name, variables in var.vars_mapped_by_workspace_name : [
      for var_name, var_attrs in (variables) : {
        ws            = ws_name
        var_key       = var_name
        var_value     = var_attrs["value"]
        var_category  = "terraform" #lookup(var_attrs, "category",  var.default_var_category)
        var_hcl       = true #lookup(var_attrs, "hcl",       var.default_var_hcl)
        var_sensitive = lookup(var_attrs, "sensitive", var.default_var_sensitive)
        ws_id         = tfe_workspace.managed_ws[ws_name].id
      }
    ]
  ])
  
}

output "var_list" {
  value = data.tfe_variables.variable_list
  #value = locals.ws_params
}
/*
output "vcs_token_id" {
  value = var.vcs_token_id  != ""  ? var.vcs_token_id : data.tfe_variables.variable_list.variables[index(data.tfe_variables.variable_list.variables.*.name,"VCS_TOKEN_ID")].value 
}
*/


# Workspaces to be created in Terraform Cloud
resource "tfe_workspace" "managed_ws" {
  description = "Create all workspaces specified in the input workspaces map"
  for_each = var.vars_mapped_by_workspace_name


  name = each.key
  organization = data.tfe_organization_membership.org.organization
  auto_apply = true
  force_delete = false
  #assessments_enabled = true
  working_directory = lookup(var.vars_mapped_by_workspace_name[each.key],"WORKING_DIR",null) == null ? null : lookup(var.vars_mapped_by_workspace_name[each.key],"WORKING_DIR",null).value
  vcs_repo {
    #identifier = var.vcs_repo_identifier
    identifier = lookup(var.vars_mapped_by_workspace_name[each.key],"VCS_REPO_ID", "" ).value 
    oauth_token_id = data.tfe_oauth_client.gh.oauth_token_id #lookup(var.vars_mapped_by_workspace_name[each.key], "VCS_ID_TOKEN") #.value ,"VCS_ID_TOKEN","default").value #lookup(data.tfe_variables.variable_list[VCS_TOKEN].   tfe_workspace.managed_ws[ws_name].id
  }
}

    # Variables to be created for individual workspace
# part of each workspace configuration in tfvar file

resource "tfe_variable" "managed_var" {


  for_each = {
    for v in local.ws_variables : "${v.ws}.${v.var_key}" => v
  }

  workspace_id = each.value.ws_id
  key          = each.value.var_key
  value        = each.value.var_value
  category     = each.value.var_category
  hcl          = each.value.var_hcl
  sensitive    = each.value.var_sensitive
}

