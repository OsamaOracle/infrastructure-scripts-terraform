# This data source looks up the public DNS zone
data "aws_route53_zone" "public" {
  name         = "aws.osamaoracle.com"
  private_zone = false
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "jumpbox.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.this.public_ip]
}
