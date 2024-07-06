# security group creation and attaching in ecs, lb etc

# LB Security Group: Edit to restrict access to the application
resource "aws_security_group" "lb-sg" {
  name        = "${local.ApplicationPrefix}-lb-security-group"
  description = "controls access to the LB"
  vpc_id      = aws_vpc.vpc_main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all egress traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.ApplicationPrefix}-alb-sg"
  }
}

# this security group for ecs - Traffic to the ECS cluster should only come from the LB
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-tasks-security-group"
  description = "allow inbound access from the LB only for EC2 in cluster"
  vpc_id      = aws_vpc.vpc_main.id

  ingress {
    description     = "Allow ingress traffic from ALB on HTTP port 80"
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb-sg.id, aws_security_group.bastion-sg.id]
  }

  ingress {
    description     = "Allow ingress traffic from ALB on HTTPS port 443"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.lb-sg.id, aws_security_group.bastion-sg.id]
  }

  ingress {
    description     = "Allow ingress traffic from ALB on port 8080"
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.lb-sg.id, aws_security_group.bastion-sg.id]
  }

  ingress {
    description     = "Allow ingress traffic from ALB on HTTP on ephemeral ports"
    protocol        = "tcp"
    from_port       = 1024
    to_port         = 65535
    security_groups = [aws_security_group.lb-sg.id, aws_security_group.bastion-sg.id]
  }

  ingress {
    description     = "Allow SSH ingress traffic from bastion host"
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.lb-sg.id, aws_security_group.bastion-sg.id]
  }

  ingress {
    description     = "Allow icmp ingress traffic from bastion host"
    protocol        = "icmp"
    from_port       = -1
    to_port         = -1
    security_groups = [aws_security_group.lb-sg.id, aws_security_group.bastion-sg.id]
  }

  egress {
    description = "Allow all egress traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#creating security group for bastion - this allows traffic from 0.0.0.0/0
resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Bastion host Security Group"
  vpc_id      = aws_vpc.vpc_main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ## The IP range could be limited to the developers IP addresses if they are fix
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ## The IP range could be limited to the developers IP addresses if they are fix
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ## The IP range could be limited to the developers IP addresses if they are fix
  }

  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] ## The IP range could be limited to the developers IP addresses if they are fix
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

