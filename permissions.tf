resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-Node"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = {
    Terraform = "Yes"
  }
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy" "ebs" {
  name        = "${var.cluster_name}-EBS"
  path        = "/"
  description = "Permit dynamic provisioning of EBS persistent volumes"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DescribeVpcs",
        "elasticloadbalancing:DescribeLoadBalancers",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ebs" {
  role       = aws_iam_role.node.name
  policy_arn = aws_iam_policy.ebs.arn
}

resource "aws_iam_policy" "route53" {
  name        = "${var.cluster_name}-Route53"
  path        = "/"
  description = "Permit access to Route 53 for DNS record creation"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:GetHostedZone",
        "route53:ListHostedZones",
        "route53:ListHostedZonesByName",
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets",
        "route53:GetChange"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "route53" {
  role       = aws_iam_role.node.name
  policy_arn = aws_iam_policy.route53.arn
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.cluster_name}-Node"
  role = aws_iam_role.node.name
}
