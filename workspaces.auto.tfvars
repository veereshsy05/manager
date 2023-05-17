vars_mapped_by_workspace_name = {
  customer_workspace_aws = {
   
    # Specify workspace specific variables here.Use these sections to create workspace specifc variables. 
    # Variables that are configured at Organization level as Variable set, will be automatically inherited to workspace
    # variables specified here will override org specific variables.
    
    /* AWS Cloud spedific variables. 
    AWS_ACCESS_KEY_ID = {
      value = "< AWS ACCESS KEY WORKSPACE SPECIFIC>"
      sensitive = true # (default = false) set to true if the variable is secret vaule 
    }
    AWS_SECRET_ACCESS_KEY = {
      value = "<AWS SECRET KEY>"
      sensitive = true
    } */
    VCS_REPO_ID = {value = "hpe-aps-hybrid-cloud/tfe-demo-aws"}
    #WORKING_DIR = {value = "working directory"} (optional)
  }

}

