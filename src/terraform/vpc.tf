resource "aws_vpc" "cka" {
  cidr_block = var.vpc_cidr_range
}


resource "aws_subnet" "cka" {
  vpc_id                  = aws_vpc.cka.id
  cidr_block              = var.subnet_cidr_range
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/role/elb" = "1"
  }
}


resource "aws_internet_gateway" "cka" {
  vpc_id = aws_vpc.cka.id
}


resource "aws_eip" "cka_master" {
  instance = aws_instance.cka_master.id
  vpc      = true
}


resource "aws_eip" "cka_worker" {
  count    = length(aws_instance.cka_worker)
  instance = aws_instance.cka_worker[count.index].id

  //aws_instance.cka_worker.id
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
  subnet_id      = aws_subnet.cka.id
  route_table_id = aws_route_table.cka.id
}


resource "aws_security_group" "allow_ssh" {
  name        = "Allow ssh"
  description = "Allow SSH to instances"
  vpc_id      = aws_vpc.cka.id

  ingress {
    description = "TLS from Internet"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.remote_ip_address]
  }

  ingress {
    description = "inner subnet coms"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr_range]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "cka_master" {
  ami                    = var.ami_image
  instance_type          = var.instance_size
  key_name               = var.ami_key_name
  subnet_id              = aws_subnet.cka.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }

  iam_instance_profile = aws_iam_instance_profile.k8s_worker_profile.id

  tags = {
    App    = "K8s"
    Course = "CKA"
  }
}

resource "aws_instance" "cka_worker" {
  count                  = var.worker_node_count
  ami                    = var.ami_image
  instance_type          = var.instance_size
  key_name               = var.ami_key_name
  subnet_id              = aws_subnet.cka.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  iam_instance_profile = aws_iam_instance_profile.k8s_worker_profile.id

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }


  tags = {
    App    = "K8s"
    Course = "CKA"
  }
}


output "control_node_ip" {
  value = aws_eip.cka_master.public_ip
}


output "worker_node_ip" {
  value = [for i in aws_eip.cka_worker : i.public_ip]
}
