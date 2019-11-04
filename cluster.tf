resource "aws_key_pair" "node" {
  key_name   = "${var.cluster_name}-Node"
  public_key = file(var.node_key)
}

resource "aws_eip" "node" {
  vpc = true

  tags = {
    Name      = "${var.cluster_name}-Node"
    Terraform = "Yes"
  }
}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  most_recent = true
  owners      = ["099720109477"]
}

data "template_file" "node-userdata" {
  template = file("init-kube.sh")

  vars = {
    k8s_version  = var.k8s_version
    helm_version = var.helm_version
    admin_token  = var.admin_token
    dns_name     = lower("${var.cluster_name}.${var.host_zone}")
    ip_address   = aws_eip.node.public_ip
    cluster_name = var.cluster_name
  }
}

resource "aws_instance" "node" {
  instance_type          = var.node_type
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.node.key_name
  subnet_id              = aws_subnet.cluster.id
  iam_instance_profile   = aws_iam_instance_profile.node.name
  user_data              = data.template_file.node-userdata.rendered
  vpc_security_group_ids = [aws_security_group.node.id]

  tags = {
    Name                                        = var.cluster_name
    Terraform                                   = "Yes"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip_association" "node" {
  instance_id   = aws_instance.node.id
  allocation_id = aws_eip.node.id
}

data "aws_route53_zone" "cluster" {
  name         = "${var.host_zone}."
  private_zone = false
}

resource "aws_route53_record" "cluster" {
  zone_id = data.aws_route53_zone.cluster.zone_id
  name    = "${var.cluster_name}.${var.host_zone}."
  type    = "A"
  records = [aws_eip.node.public_ip]
  ttl     = 300
}

resource "aws_route53_record" "cluster-ingress" {
  zone_id = data.aws_route53_zone.cluster.zone_id
  name    = "*.${var.cluster_name}.${var.host_zone}."
  type    = "A"
  records = [aws_eip.node.public_ip]
  ttl     = 300
}

