data "aws_secretsmanager_random_password" "test" {
  password_length = 50
  exclude_numbers = true
}

resource "random_password" "pgdb" {
  length = 16
}

# Secrets
resource "aws_secretsmanager_secret" "pgdb" {
  name = local.secrets_db_name # "faas-database-secret"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "pgdb" {
  secret_id     = aws_secretsmanager_secret.pgdb.id
  secret_string = jsonencode(local.secrets)
}
