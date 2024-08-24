resource "aws_ecs_cluster" "ecs_cluster" {
 count = var.enable_ecs_cluster ? 1 : 0
 name = var.ecs_cluster_name
}


resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
 name = "${var.ecs_cluster_name}_ecs_capacity_provider"
 auto_scaling_group_provider {
   auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

   managed_scaling {
     maximum_scaling_step_size = 5
     minimum_scaling_step_size = 1
     status                    = "ENABLED"
     target_capacity           = 3
   }
 }
}


resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster[0].name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

 default_capacity_provider_strategy {
   base              = 1
   weight            = 100
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
 }
 depends_on = [ aws_ecs_cluster.ecs_cluster ]
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
 family             = "my-ecs-task"
 network_mode       = "awsvpc"
 execution_role_arn = "arn:aws:iam::401704305923:role/ecsTaskExecutionRole"
 cpu                = 256
 runtime_platform {
   operating_system_family = "LINUX"
   cpu_architecture        = "X86_64"
 }
 
 container_definitions = jsonencode([
   {
     name      = "dockergs"
     image     = "401704305923.dkr.ecr.ap-south-1.amazonaws.com/sample-node:latest"
     cpu       = 256
     memory    = 512
     essential = true
     portMappings = [
       {
         containerPort = 3000
         hostPort      = 3000
         protocol      = "tcp"
       }
     ]
   }
 ])
}