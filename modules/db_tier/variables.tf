variable "vpc_id" {
    description = "The vpc it lauches resources into"
}

variable "name" {
    description = "Base used to identify resources."
}
variable "db_ami" {
    description = "The ami for the db"
}

variable "internet_gateway" {
    description = "internet gateway"
}