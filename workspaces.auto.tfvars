vars_mapped_by_workspace_name = {
  customer_aws_workspace = {
   
    # Specify workspace specific variables here. 
    #These vairables will be configured for the workspace that is manged by tfe provider
    # Variables that are configured at Organization level as Variable set, will be automatically inherited to workspace
    # user need not crate them here. 
    # use these sections to create workspace specifc variables. 
    # variables specified here will override org specific variables.
    
    # Sample variables
    /*
    AWS_ACCESS_KEY_ID = {
      value = "< AWS ACCESS KEY WORKSPACE SPECIFIC>"
      sensitive = true # (default = false) set to true if the variable is secret vaule 
    }
    AWS_SECRET_ACCESS_KEY = {
      value = "<AWS SECRET KEY>"
      sensitive = true
    }
    VARIABLE_ = {value = "value1"}
    */
    VCS_REPO_ID = {value = "veereshsy05/mvc-demos"}
    #WORKING_DIR = {value = "aws/ec2"}
  }
}
