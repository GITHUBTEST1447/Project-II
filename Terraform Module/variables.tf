variable "vpc_id" { # Gathers the VPC
    description = "The VPC ID that the infrastructure should be deployed in."
    type = string
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
        values = [var.vpc_id]
    }

    filter {
        name   = "tag:Tier"
        values = ["Private"]
    }
}

data "aws_subnets" "public_subnets" { # Gathers all subnets in the VPC
    filter {
        name   = "vpc-id"
        values = [var.vpc_id]
    }

    filter {
        name   = "tag:Tier"
        values = ["Public"]
    }
}