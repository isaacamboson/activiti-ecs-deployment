#-----------------------------------------------------------------------------
## Creates an ASG linked with our main VPC
#-----------------------------------------------------------------------------

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                      = "${local.ApplicationPrefix}_ASG_${var.environment}"
  desired_capacity          = 4
  max_size                  = 6
  min_size                  = 4
  health_check_grace_period = 30
  vpc_zone_identifier       = [aws_subnet.private_subnets[2].id, aws_subnet.private_subnets[3].id]
  health_check_type         = "EC2"
  target_group_arns         = [aws_lb_target_group.activiti-app-tg.arn]
  protect_from_scale_in = true

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.activiti-app-launch-temp1.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.ApplicationPrefix}_ASG_${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

#-----------------------------------------------------------------------------
#creating Launch Template for the autoscaling group instances
#-----------------------------------------------------------------------------

resource "aws_launch_template" "activiti-app-launch-temp1" {
  name                                 = "${local.ApplicationPrefix}-launch-temp"
  image_id                             = data.aws_ami.ecs-optimized.image_id #ECS Optimized
  instance_type                        = var.EC2_Components["instance_type"]
  key_name                             = "private-key-kp"
  user_data                            = base64encode(data.template_file.ecs_user_data.rendered)
  vpc_security_group_ids               = [aws_security_group.ecs_sg.id, aws_security_group.bastion-sg.id]
  instance_initiated_shutdown_behavior = "terminate"
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = false

  iam_instance_profile {
    name = "ecsInstanceRole"
  }

  monitoring {
    enabled = true
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  dynamic "block_device_mappings" {
    for_each = var.device_names
    content {
      device_name = block_device_mappings.value

      ebs {
        volume_size = 10
        volume_type = "gp2"
        encrypted   = true
      }
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  tags = {
    Name = "${local.ApplicationPrefix}_Instance"
  }
}

#-----------------------------------------------------------------------------
## Creates Capacity Provider linked with ASG and ECS Cluster
#-----------------------------------------------------------------------------

resource "aws_ecs_capacity_provider" "cas" {
  name = "${local.ApplicationPrefix}_ECS_CapacityProvider_${var.environment}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_autoscaling_group.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 4 #Maximum amount of EC2 instances that should be added on scale-out
      minimum_scaling_step_size = 1 #Minimum amount of EC2 instances that should be added on scale-out
      status                    = "ENABLED"
      target_capacity           = 100 #Amount of resources of container instances that should be used for task placement in %
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cas" {
  cluster_name       = aws_ecs_cluster.activiti-cluster.name
  capacity_providers = [aws_ecs_capacity_provider.cas.name]
}

#-----------------------------------------------------------------------------
## Define Target Tracking on ECS Cluster Task level
#-----------------------------------------------------------------------------
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10 #How many ECS tasks should maximally run in parallel
  min_capacity       = 2  #How many ECS tasks should minimally run in parallel
  resource_id        = "service/${aws_ecs_cluster.activiti-cluster.name}/${aws_ecs_service.activiti-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

## Policy for CPU tracking
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "${local.ApplicationPrefix}_CPUTargetTrackingScaling_${var.environment}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/${aws_ecs_cluster.activiti-cluster.name}/${aws_ecs_service.activiti-service.name}"
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70 #Target tracking for CPU usage in %

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

## Policy for memory tracking
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  name               = "${local.ApplicationPrefix}_MemoryTargetTrackingScaling_${var.environment}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 80 #Target tracking for memory usage in %

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

