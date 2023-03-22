resource "aws_vpc" "cka" {
    cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "cka" {
    vpc_id = aws_vpc.cka.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
}


resource "aws_internet_gateway" "cka" {
    vpc_id = aws_vpc.cka.id
}


resource "aws_eip" "cka_master" {
    instance = aws_instance.cka_master.id
    vpc = true
}


resource "aws_eip" "cka_worker" {
    instance = aws_instance.cka_worker.id
    vpc = true
}


resource "aws_route_table" "cka" {
    vpc_id = aws_vpc.cka.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.cka.id
    }
}


resource "aws_route_table_association" "cka" {
    subnet_id = aws_subnet.cka.id
    route_table_id = aws_route_table.cka.id
}


resource "aws_security_group" "allow_ssh" {
    name = "Allow ssh"
    description = "Allow SSH to instances"
    vpc_id = aws_vpc.cka.id
    
    ingress {
        description = "TLS from Internet"
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = [var.ip_address] #Change to perosnal IP
    }

    ingress {
        description = "inner subnet coms"
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/24"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "cka_master" {
    ami = "ami-0cefaebb6da6ffd7f"
    instance_type = "t4g.large"
    key_name = "ubuntu"
    subnet_id = aws_subnet.cka.id
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]


    tags = {
        App = "K8s"
        Course = "CKA"
    }
}

resource "aws_instance" "cka_worker" {
    ami = "ami-0cefaebb6da6ffd7f"
    instance_type = "t4g.large"
    key_name = "ubuntu"
    subnet_id = aws_subnet.cka.id
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]


    tags = {
        App = "K8s"
        Course = "CKA"
    }
}


output "control_node_ip" {
    value = aws_eip.cka_master.public_ip
}


output "worker_node_ip" {
    value = aws_eip.cka_worker.public_ip
}