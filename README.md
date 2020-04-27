# Terraform for sparta node app :shark:

This project orchestrates the environment for the sparta node app following on from the ami that was built by this repository:
- https://github.com/Maksaud/packer-for-node

This repository includes two files:
- main.tf
- variables.tf

## Sparta Node App

This is an app created by sparta and using NodeJS. This app has a few pages which includes:
- fibonacci (a page with a fibonacce calculator) which is found using: https://yourip/fibonacci/number-you-want-to-calc
- posts (a blog page) which is found using the url: https://yourip/posts

## Pre-requiesites

```
sparta-node-app-AMI
AWS CLI
terraform
AWS credentials
aws ssh keys
Git
```

## Terraform

Terraform is an infrastucture as code tool that orchestrates environments by creating networks, provisioning or launching machines using AMIs.

## variables.tf

This file is used to initialise variables to be used such as name:

```terraform
variable "name" {
    default = "eng54-Maksaud-node-app-tf"
}
```

## main.tf

This file is used to run the main code for the terraform. For example:

```terraform
# Creating instance from ami
resource "aws_instance" "app_instance" {
    ami = var.ami
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = aws_subnet.app_subnet.id
    vpc_security_group_ids = [aws_security_group.maksaud_security_group.id]
    tags = {
        Name = var.name
    }
    key_name = "maksaud-eng54"

    user_data = data.template_file.app_init.rendered

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("~/.ssh/maksaud-eng54.pem")}"
        host = self.public_ip
    }
}
```

This is the block of terraform code that creates an EC2 instance from an ami with certain configurations.

## initialise working directory

```
terraform init
```

This command initialises the working directory that has terraform configuration files

## Plan

```
terraform plan
```

This command is used to show an execution plan so that you can check if the terraform is going to execute what you expect

## apply

```
terraform apply
```

This used to apply the changes that you have made to the configuration.

For us the terraform will create an EC2 instance from a pre-existing AMI and start the app inside.