###
### Event lambda is used to process API events
###

resource "aws_cloudwatch_log_group" "api_event_lambda" {
  name              = "/aws/lambda/${local.api_event_lambda_name}"
  retention_in_days = var.log_retention_period

  tags = local.common_tags
}


resource "aws_cloudwatch_log_group" "event_lambda" {
  name              = "/aws/lambda/${local.event_lambda_name}"
  retention_in_days = var.log_retention_period

  tags = local.common_tags
}


resource "aws_cloudwatch_log_group" "db_lambda" {
  name              = "/aws/lambda/${local.db_lambda_name}"
  retention_in_days = var.log_retention_period

  tags = local.common_tags
}



# Lambda doesn't have `request` package by default. We need to install this package locally and add it to zip file.
resource "null_resource" "install_package" {
  triggers = {
    file_changed = filebase64sha256("./code/api.py")
  }

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = "pip3 install boto3 aws-psycopg2 -t ./code/"
  }
}

data "archive_file" "api_event_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/code/"
  output_path = "${path.module}/code/api.zip"

  depends_on = [null_resource.install_package]
}

resource "aws_lambda_function" "api_event_lambda" {
  filename      = data.archive_file.api_event_lambda.output_path
  function_name = local.api_event_lambda_name
  role          = aws_iam_role.api_event_lambda.arn
  handler       = "api.api_lambda_handler"

  source_code_hash = data.archive_file.api_event_lambda.output_base64sha256

  runtime = "python3.9"

  timeout = 10

  environment {
    variables = {
      EVENT_BUS = local.bus_name
    }
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.api_event_lambda,
    aws_cloudwatch_log_group.api_event_lambda
  ]
}

resource "aws_lambda_permission" "api_event" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_event_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway HTTP API.
  source_arn = "${aws_apigatewayv2_api.api_event.execution_arn}/*/*/*"
}


###### S3 Lambda


resource "aws_lambda_function" "event_lambda" {
  filename      = data.archive_file.api_event_lambda.output_path
  function_name = local.event_lambda_name
  role          = aws_iam_role.event_lambda.arn
  handler       = "api.event_lambda_handler"

  source_code_hash = data.archive_file.api_event_lambda.output_base64sha256

  runtime = "python3.9"

  timeout = 10

  environment {
   variables = {
    BUCKET_NAME = local.bucket_name
   }
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.event_lambda,
    aws_cloudwatch_log_group.event_lambda
  ]
}


resource "aws_lambda_permission" "allow_eventbridge_to_call_lambda" {
    statement_id = "AllowExecutionFromEventBridge"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.event_lambda.function_name}"
    principal = "events.amazonaws.com"
    # source_arn = "${module.eventbridge.aws_cloudwatch_event_rule.this["events"].arn}"
    source_arn = "${module.eventbridge.eventbridge_rule_arns["events"]}"
}




###### DB Lambda


resource "aws_lambda_function" "db_lambda" {
  filename      = data.archive_file.api_event_lambda.output_path
  function_name = local.db_lambda_name
  role          = aws_iam_role.db_lambda.arn
  handler       = "api.db_lambda_handler"

  source_code_hash = data.archive_file.api_event_lambda.output_base64sha256

  runtime = "python3.9"

  timeout = 10

  environment {
   variables = {
    DB_INSTANCE_ADDRESS = module.db.db_instance_address #aws_db_instance.bl-db.address
   }
  }

  tags = local.common_tags
}


resource "aws_lambda_permission" "allow_eventbridge_to_call_db_lambda" {
    statement_id = "AllowExecutionFromEventBridge"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.db_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${module.eventbridge.eventbridge_rule_arns["events"]}"
}




