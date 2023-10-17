resource "aws_autoscaling_group" "ecs_asg" {
 vpc_zone_identifier = [aws_subnet.private-subnet-az-a.id, aws_subnet.private-subnet-az-b.id]
 desired_capacity    = 2
 max_size            = 4
 min_size            = 2

 launch_template {
   id      = aws_launch_template.ecs_lt.id
}

 tags = {
         "Environment" = var.ENVIRONMENT
         "ProjectID"  = var.PROJECT_ID
         "Resource Function" = "ECS ASG"
     } 


}