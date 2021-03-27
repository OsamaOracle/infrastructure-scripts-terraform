data "aws_route53_zone" "public" {
  name         = var.dns_zone
  private_zone = false
}

resource "aws_route53_record" "this" {
  count   = var.instance_count
  zone_id = data.aws_route53_zone.public.zone_id
  name    = lookup(aws_instance.this.*.tags[count.index], "Name", aws_instance.this.*.id[count.index])
  type    = "A"
  ttl     = 300
  records = [element(aws_instance.this, count.index).private_ip]
}
