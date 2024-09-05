resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
   tags = {
    Name = "par-vpc"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "par-subnet-private"
  }
}

 resource "aws_subnet" "public" {
   count = length(var.public_subnets)
   vpc_id = aws_vpc.main.id
   cidr_block = var.public_subnets[count.index]
   map_public_ip_on_launch = true


  tags = {
    Name = "par-subnet-public"
  }
 }

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "public"
  }
}

# resource "aws_route_table_association" "private-us-east-1a" {
#   subnet_id      = aws_subnet.private[0].id
#   route_table_id = aws_route_table.private.id
# }

# resource "aws_route_table_association" "private-us-east-1b" {
#   subnet_id      = aws_subnet.private[1].id
#   route_table_id = aws_route_table.private.id
# }

# resource "aws_route_table_association" "public-us-east-1a" {
#   subnet_id      = aws_subnet.public[0].id
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route_table_association" "public-us-east-1b" {
#   subnet_id      = aws_subnet.public[1].id
#   route_table_id = aws_route_table.public.id
# }


resource "aws_route_table_association" "private" {
  for_each = { for idx, subnet in aws_subnet.private : idx => subnet.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  for_each = { for idx, subnet in aws_subnet.public : idx => subnet.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

