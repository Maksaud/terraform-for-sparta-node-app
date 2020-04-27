provider "aws" {
    region = "eu-west-1"
}

# create a VPC
#resource "aws_vpc" "app_vpc" {
#    cidr_block = "10.0.0.0/16"
#    tags = {
#        Name = "Maksaud-eng54-app_vpc"
#    }
#}

#### create app tier
# Use devops vpc
    # vpc-07e47e9d90d2076da
# Create new subnet
# move instance into subnet




# We don't need a new IG -
# We can query our exist vpc/infrastructure with the 'data' handler/function
data "aws_internet_gateway" "default-gw" {
    filter {
        name = "attachment.vpc-id"
        values = [var.vpc_id]
    }
  
}

module "app" {
    source = "./modules/app_tier"
    vpc_id = var.vpc_id
    name = var.name
    ami = var.ami
    internet_gateway = var.internet_gateway
}


