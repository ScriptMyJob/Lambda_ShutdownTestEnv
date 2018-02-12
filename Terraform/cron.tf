resource "aws_cloudwatch_event_rule" "cron_12AM_Everyday" {
    name                = "12AM_Everyday"
    description         = "Run at 12 AM CST Everyday"

    schedule_expression = "cron(00 5 * * ? *)"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id        = "AllowExecutionFromCloudWatch"
    action              = "lambda:InvokeFunction"
    function_name       = "${aws_lambda_function.shutdown_ec2.arn}"
    principal           = "events.amazonaws.com"
    source_arn          = "${aws_cloudwatch_event_rule.cron_12AM_Everyday.arn}"
}

resource "aws_cloudwatch_event_target" "shutdown_ec2" {
    rule                = "${aws_cloudwatch_event_rule.cron_12AM_Everyday.name}"
    target_id           = "${lookup(var.lambda,"name")}"
    arn                 = "${aws_lambda_function.shutdown_ec2.arn}"
}
