resource "aws_vpc" "lab-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "lab_vpc"
  }
}

resource "aws_subnet" "lab-subnet-public-1" {
  vpc_id                  = aws_vpc.lab-vpc.id
  cidr_block              = "10.0.0.0/20"
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = "us-east-1a"
  tags = {
    Name = "lab-subnet-public-1"
  }
}

resource "aws_subnet" "firewall-subnet-public-1" {
  vpc_id                  = aws_vpc.lab-vpc.id
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = "us-east-1a"
  tags = {
    Name = "firewall-subnet-public-1"
  }
}

resource "aws_route_table" "igw-route" {
  vpc_id = aws_vpc.lab-vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "10.0.0.0/20"
    //CRT uses this IGW to reach internet
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.networkFirewallLab.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id], 0)
  }

  tags = {
    Name = "igw-route"
  }
}

resource "aws_route_table_association" "igw-route-association" {
  gateway_id     = aws_internet_gateway.lab-igw.id
  route_table_id = aws_route_table.igw-route.id
}

resource "aws_route_table" "firewall-route" {
  vpc_id = aws_vpc.lab-vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.lab-igw.id
  }

  tags = {
    Name = "firewall-route"
  }
}
