data "aws_ami" "stack_ami" {
  owners      = ["self"]
  name_regex  = "^ami-stack*"
  most_recent = true

  filter {
    name   = "name"
    values = ["ami-stack-*"]
  }
}

# pulling baked AMI for mysql into a data source
data "aws_ami" "mysql_ami" {
  owners      = ["self"]
  name_regex  = "^mySQL_DB_AM*"
  most_recent = true

  filter {
    name   = "name"
    values = ["mySQL_DB_AM*"]
  }
}

# optimized AMI for ECS deployment
data "aws_ami" "ecs-optimized" {
  owners      = ["679593333241"]
  name_regex  = "^Amazon ECS-Optimized Amazon Linux 2 AMI*"
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# pulling stores secrets from AWS Secret Manager into data source
data "aws_secretsmanager_secret_version" "creds" {
  # fill in the name you gave the secret
  secret_id = "creds"
}

# pulling route53 address into data source
data "aws_route53_zone" "stack_isaac_zone" {
  name         = "stack-isaac.com." # Notice the dot!!!
  private_zone = false
}

# pulling specific Elastic Public IP into data source 
data "aws_eip" "my_instance_eip" {
  public_ip = "34.203.95.105"
}