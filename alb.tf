#creating aws application loadbalancer, target group and lb http listener

resource "aws_lb" "lb" {
  name = "${local.ApplicationPrefix}-load-balancer"
  # subnets = [aws_subnet.pub_subnets[1].id]
  subnets                          = [aws_subnet.pub_subnets[0].id, aws_subnet.pub_subnets[1].id]
  security_groups                  = [aws_security_group.lb-sg.id]
  internal                         = false
  load_balancer_type               = "application"
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
}

#redirecting all incoming traffic from LB to the target group
resource "aws_lb_listener" "activiti-app" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.activiti-app-tg.arn
  }
}

resource "aws_lb_target_group" "activiti-app-tg" {
  name        = "${local.ApplicationPrefix}-app-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_main.id

  deregistration_delay = 300

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    interval            = 30
    matcher             = "200" #HTTP status code matcher for healthcheck
    path                = "/"   #Endpoint for ALB healthcheck
    port                = "traffic-port"
  }

  depends_on = [aws_lb.lb]
}


