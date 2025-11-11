
################
# VPC Gateway Endpoints (S3 + DynamoDB)
# Attach to the private route tables (and public route tables for S3 if you want)
################
# S3 Gateway endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # attach to both private & public route tables so resources in either can reach S3 privately
  route_table_ids = concat(
    module.vpc.private_route_table_ids,
    module.vpc.public_route_table_ids
  )

  tags = {
    Name = "${var.name_prefix}-vpce-s3"
  }
}