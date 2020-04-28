# DB tier

resource "aws_subnet" "maksaud_private_subnet" {
    vpc_id = var.vpc_id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-west-1a"
    tags = {
        Name = "${var.name}-subnet"
    }
}

# Creating NACLs
resource "aws_network_acl" "maksaud-eng54-private-nacl" {
    vpc_id = var.vpc_id
    subnet_ids = [aws_subnet.maksaud_private_subnet.id]

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
        from_port = 27017
        to_port = 27017
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
        cidr_block = "90.207.145.147/32" # Change to bastion
        from_port = 22
        to_port = 22
    }
    
    egress {
        protocol   = "-1"
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
resource "aws_security_group" "maksaud_db_security_group" {
    name        = "maksaud_db_security_group"
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
    description = "port 80 from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    description = "port 80 from VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    description = "port 22 from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["90.207.145.147/32"] # Change to bastion
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "maksaud_db_security_group"
    }
}

# Route table
resource "aws_route_table" "private-route" {
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
    subnet_id = aws_subnet.maksaud_private_subnet.id
    route_table_id = aws_route_table.private-route.id
}

#Launching the db instance ready to be inserted
resource "aws_instance" "db_instance" {
    ami = var.db_ami
    instance_type = "t2.micro"
    associate_public_ip_address = false
    subnet_id = aws_subnet.maksaud_private_subnet.id
    vpc_security_group_ids = [aws_security_group.maksaud_db_security_group.id]
    tags = {
        Name = "${var.name}-db"
    }
    key_name = "maksaud-eng54"

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("~/.ssh/maksaud-eng54.pem")}"
        host = self.public_ip
    }
}