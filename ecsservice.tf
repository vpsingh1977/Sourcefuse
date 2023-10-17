resource "aws_ecs_service" "ecs_service" {
 name            = "sourcefuse-ecs-service"
 cluster         = aws_ecs_cluster.ecs_cluster.id
 task_definition = aws_ecs_task_definition.ecs_task_definition.arn
 desired_count   = 2

 network_configuration {
   subnets         = [aws_subnet.private-subnet-az-a.id, aws_subnet.private-subnet-az-b.id]
   security_groups = [aws_security_group.ecs_security_group_service.id]
 }

 load_balancer {
   target_group_arn = aws_lb_target_group.ecs_tg.arn
   container_name   = "nginx"
   container_port   = 80
 }

 depends_on = [aws_autoscaling_group.ecs_asg]
}