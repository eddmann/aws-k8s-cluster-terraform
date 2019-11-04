resource "aws_vpc" "cluster" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name      = "${var.cluster_name}-Cluster"
    Terraform = "Yes"
  }
}

resource "aws_subnet" "cluster" {
  vpc_id                  = aws_vpc.cluster.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-1c"
  map_public_ip_on_launch = false

  tags = {
    Name      = "${var.cluster_name}-Cluster"
    Terraform = "Yes"
  }
}

resource "aws_internet_gateway" "cluster" {
  vpc_id = aws_vpc.cluster.id

  tags = {
    Name      = "${var.cluster_name}-Cluster"
    Terraform = "Yes"
  }
}

resource "aws_route" "cluster" {
  route_table_id         = aws_vpc.cluster.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cluster.id
}

resource "aws_security_group" "node" {
  vpc_id = aws_vpc.cluster.id
  name   = "${var.cluster_name}-Node"

  tags = {
    Terraform = "Yes"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

