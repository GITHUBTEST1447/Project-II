# DB Subnet group for RDS database
resource "aws_db_subnet_group" "db_subnet_group" {
  name                          = "terraform-vpc-db-subnet-group"
  subnet_ids                    = data.aws_subnets.private_subnets.ids
}

# Security group for RDS Database
resource "aws_security_group" "rds_sg" {
  name                          = "Terraform RDS SG"
  description                   = "Allow ECS access to RDS"
  vpc_id                        = data.aws_vpc.aws-vpc.id

  ingress {
    from_port                   = 5432
    to_port                     = 5432
    protocol                    = "tcp"
    cidr_blocks                 = ["0.0.0.0/0"] # REMOVE LATER
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
  password                      = "password123" # IMPLEMENT AWS SECRETS MANAGER
  skip_final_snapshot           = true
  instance_class                = "db.t3.micro"
  db_subnet_group_name          = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids        = [aws_security_group.rds_sg.id]

  depends_on = [
    data.aws_vpc.aws-vpc
  ]
}

# AWS ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "Terraform-ECS-Cluster"
}

# AWS ECS Task Definition
resource "aws_ecs_task_definition" "task_definition" {
  family = "Flask-App-Task-Definition"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "2048"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  execution_role_arn = var.execution_role_arn
  task_role_arn = var.ecs_task_role_arn
  container_definitions = local.container_definition
}

# ECS SECURITY GROUP
resource "aws_security_group" "ecs_sg" {
  name                          = "Terraform ECS SG"
  description                   = "Configure ECS access"
  vpc_id                        = data.aws_vpc.aws-vpc.id

  ingress {
    from_port                   = 80
    to_port                     = 80
    protocol                    = "tcp"
    #cidr_blocks                 = ["0.0.0.0/0"] # REMOVE LATER
    security_groups = [aws_security_group.lb_security_group.id] 
  }
  egress {
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = ["0.0.0.0/0"]
  }
}

# Security group for ECS' Load Balancer
resource "aws_security_group" "lb_security_group" {
    name        = "terraform-lb-security-group"
    vpc_id      = var.vpc_id
  ingress { # REMOVE HTTP/80 LATER
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target group for ECS' Load Balancer
resource "aws_lb_target_group" "target_group" {
    name =      "terraform-target-group"
    port =      80
    protocol =  "HTTP"
    target_type = "ip"
    vpc_id =    var.vpc_id
}

# Load Balancer for AWS ECS Service
resource "aws_lb" "load_balancer" {
  name = "terraform-lb-ecs"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.lb_security_group.id]
  subnets = data.aws_subnets.public_subnets.ids
}

# Create HTTPS listener for load balancer
resource "aws_lb_listener" "lb_listener" {
    load_balancer_arn = aws_lb.load_balancer.arn
    port              = "80" # CHANGE To 443 LATER
    protocol          = "HTTP" # CHANGE To HTTPS LATER
    #ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    #certificate_arn   = var.certificate_arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.target_group.arn
    }
}

# ECS SERVICE NEXT
resource "aws_ecs_service" "ecs_service" {
  name = "flaskapp-service"
  cluster = aws_ecs_cluster.ecs_cluster.id
  launch_type = "FARGATE"
  desired_count = 1
  task_definition = aws_ecs_task_definition.task_definition.arn

  network_configuration {
    subnets = data.aws_subnets.public_subnets.ids # CHANGE TO PRIVATE SUBNETS LATER
    assign_public_ip = true # Remove this later
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name = "flaskapp-container"
    container_port = "80"
  }
}


# ADD LOAD BALANCER (RESOURCE AND AS PART OF SERVICE)
# FIGURE OUT CONFIGURATION FOR RDS DATABASE
# ROUTE 53 RECORD -> Load BALANCER
# TERRAFORM TESTING IN CI/CD WORKFLOW
# FIX SECURITY ISSUES, AWS SECRETS MANAGER
# HEALTH CHECKS?
