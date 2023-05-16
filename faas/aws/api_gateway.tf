resource "aws_api_gateway_account" "global" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

resource "aws_cloudwatch_log_group" "api_event_api_gateway" {
  name              = "/aws/apigateway/${local.api_event_lambda_name}"
  retention_in_days = var.log_retention_period

  tags = local.common_tags
}

resource "aws_apigatewayv2_api" "api_event" {
  name          = local.api_event_lambda_name
  description   = "This API is used to proccess events in FaaS project"
  protocol_type = "HTTP"

  tags = local.common_tags
}

resource "aws_apigatewayv2_integration" "api_event" {
  api_id           = aws_apigatewayv2_api.api_event.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.api_event_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "api_event" {
  api_id    = aws_apigatewayv2_api.api_event.id
  route_key = "POST /api"

  target = "integrations/${aws_apigatewayv2_integration.api_event.id}"
}

resource "aws_apigatewayv2_stage" "api_event" {
  api_id      = aws_apigatewayv2_api.api_event.id
  name        = "v1"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_event_api_gateway.arn
    format = jsonencode(
      {
        httpMethod     = "$context.httpMethod"
        ip             = "$context.identity.sourceIp"
        protocol       = "$context.protocol"
        requestId      = "$context.requestId"
        requestTime    = "$context.requestTime"
        responseLength = "$context.responseLength"
        routeKey       = "$context.routeKey"
        status         = "$context.status"
        integration    = "$context.integrationErrorMessage"
        error          = "$context.error.message"
        responseType   = "$context.error.responseType"
      }
    )
  }

  tags = local.common_tags
}
