locals {
  name_prefix = "${var.project}-${var.env}"

  common_tags = {
    Env           = var.env
    Project       = title(var.project)
  }

  api_event_lambda_name = "api-event"

}
