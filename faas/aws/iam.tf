###
### API Gateway 
###

data "aws_iam_policy_document" "api_gateway_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "api-gateway-cloudwatch-global"

  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
}

data "aws_iam_policy_document" "api_gateway_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch" {
  name = "api-gateway-cloudwatch"
  role = aws_iam_role.api_gateway_cloudwatch.id

  policy = data.aws_iam_policy_document.api_gateway_cloudwatch.json
}

###
### Lambda
###

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_event_lambda" {
  name = local.api_event_lambda_name

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "api_event_lambda" {

  statement {
    actions = [
      "cloudwatch:ListTagsForResource",
      "events:PutEvents"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.api_event_lambda.arn}:*"]
  }

}

resource "aws_iam_policy" "api_event_lambda" {
  name        = local.api_event_lambda_name
  path        = "/"
  description = "Policy for API Lambda"
  policy      = data.aws_iam_policy_document.api_event_lambda.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "api_event_lambda" {
  policy_arn = aws_iam_policy.api_event_lambda.arn
  role       = aws_iam_role.api_event_lambda.name
}


###
### Lambda Event
###

data "aws_iam_policy_document" "lambda_event_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "event_lambda" {
  name = local.event_lambda_name

  assume_role_policy = data.aws_iam_policy_document.lambda_event_assume_role.json

  tags = local.common_tags
}


data "aws_iam_policy_document" "event_lambda" {

  statement {
    actions = [
      "cloudwatch:ListTagsForResource",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:*Object"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["${aws_cloudwatch_log_group.event_lambda.arn}:*"]
  }

}

resource "aws_iam_policy" "event_lambda" {
  name        = local.event_lambda_name
  path        = "/"
  description = "Policy for Event Lambda"
  policy      = data.aws_iam_policy_document.event_lambda.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "event_lambda" {
  policy_arn = aws_iam_policy.event_lambda.arn
  role       = aws_iam_role.event_lambda.name
}



###
# Queue
###

# resource "aws_sqs_queue_policy" "queue" {
#   queue_url = aws_sqs_queue.queue.id
#   policy    = data.aws_iam_policy_document.queue.json
# }

# data "aws_iam_policy_document" "queue" {
#   statement {
#     sid     = "events-policy"
#     actions = ["sqs:SendMessage"]

#     principals {
#       type        = "Service"
#       identifiers = ["events.amazonaws.com"]
#     }

#     resources = [
#       aws_sqs_queue.queue.arn
#     ]
#   }
# }


