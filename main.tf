provider "aws" {
  region = var.region
}

resource "aws_vpc" "example" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.az
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

resource "aws_security_group" "example" {
  name        = "example"
  description = "example security group"
  vpc_id      = aws_vpc.example.id
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}

resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  count         = var.instance_count

  vpc_security_group_ids = [aws_security_group.example.id]
  subnet_id               = aws_subnet.example.id

  tags = {
    Name = "example"
  }
}

resource "aws_eip" "example" {
  count       = var.instance_count
  vpc         = true
  instance_id = aws_instance.example.*.id[count.index]
}

output "eip" {
  value = aws_eip.example.*.public_ip
}
