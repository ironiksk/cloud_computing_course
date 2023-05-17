module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  bus_name = "event-bus"

  rules = {
    events = {
      description   = "Capture all order data"
      event_pattern = jsonencode({ "source" : ["api.event"] })
      enabled       = true
    }
  }

  targets = {
    events = [
      {
        name = "call-lambda"
        arn = aws_lambda_function.event_lambda.arn
      }
    ]
  }


  tags = {
    Name = "event-bus"
  }
}