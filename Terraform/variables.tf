variable "ami" {
    default = "ami-0df435f331839b2d6"
}

variable "instance_type" {
    default = "t2.micro"
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet" "default" {
    vpc_id = data.aws_vpc.default.id
    availability_zone = "us-east-1a"
}