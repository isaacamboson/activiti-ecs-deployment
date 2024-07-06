locals {
  PublicPrefix      = "Public"
  PrivatePrefix     = "Private"
  ApplicationPrefix = "activiti"

  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

# route53 for activiti application
resource "aws_route53_record" "activiti_route53" {
  zone_id = data.aws_route53_zone.stack_isaac_zone.id
  name    = "dev.activiti"
  type    = "A"
  # ttl     = 5

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_lb.lb]
}

