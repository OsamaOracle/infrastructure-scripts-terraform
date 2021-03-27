data "aws_route53_zone" "primary" {
  name         = var.dns_zone
  private_zone = false
}

resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.name
  type    = "A"
  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = false
  }
}

