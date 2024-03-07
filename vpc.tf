resource "aws_eip" "elastic-ip-tf" {
  tags = {
    Name = "${var.vpc_name}-elastic-ip"
  }
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.vpc-tf.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

resource "aws_subnet" "vpc-tf-public-subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc-tf.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.availability-zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  }
}


# resource "aws_subnet" "vpc-tf-private-subnets" {
#   count = length(var.private_subnet_cidrs)
#   vpc_id     = aws_vpc.vpc-tf.id
#   cidr_block = element(var.private_subnet_cidrs, count.index)
#   availability_zone = element(var.availability-zones,count.index)

#   tags = {
#     Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
#   }
# }

#  resource "aws_nat_gateway" "nat-gateway-tf" {
#   allocation_id = aws_eip.elastic-ip-tf.id
#   subnet_id     = aws_subnet.vpc-tf-public-subnets[0].id

#   tags = {
#     Name = "${var.vpc_name}-NATGATEWAY"
#   }
#   depends_on = [aws_internet_gateway.internet-gw]
# } 


resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-route-table"
  }
}


# resource "aws_route_table" "private-route-table" {
#   vpc_id = aws_vpc.vpc-tf.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat-gateway-tf.id
#   }

#   tags = {
#     Name = "${var.vpc_name}-private-route-table"
#   }
# }



resource "aws_route_table_association" "route-table-association-public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.vpc-tf-public-subnets[*].id, count.index)
  route_table_id = aws_route_table.public-route-table.id
}

# resource "aws_route_table_association" "route-table-association-private" {
#   count =  length(var.private_subnet_cidrs)
#   subnet_id      = element(aws_subnet.vpc-tf-private-subnets[*].id,count.index)
#   route_table_id = aws_route_table.private-route-table.id
# }


resource "aws_vpc" "vpc-tf" {
  cidr_block = "${var.vpc-cidr-range}"
  tags = {
    Name = var.vpc_name
  }
}



