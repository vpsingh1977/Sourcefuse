resource "aws_vpc" "sourcefuse-aws-vpc" {
    cidr_block = var.VPC_CIDR
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    instance_tenancy = "default"
    
    tags = {
        "Name" = format("vpc-%s-%s-%s", var.AWS_REGION, var.ENV_CODE, var.APP_SHORT )
        "Environment" = var.ENVIRONMENT
        "ProjectID"  = var.PROJECT_ID
        "Resource Function" = "VPC"
    }
}

#Subnets 
resource "aws_subnet" "public-subnet-az-a" {
    vpc_id = "${aws_vpc.sourcefuse-aws-vpc.id}"
    cidr_block = var.PUB_AZA_CIDR
    map_public_ip_on_launch = "true"
    availability_zone = format("%sa", var.AWS_REGION)

    tags = {
        "Name" = format("sub-pub-%s-1a-%s-%s", var.AWS_REGION, var.ENV_CODE, var.APP_SHORT )
        "Environment" = var.ENVIRONMENT
        "ProjectID"  = var.PROJECT_ID
        "Resource Function" = "VPC"
    }
}
resource "aws_subnet" "public-subnet-az-b" {
    vpc_id = "${aws_vpc.sourcefuse-aws-vpc.id}"
    cidr_block = var.PUB_AZB_CIDR
    map_public_ip_on_launch = "true"
    availability_zone = format("%sb", var.AWS_REGION)

    tags = {
        "Name" = format("sub-pub-%s-1b-%s-%s", var.AWS_REGION, var.ENV_CODE, var.APP_SHORT )
        "Environment" = var.ENVIRONMENT
        "ProjectID"  = var.PROJECT_ID
        "Resource Function" = "VPC"
    }
}

resource "aws_subnet" "private-subnet-az-a" {
    vpc_id = "${aws_vpc.sourcefuse-aws-vpc.id}"
    cidr_block = var.PRIV_AZA_CIDR
    map_public_ip_on_launch = "false"
    availability_zone = format("%sa", var.AWS_REGION)

    tags = {
        "Name" = format("sub-priv-%s-1a-%s-%s", var.AWS_REGION, var.ENV_CODE, var.APP_SHORT )
        "Environment" = var.ENVIRONMENT
        "ProjectID"  = var.PROJECT_ID
        "Resource Function" = "VPC"
    }
}
resource "aws_subnet" "private-subnet-az-b" {
    vpc_id = "${aws_vpc.sourcefuse-aws-vpc.id}"
    cidr_block = var.PRIV_AZB_CIDR
    map_public_ip_on_launch = "false"
    availability_zone = format("%sb", var.AWS_REGION)

    tags = {
        "Name" = format("sub-priv-%s-1b-%s-%s", var.AWS_REGION, var.ENV_CODE, var.APP_SHORT )
        "Environment" = var.ENVIRONMENT
        "ProjectID"  = var.PROJECT_ID
        "Resource Function" = "VPC"
    }
}


