# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${local.ApplicationPrefix}-log-group-ecs"
  retention_in_days = 30

  tags = {
    Name = "${local.ApplicationPrefix}-cw-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${local.ApplicationPrefix}-ecs-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}