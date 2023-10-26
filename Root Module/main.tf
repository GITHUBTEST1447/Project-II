module "aws-vpc" {
    source                   = "terraform-aws-modules/vpc/aws"
    name                     = "terraform-vpc"
    cidr                     = "192.168.0.0/16"
    azs                      = ["us-east-1a", "us-east-1b"]
    public_subnets           = ["192.168.1.0/24", "192.168.2.0/24"]
    public_subnet_tags = {
                      "Tier" = "Public"
    }

    private_subnet_tags = {
                      "Tier" = "Private"
    }
    private_subnets          = ["192.168.3.0/24", "192.168.4.0/24"]
    enable_nat_gateway       = false
    enable_vpn_gateway       = false


}

module "terraform-module" {
    source = "../Terraform Module"
    vpc_id = module.aws-vpc.vpc_id
    hosted_zone = "steffenaws.net"
    region = "us-east-1"
}