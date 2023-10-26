resource "aws_instance" "test_instance" {

    ami = var.ami
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.test_tf_sg.id]
    subnet_id = data.aws_subnet.default.id

    tags = {
        Name = "Test Terraform Instance"
    }
}

resource "aws_security_group" "test_tf_sg" {
  name        = "Test Terraform SG"
  description = "Allow traffic to test EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Test Terraform SG"
  }
}