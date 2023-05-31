locals {
  name_prefix = "${var.project}"

  common_tags = {
    Env           = var.env
    Project       = title(var.project)
  }

  bus_name = "event-bus"
  bucket_name = "ucu-faas-files-bucket"
  api_event_lambda_name = "api_event_function"
  event_lambda_name = "event_function_function"
  db_lambda_name = "event_db_function"

  
  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
  secrets_db_name = "faas-secret"

  vpc_cidr = "10.0.0.0/16"
  private_subnet_cidr_list = [cidrsubnet(var.vpc_cidr, 2, 0), cidrsubnet(var.vpc_cidr, 2, 1), cidrsubnet(var.vpc_cidr, 2, 2)]
  public_subnet_cidr_list  = [cidrsubnet(var.vpc_cidr, 6, 48), cidrsubnet(var.vpc_cidr, 6, 50), cidrsubnet(var.vpc_cidr, 6, 52)]

  pgdb_username = "dbuser"

  db_name = "postgres"

  secrets = { 
    host = module.db.db_instance_address
    #database = module.db.db_instance_name
    database = local.db_name
    username = module.db.db_instance_username
    password = module.db.db_instance_password
  }
}
