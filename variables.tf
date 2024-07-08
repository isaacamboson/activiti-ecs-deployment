variable "AWS_REGION" {
  default     = "us-east-1"
  description = "AWS region where our resources are going to be deployed"
}

variable "ecs_task_execution_role" {
  default     = "myECSTaskExecutionRole"
  description = "ECS task execution role name"
}

variable "app_image" {
  default     = "767398027423.dkr.ecr.us-east-1.amazonaws.com/activiti-repo:latest"
  description = "docker image to run in this ECS cluster"
}

variable "availability_zone" {
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "app_port" {
  default     = "8080"
  description = "portexposed on the docker image"
}

variable "health_check_path" {
  default = "/"
}

variable "ec2_cpu" {
  default     = "10"
  description = "ec2 instance CPU units to provision, my requirement 1 vcpu so gave 1024"
}

variable "ec2_memory" {
  default     = "512"
  description = "ec2 instance memory to provision (in MiB) not MB"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.2.0/23", # 510 hosts   - bastion, load balancer
    "10.0.4.0/23"  # 510 hosts   - bastion, load balancer
  ]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.18.0/26", # 62 hosts    - deployment of MySQL DB for Java App
    "10.0.20.0/26", # 62 hosts    - deployment of MySQL DB for Java App 
    "10.0.19.0/26", # 62 hosts    - deployment of Java App 
    "10.0.21.0/26"  # 62 hosts    - deployment of Java App
  ]
}

variable "environment" {
  default = "dev"
}

variable "OwnerEmail" {
  default = "isaacamboson@gmail.com"
}

variable "device_names" {
  default = ["/dev/sdb", "/dev/sdc", "/dev/sdd", "/dev/sde", "/dev/sdf"]
}

#controls / conditionals
variable "stack_controls" {
  type = map(string)
  default = {
    ec2_create = "Y"
  }
}

#components for EC2 instances
variable "EC2_Components" {
  type = map(string)
  default = {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = "true"
    instance_type         = "t2.medium"
  }
}

