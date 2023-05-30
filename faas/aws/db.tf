resource "aws_db_subnet_group" "database" {
  name       = "faassubnetdatabase"
  subnet_ids = module.vpc.public_subnets
}


module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> v5.9.0"
  identifier = "${local.name_prefix}-db"

  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t4g.large"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name = local.db_name
  username = local.pgdb_username
  password = random_password.pgdb.result
  port     = 5432

  multi_az               = true

  db_subnet_group_name                = aws_db_subnet_group.database.id
  vpc_security_group_ids              = [aws_security_group.database.id]
  subnet_ids = aws_db_subnet_group.database.subnet_ids


  publicly_accessible = true

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "example-monitoring-role-name"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Description for monitoring role"

}

