data "aws_route53_zone" "primary" {
  name         = var.dns_zone
  private_zone = false
}

resource "aws_route53_record" "service" {
  count   = length(var.services)
  name    = element(var.services.*.name, count.index)
  zone_id = data.aws_route53_zone.primary.zone_id
  type    = "A"
  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = false
  }
}

