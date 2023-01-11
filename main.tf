provider "aws" {
  region = var.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.az
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "my security group"
  vpc_id      = aws_vpc.my_vpc.id
}

resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_instance" "my_instances" {
  ami           = var.ami_id
  instance_type = var.instance_type
  count         = var.instance_count

  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  subnet_id               = aws_subnet.my_subnet.id

  tags = {
    Name = "my_instance"
  }
}

resource "aws_eip" "my_eip" {
  count       = var.instance_count
  vpc         = true
  instance_id = aws_instance.my_instances.*.id[count.index]
}

output "eip" {
  value = aws_eip.my_eip.*.public_ip
}
