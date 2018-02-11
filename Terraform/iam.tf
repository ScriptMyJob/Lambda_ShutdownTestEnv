########################################
### IAM Policies #######################
########################################

resource "aws_iam_policy" "lambda_shutdown_ec2" {
    name    = "lambda_shutdown_ec2"
    path    = "/"
    policy  = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:StopInstances",
                "autoscaling:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:UpdateAutoScalingGroup"
            ],
            "Resource": "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

########################################
### IAM Roles ##########################
########################################

resource "aws_iam_role" "lambda_shutdown_ec2" {
  name = "lambda_shutdown_ec2"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
POLICY
}

########################################
### IAM Policy Attachments #############
########################################

resource "aws_iam_policy_attachment" "expiry_attach" {
    name            = "expiry_attach"
    roles           = [
        "${aws_iam_role.lambda_shutdown_ec2.name}"
    ]
    policy_arn      = "${aws_iam_policy.lambda_shutdown_ec2.arn}"
}
