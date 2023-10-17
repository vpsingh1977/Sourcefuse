resource "aws_launch_template" "ecs_lt" {
 name_prefix   = "ecs-launch-template"
 image_id      = "ami-061ac2e015473fbe2"
 instance_type = "t3.micro"

 key_name               = "ec2ecsglog"
 vpc_security_group_ids = [aws_security_group.ecs_security_group.id]
 iam_instance_profile {
   name = var.ECS_INSTANCE_ROLE
 }
 
 # root disk
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp3"
    delete_on_termination = true
  }
  # data disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "20"
    volume_type           = "gp3"
    delete_on_termination = true
  }
 
 
 tags = {
         "Environment" = var.ENVIRONMENT
         "ProjectID"  = var.PROJECT_ID
         "Resource Function" = "ECS Server"
     } 

 
}