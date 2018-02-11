########################################
### Lambda Configs: ####################
########################################

# lambda_shutdown_ec2
####################

data "archive_file" "zip_shutdown_ec2" {
    type            = "zip"

    source_file     = "${path.module}/../Resources/shutdown_ec2.py"
    output_path     = "${path.module}/../Resources/shutdown_ec2.zip"
}

resource "aws_lambda_function" "shutdown_ec2" {

    depends_on      = [
        "data.archive_file.zip_shutdown_ec2"
    ]

    filename        = "${path.module}/../Resources/shutdown_ec2.zip"
    function_name   = "${lookup(var.lambda,"name")}"
    role            = "${aws_iam_role.lambda_shutdown_ec2.arn}"
    handler         = "shutdown_ec2.execute_me_lambda"
    runtime         = "python2.7"
    memory_size     = 128
    timeout         = 5
    environment {
        variables = {
            region      = "us-west-2"
            environment = "Development"
        }
    }
}
