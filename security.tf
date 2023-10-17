# Security Groups
resource "aws_security_group" "ecs_security_group" {
 name   = "alb-security-group"
 vpc_id = aws_vpc.sourcefuse-aws-vpc.id

 ingress {
   from_port   = 0
   to_port     = 0
   protocol    = -1
   cidr_blocks = ["0.0.0.0/0"]
   description = "any"
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


resource "aws_security_group" "ecs_security_group_service" {
 name   = "ecs-security-group"
 vpc_id = aws_vpc.sourcefuse-aws-vpc.id

 ingress {
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   security_groups = [aws_security_group.ecs_security_group.id]
   description = "From ALB"
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}