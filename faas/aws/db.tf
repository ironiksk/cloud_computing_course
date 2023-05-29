data "aws_secretsmanager_random_password" "test" {
  password_length = 50
  exclude_numbers = true
}

resource "random_password" "pgdb" {
  length = 16
}

variable "pgdb_username" {
  type    = string
  default = "dbuser"
}


# Secrets
resource "aws_secretsmanager_secret" "pgdb" {
  name = "faas-database-secret"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "pgdb" {
  secret_id     = aws_secretsmanager_secret.pgdb.id
  secret_string = jsonencode({ username = var.pgdb_username, password = random_password.pgdb.result })
}


# resource "aws_db_instance" "bl-db" {
#   allocated_storage       = 10 # gigabytes
#   backup_retention_period = 7 # in days
#   engine                  = "postgres"
#   engine_version          = "15.3"
#   identifier              = "faasdb"
#   name                    = "faasdb"
#   instance_class          = "db.t4g.small"
#   multi_az                = false
#   username                = var.pgdb_username
#   password                = random_password.pgdb.result
#   port                    = 5432
#   publicly_accessible     = true
#   storage_encrypted       = false
#   storage_type            = "gp2"
#   skip_final_snapshot     = true
# }


module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "faasdb"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t4g.large"

  allocated_storage     = 20
  max_allocated_storage = 100

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  # db_name  = "database"
  username = var.pgdb_username
  password = random_password.pgdb.result
  port     = 5432

  multi_az               = true

  db_subnet_group_name                = module.vpc.database_subnet_group
  create_db_subnet_group              = false
  vpc_security_group_ids              = [aws_security_group.database.id]

  # db_subnet_group_name   = module.vpc.database_subnet_group
  # vpc_security_group_ids = [module.security_group.security_group_id]

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



################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "vpc-faas-db"
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true

  # tags = local.tags
}


resource "aws_security_group" "database" {
  name        = "faas-database"
  vpc_id      = module.vpc.vpc_id
  description = "Security Group for database"

  ingress {
    description     = "Ingress from application instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = ["0.0.0.0"]
  }

  egress {
    description = "Egress all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

