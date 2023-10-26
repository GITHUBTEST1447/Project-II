# DB Subnet group for RDS database
resource "aws_db_subnet_group" "db_subnet_group" {
  name                          = "terraform-vpc-db-subnet-group"
  subnet_ids                    = data.aws_subnets.private_subnets.ids
}

# Security group for RDS Database
resource "aws_security_group" "rds_sg" {
  name                          = "Terraform RDS SG"
  description                   = "Allow ECS access to RDS"
  vpc_id                        = var.vpc_id

  ingress {
    from_port                   = 5432
    to_port                     = 5432
    protocol                    = "tcp"
    cidr_blocks                 = ["0.0.0.0/0"]
    #security_groups = [ THE ECS SECURITY GROUP ]  COMPLETE LATER
  }
  egress {
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = ["0.0.0.0/0"]
  }
}

# RDS Database
resource "aws_db_instance" "database" { # NEED TO ACTUALLY HAVE THE DATABASE AUTOMATICALLY CONFIGURTED NOW!
  engine                        = "postgres"
  engine_version                = "15.3"
  identifier                    = "terraform-rds-db"
  storage_type                  = "gp2"
  max_allocated_storage         = 200
  allocated_storage             = 20
  network_type                  = "IPV4"
  db_name                       = "postgres"
  username                      = "postgres"
  password                      = "password123"
  skip_final_snapshot           = true
  instance_class                = "db.t3.micro"
  db_subnet_group_name          = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids        = [aws_security_group.rds_sg.id]
}