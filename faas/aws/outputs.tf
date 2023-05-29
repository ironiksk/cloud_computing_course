output "api_url" {
  description = "API URL"
  value       = aws_apigatewayv2_api.api_event.api_endpoint
}

output "rds" {
  description = "Amazon RDS instance information and DB credentials for Backend instance"
  #sensitive   = true
  value = {
    instance_arn                  = module.db.db_instance_arn
    instance_address              = module.db.db_instance_address
    instance_endpoint             = module.db.db_instance_endpoint
    instance_port                 = module.db.db_instance_port
    instance_id                   = module.db.db_instance_id
    #instance_username             = module.db.db_instance_username
    #instance_password             = module.db.db_instance_password
  }
}