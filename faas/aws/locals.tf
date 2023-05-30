locals {
  name_prefix = "${var.project}-${var.env}"

  common_tags = {
    Env           = var.env
    Project       = title(var.project)
  }

  bus_name = "event-bus"
  bucket_name = "ucu-faas-files-bucket"
  api_event_lambda_name = "api_event_function"
  event_lambda_name = "event_function_function"
  db_lambda_name = "event_db_function"

  vpc_cidr = "10.0.0.0/16"
  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
  secrets_db_name = "faas-secrets"
}
