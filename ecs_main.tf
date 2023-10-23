# Terraform 

terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "> 5.0.0"
      }
    }
}

provider "aws" {
    region = "us-east-1"
    access_key = "AKIAZ7KA4IYALNMSEBVD"
    secret_key = "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"
}


resource "aws_s3_bucket" "sourcefuse_bucket" {
  bucket = "sourcefuses3"  
  tags = {
    Name = "sourcefuses3"
    Environment = "accessment"
  }
}

resource "aws_iam_policy" "s3-policy" {
  name        = "S3-Policy"
  description = "S3 Policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:*"],
        Effect   = "Allow",
        "Resource": [
 	       "arn:aws:s3:::sourcefuses3",
          "arn:aws:s3:::sourcefuses3/*"
       ]
      }
    ]
  })
}

resource "aws_iam_role" "ecs-role" {
	name = "ECS-Role"
  	assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Principal: {
                Service: "ecs-tasks.amazonaws.com"
            },
            Action: "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_policy_attachment" "role-policy-attachment1" {
  name = "ECS-Role"
  policy_arn = aws_iam_policy.s3-policy.arn
  roles      = [aws_iam_role.ecs-role.name]
}


resource "aws_iam_policy" "task-policy" {
  name        = "Task-Policy"
  description = "Task Policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
            Effect: "Allow",
            Action: [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            Resource: "*"
        }
    ]
  })
}

resource "aws_iam_role" "task-role" {
	name = "Task-Role"
  	assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Principal: {
                Service: "ecs-tasks.amazonaws.com"
            },
            Action: "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_policy_attachment" "role-policy-attachment2" {
  name = "Task-Role"
  policy_arn = aws_iam_policy.task-policy.arn
  roles      = [aws_iam_role.task-role.name]
}

# Define the AWS VPC
resource "aws_vpc" "sourcefuse_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a","us-east-1b"]
}


resource "aws_subnet" "public_subnets" {
 count             = length(var.public_subnet_cidrs)
 vpc_id            = aws_vpc.sourcefuse_vpc.id
 cidr_block        = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}

resource "aws_subnet" "private_subnets" {
 count             = length(var.private_subnet_cidrs)
 vpc_id            = aws_vpc.sourcefuse_vpc.id
 cidr_block        = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sourcefuse_vpc.id
}

# Retrieve the main route table associated with the VPC
data "aws_route_table" "route_table" {
  vpc_id = aws_vpc.sourcefuse_vpc.id
}

# Add Internet Gateway to the Default Route Table
resource "aws_route" "default_route" {
  route_table_id         = data.aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0" # This is the default route for the Internet
  gateway_id             = aws_internet_gateway.igw.id
}


# Create a Security Group for your ALB service
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "ALB security group"
  vpc_id      = aws_vpc.sourcefuse_vpc.id

  # Define your security group rules here if needed
   ingress {
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   description = "Any"
	 }
	
	 egress {
	   from_port   = 0
	   to_port     = 0
	   protocol    = "-1"
	   cidr_blocks = ["0.0.0.0/0"]
	 }
}

# Create a Security Group for your ECS service
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "ECS security group"
  vpc_id      = aws_vpc.sourcefuse_vpc.id

  # Define your security group rules here if needed
   ingress {
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   security_groups = [aws_security_group.alb_sg.id]
   description = "From ALB"
	 }
	
	 egress {
	   from_port   = 0
	   to_port     = 0
	   protocol    = "-1"
	   cidr_blocks = ["0.0.0.0/0"]
	 }
}


# Define the ECS Cluster for Fargate
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-nginx"
}


# Define the ECS Task Definition for Fargate
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "ecs-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory = 3072
  cpu    = 1024
  execution_role_arn       = aws_iam_role.task-role.arn
  task_role_arn            = aws_iam_role.ecs-role.arn

  container_definitions = jsonencode([
    {
      name  = "nginx-container"
      image = "public.ecr.aws/nginx/nginx:stable-perl"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol =  "tcp"
          appProtocol = "http"
        }
      ]
    }
  ])
}


# Define the ECS Service using the Fargate Task Definition and ALB
resource "aws_ecs_service" "ecs-service-nginx" {
  name            = "ecs-service-nginx"
  cluster         = aws_ecs_cluster.ecs_cluster.id  
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  scheduling_strategy = "REPLICA"

  network_configuration {
    subnets = aws_subnet.private_subnets[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
    container_name   = "nginx-container"
    container_port   = 80
  }

}


# Define the Application Load Balancer
resource "aws_lb" "ecs-alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnets[*].id
  enable_deletion_protection = false
  security_groups    = [aws_security_group.alb_sg.id]
}


# Define a target group for the ALB
resource "aws_lb_target_group" "ecs-alb-tg" {
  name        = "nginx-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.sourcefuse_vpc.id
}

# Create an ALB listener
resource "aws_lb_listener" "ecs-alb-listener" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = 80
  protocol          = "HTTP"

 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
  }
}

# Define an output for the ALB DNS name
output "alb_dns_name" {
	value = "Try after 5 mins - The URL for ALB is: http://${aws_lb.ecs-alb.dns_name}"
}

