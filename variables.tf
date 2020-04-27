variable "vpc_id" {
    default = "vpc-07e47e9d90d2076da"
}

variable "name" {
    default = "eng54-Maksaud-node-app-tf"
}

variable "ami" {
    default = "ami-0a4db0cd882d67374"
}

variable "internet_gateway" {
    default = "data.aws_internet_gateway.default-gw.id"
}