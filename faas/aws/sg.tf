resource "aws_security_group" "database" {
  name        = "${local.name_prefix}-database"
  vpc_id      = module.vpc.vpc_id
  description = "Security Group for database"

  # ingress {
  #   description     = "Ingress from application instances"
  #   from_port       = 5432
  #   to_port         = 5432
  #   protocol        = "TCP"
  #   security_groups = [aws_security_group.lambda.id]
  # }

  ingress {
    description = "Ingress from VPN"
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Egress all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}