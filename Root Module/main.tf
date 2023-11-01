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
    enable_nat_gateway       = true
    enable_vpn_gateway       = false


}

module "terraform-module" {
    source = "../Terraform Module" # This calls the module.
    vpc_id = module.aws-vpc.vpc_id # This field requires a VPC to already be made. VPC made via the official VPC module above.
    hosted_zone = "steffenaws.net" # This requires you to have a Route53 Hosted Zone.
    certificate_arn = "arn:aws:acm:us-east-1:060477591397:certificate/ce43b223-d157-419a-adc6-a1eb4428b723" # This requires you to have a ACM certificate made that is associated with your goal record.
    region = "us-east-1" # This is the region.
    rds_snapshot = "arn:aws:rds:us-east-1:060477591397:snapshot:terraform-rds-snapshot-new" # Snapshot of the database you want used in your application.
    rds_secret_name = "terraform/rds/secret" # This is the secrets where the database credentials are stored.
}