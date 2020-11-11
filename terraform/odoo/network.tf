resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.stack_name}-vpc-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.stack_name}-igw-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  count = length(var.public_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.stack_name}-nat-gw-${var.environment}-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_eip" "nat" {
  vpc = true
  count = length(var.private_subnets)

  tags = {
    Name = "${var.stack_name}-eip-${var.environment}-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  count = length(var.private_subnets)
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.stack_name}-private-subnet-${var.environment}-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  count = length(var.public_subnets)
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.stack_name}-public-subnet-${var.environment}-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.stack_name}-routing-table-public"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  count  = length(var.private_subnets)

  tags = {
    Name = "${var.stack_name}-routing-table-private-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.main.id
}


resource "aws_route" "private" {
  count = length(compact(var.private_subnets))
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = element(aws_route_table.private.*.id, count.index)
  nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.stack_name}-task-${var.environment}"

  tags = {
    Name = "${var.stack_name}-task-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.stack_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole"
        Principal: {
          Service: "vpc-flow-logs.amazonaws.com"
        },
        Effect: "Allow",
        Sid: "",
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  vpc_id = aws_vpc.main.id
  iam_role_arn = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.main.arn
  traffic_type = "ALL"
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "${var.stack_name}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Action: [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Effect: "Allow",
        Resource: "*"
      }
    ]
  })
}
