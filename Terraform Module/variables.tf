variable "vpc_id" { # Gathers the VPC
    description = "The VPC ID that the infrastructure should be deployed in."
    type = string
}

variable "rds_snapshot" {
    type = string
}

data "aws_vpc" "aws-vpc" {
  id = var.vpc_id
}

variable "hosted_zone" {
    description = "Hosted zone of your route53"
    type = string
}

variable "certificate_arn" {
    description = "SSL/TLS Certificate"
    type = string
}

data "aws_route53_zone" "hosted_zone_data" {
  name = var.hosted_zone
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
  container_definition = <<DEFINITION
  [
    {
      "name": "flaskapp-container",
      "image": "steffenp123/flaskapp",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "POSTGRES_PASSWORD",
          "value": "${var.db_password}"
        },
        {
          "name": "POSTGRES_USER",
          "value": "${var.db_user}"
        },
        {
          "name": "POSTGRES_DB",
          "value": "${var.db_name}"
        },
        {
          "name": "DB_HOSTNAME",
          "value": "${aws_db_instance.database.arn}"
        }
      ],
      "ephemeralStorage": {
        "sizeInGiB": 20
      },
      "memory": 2048,
      "cpu": 512
    }
  ]
  DEFINITION
}

variable "db_name" {
    default = "postgres"
}

variable "db_user" {
    default = "postgres"
}

variable "db_password" {
    default = "password123"
}