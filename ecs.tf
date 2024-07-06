#creating the ECS cluster 
resource "aws_ecs_cluster" "activiti-cluster" {
  name = "${local.ApplicationPrefix}-app-cluster"

  tags = {
    Name = "${local.ApplicationPrefix}-app-cluster"
  }

  depends_on = [ aws_cloudwatch_log_group.log_group ]
}

#creating the ECS task definition
resource "aws_ecs_task_definition" "activiti-def" {
  family                   = "${local.ApplicationPrefix}-app-task-def"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_iam_role.arn
  requires_compatibilities = ["EC2"]
  container_definitions    = data.template_file.activiti-app.rendered

  tags = {
    Name = "${local.ApplicationPrefix}-app-container"
  }

  depends_on = [ aws_cloudwatch_log_group.log_group ]
}


#creating the ECS service
resource "aws_ecs_service" "activiti-service" {
  name                               = "${local.ApplicationPrefix}-app-service-1"
  iam_role                           = aws_iam_role.ecs_service_role.arn
  cluster                            = aws_ecs_cluster.activiti-cluster.id
  task_definition                    = aws_ecs_task_definition.activiti-def.arn
  desired_count                      = 4   #How many ECS tasks should run in parallel 
  deployment_minimum_healthy_percent = 100  #How many percent of a service must be running to still execute a safe deployment
  deployment_maximum_percent         = 200 #How many additional tasks are allowed to run (in percent) while a deployment is executed
  launch_type                        = "EC2"
  # scheduling_strategy = "REPLICA"

  force_new_deployment = true

  triggers = {
    redeployment = timestamp()
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.activiti-app-tg.arn
    #Name of the container to associate with the load balancer (as it appears in a container definition)
    container_name = "${local.ApplicationPrefix}-app-container"
    container_port = 8080
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  # Spread tasks evenly accross all Availability Zones for High Availability
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  # Make use of all available space on the Container Instances
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  # Do not update desired count again to avoid a reset to this number on every deployment
  # lifecycle {
  #   ignore_changes = [desired_count]
  # }

  depends_on = [
                aws_autoscaling_group.ecs_autoscaling_group, 
                aws_route_table_association.rt_association_private_subnets, 
                aws_iam_role.ecs_service_role,
                aws_launch_template.activiti-app-launch-temp1,
                aws_lb.lb,
                aws_cloudwatch_log_group.log_group
  ]
}


