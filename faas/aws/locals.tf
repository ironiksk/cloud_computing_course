locals {
  name_prefix = "${var.project}-${var.env}"

  common_tags = {
    Env           = var.env
    Project       = title(var.project)
  }

  bus_name = "event-bus"
  bucket_name = "ucu-faas-files-bucket"
  api_event_lambda_name = "api-event"
  event_lambda_name = "event"

}
