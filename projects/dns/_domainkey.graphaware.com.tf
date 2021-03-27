data "aws_route53_zone" "_domainkey_osamaoracle_com" {
  name         = "_domainkey.osamaoracle.com"
  private_zone = false
}

resource "aws_route53_record" "osamaoracle_com__dkim__txt" {
  zone_id = data.aws_route53_zone._domainkey_osamaoracle_com.zone_id
  name    = "google"
  type    = "TXT"
  ttl     = "300"

  records = [
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAva1tN9rOC5a/8WaAM7vqkrJynJD5yCXZIhAYQv6f4N4l/PamxrLBaDzLu6/Ub+pDdpBudd+N0R2A/Ho6SO0YNTry2oXoy0rvb9OwHZ2GKsYEBXc5F2x2C3u8eyB+1kJJnbeuGrap6BU0vpE4mnyJH6WkTqJZVugKTQYvBe8hdcDf2GGAgM6CKR0ktt/bjBMw\"\"LPsT8Mt9qQG6l0AWsV38K3DIVkSSgDVPY1WzNvmRaCFkGLFVdjURtgasnin4vzan6kEAoubVreoi9l9yzSMimRosEtvCifgJptWPE/9wvTgrEloOhO75oRlHyQYEMjLDOK4+bzxKCjUxgVvhCP8EjQIDAQAB",
  ]
}

resource "aws_route53_record" "hubspotemail1__domainkey_osamaoracle_com" {
  zone_id = data.aws_route53_zone._domainkey_osamaoracle_com.zone_id
  name    = "hs1-8709349"
  type    = "CNAME"
  ttl     = "300"

  records = [
    "osamaoracle-com.hs17a.dkim.hubspotemail.net",
  ]
}

resource "aws_route53_record" "hubspotemail2__domainkey_osamaoracle_com" {
  zone_id = data.aws_route53_zone._domainkey_osamaoracle_com.zone_id
  name    = "hs2-8709349"
  type    = "CNAME"
  ttl     = "300"

  records = [
    "osamaoracle-com.hs17b.dkim.hubspotemail.net",
  ]
}
