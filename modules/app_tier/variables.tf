variable "vpc_id" {
    description = "The vpc it lauches resources into"
}

variable "name" {
    description = "Base used to identify resources."
}

variable "ami" {
    description = "The ami for the app"
}

variable "db_ip" {
    description = "database variable"   
}

variable "internet_gateway" {
    description = "internet gateway"
}