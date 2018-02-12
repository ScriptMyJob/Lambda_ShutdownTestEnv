########################################
### SNS Configurations #################
########################################

resource "aws_sns_topic" "shutdown" {
    name = "${lookup(var.lambda,"name")}"
}
