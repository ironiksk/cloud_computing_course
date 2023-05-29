module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  bus_name = local.bus_name

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
      },
      {
        name = "call-lambda-db"
        arn = aws_lambda_function.db_lambda.arn
      }      
    ]
  }


  tags = {
    Name = "event-bus"
  }
}