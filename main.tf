provider "aws" {
    region = "eu-west-1"
}

#create a VPC
resource "aws_vpc" "app_vpc" {
   cidr_block = "10.0.0.0/16"
   tags = {
       Name = "${var.name}-vpc"
   }
}

# Create internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.app_vpc.id

    tags = {
        Name = "${var.name}-ig"
    }
  
}

#### create app tier
# Use devops vpc
    # vpc-07e47e9d90d2076da
# Create new subnet
# move instance into subnet

# Create app tier with all veriables we pass to it
module "app" {
    source = "./modules/app_tier"
    vpc_id = aws_vpc.app_vpc.id
    name = var.name
    ami = var.ami
    internet_gateway = aws_internet_gateway.igw.id
}

module "db" {
    source = "./modules/db_tier"
    vpc_id = aws_vpc.app_vpc.id
    name = var.name
    #db_ami = var.db_ami
    internet_gateway = aws_internet_gateway.igw.id
}


