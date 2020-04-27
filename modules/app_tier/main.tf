# App tier
# Move here anything to do with the app tier creation

# Subnet
resource "aws_subnet" "app_subnet" {
    vpc_id = var.vpc_id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-west-1a"
    tags = {
        Name = var.name
    }
}

# Creating NACLs
resource "aws_network_acl" "maksaud-public-nacl" {
    vpc_id = var.vpc_id

    ingress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    ingress {
        protocol = "tcp"
        rule_no = 110
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    ingress {
        protocol = "tcp"
        rule_no = 120
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 3000
        to_port = 3000
    }

    ingress {
        protocol = "tcp"
        rule_no = 130
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 1024
        to_port = 65535
    }

    ingress {
        protocol = "tcp"
        rule_no = 140
        action = "allow"
        cidr_block = "90.207.145.147/32"
        from_port = 22
        to_port = 22
    }
    
    egress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }


    tags = {
        Name = "${var.name}-nacl"
    }

}


# Creating Security group
resource "aws_security_group" "maksaud_security_group" {
    name        = "Maksaud-eng54-node-security-group"
    description = "Allow port 80 inbound traffic"
    vpc_id      = var.vpc_id

    ingress {
    description = "port 80 from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    description = "port 22 from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["90.207.145.147/32"]
    }

    ingress {
    description = "port 3000 from VPC"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Maksaud-eng54-node-security-group"
    }
}

# Route table
resource "aws_route_table" "public" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = var.internet_gateway
    }

    tags = {
        Name = "${var.name}-public"
    }

}

resource "aws_route_table_association" "assoc" {
    subnet_id = aws_subnet.app_subnet.id
    route_table_id = aws_route_table.public.id
}

data "template_file" "app_init" {
    template = "${file("./scripts/app/init.sh.tpl")}"
        vars = {
            my_name = "${var.name} is the real maksaud"
        }
        # setting ports
        # for mongo db, setting private_op for db host
            # AWS gives
}

# Launching the app instance instance
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
