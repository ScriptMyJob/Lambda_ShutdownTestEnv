########################################
### Variables ##########################
########################################

variable "global" {
    type    = "map"
    default = {
        region  = "us-west-2"
        tags    = "Development"
    }
}

variable "lambda" {
    type    = "map"
    default = {
        name    = "lambda_shutdown_ec2"
    }
}

########################################
### Data ###############################
########################################

data "aws_iam_account_alias" "current" {}
