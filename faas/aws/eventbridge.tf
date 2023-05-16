module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  bus_name = "event-bus"

  rules = {
    orders = {
      description   = "Capture all order data"
      event_pattern = jsonencode({ "Source" : ["api"] })
      enabled       = true
    }
  }

  #targets = {
  #  orders = [
  #    {
  #      name            = "send-orders-to-sqs"
  #      arn             = aws_sqs_queue.queue.arn
  #      dead_letter_arn = aws_sqs_queue.dlq.arn
  #    },
  #    {
  #      name              = "send-orders-to-kinesis"
  #      arn               = aws_kinesis_stream.this.arn
  #      dead_letter_arn   = aws_sqs_queue.dlq.arn
  #      input_transformer = local.kinesis_input_transformer
  #    },
  #    {
  #      name = "log-orders-to-cloudwatch"
  #      arn  = aws_cloudwatch_log_group.this.arn
  #    }
  #  ]
  #}

  tags = {
    Name = "event-bus"
  }
}