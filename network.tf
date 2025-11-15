data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 4.0"

  name = var.name_prefix
  cidr = var.vpc_cidr

  # select first 2 AZs
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  reuse_nat_ips          = false
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.name_prefix}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = module.vpc.vpc_id

  # Lambda functions do not need inbound access
  ingress = []

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-lambda-sg"
  }
}


resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.name_prefix}/network/vpc-id"
  type  = "String"
  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "lambda_security_group_id" {
  name  = "/${var.name_prefix}/network/lambda-security-group-id"
  type  = "String"
  value = aws_security_group.lambda_sg.id
}


resource "aws_ssm_parameter" "lambda_subnet_ids" {
  name  = "/${var.name_prefix}/network/lambda-subnet-ids"
  type  = "StringList"
  value = join(",", module.vpc.private_subnets)
}
