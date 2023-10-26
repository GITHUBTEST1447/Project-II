variable "vpc_id" { # Gathers the VPC
    description = "The VPC ID that the infrastructure should be deployed in."
    type = string
}

data "aws_vpc" "aws-vpc" {
  id = var.vpc_id
}

variable "hosted_zone" {
    description = "Hosted zone of your route53"
    type = string
}

variable "region" {
    type = string
    description = "Region to deploy in AWS"
}

data "aws_subnets" "private_subnets" { # Gathers all subnets in the VPC
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.aws-vpc.id]
    }

    filter {
        name   = "tag:Tier"
        values = ["Private"]
    }
}

data "aws_subnets" "public_subnets" { # Gathers all subnets in the VPC
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.aws-vpc.id]
    }

    filter {
        name   = "tag:Tier"
        values = ["Public"]
    }
}

variable "execution_role_arn" {
    default = "arn:aws:iam::198550855569:role/ecsTaskExecutionRole"
}

variable "ecs_task_role_arn" {
    default = "arn:aws:iam::198550855569:role/ECS-FULL-ACCESS"
}

# Container definition for ECS task
locals {
  container_definition = jsonencode([
    {
      name  = "my-container"
      image = "steffenp123/flaskapp"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "POSTGRES_PASSWORD"
          value = "test12345"
        },
        {
          name  = "POSTGRES_USER"
          value = "postgres"
        },
        {
          name  = "POSTGRES_DB"
          value = "postgres"
        },
        {
          name  = "DB_HOSTNAME"
          value = aws_db_instance.database.arn
        }
      ]
      ephemeralStorage = {
        sizeInGiB = 20
      }
      memory = 2048 # This is in MiB.
      cpu    = 512 # This represents the CPU units.
    }
  ])
}