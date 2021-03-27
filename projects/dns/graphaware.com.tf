resource "aws_route53_zone" "osamaoracle_com" {
  name = "osamaoracle.com"
}

resource "aws_route53_record" "osamaoracle_com__mx" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = ""
  type    = "MX"
  ttl     = "300"

  records = [
    "10 aspmx.l.google.com",
    "20 alt1.aspmx.l.google.com",
    "20 alt2.aspmx.l.google.com",
    "30 aspmx2.googlemail.com",
    "30 aspmx3.googlemail.com",
    "30 aspmx4.googlemail.com",
    "30 aspmx5.googlemail.com",
  ]
}

resource "aws_route53_record" "aws__osamaoracle_com__ns" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "aws"
  type    = "NS"
  ttl     = "300"

  records = [
    "ns-1296.awsdns-34.org",
    "ns-1636.awsdns-12.co.uk",
    "ns-487.awsdns-60.com",
    "ns-916.awsdns-50.net",
  ]
}

resource "aws_route53_record" "az__osamaoracle_com__ns" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "az"
  type    = "NS"
  ttl     = "300"

  records = [
    "ns1-02.azure-dns.com",
    "ns2-02.azure-dns.net",
    "ns3-02.azure-dns.org",
    "ns4-02.azure-dns.info",
  ]
}

resource "aws_route53_record" "demo__osamaoracle_com__ns" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "demo"
  type    = "NS"
  ttl     = "300"

  records = [
    "ns-1165.awsdns-17.org",
    "ns-1967.awsdns-53.co.uk",
    "ns-497.awsdns-62.com",
    "ns-858.awsdns-43.net",
  ]
}

resource "aws_route53_record" "_domainkey__osamaoracle_com__ns" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "_domainkey"
  type    = "NS"
  ttl     = "300"

  records = [
    "ns-1473.awsdns-56.org",
    "ns-1859.awsdns-40.co.uk",
    "ns-491.awsdns-61.com",
    "ns-956.awsdns-55.net",
  ]
}

resource "aws_route53_record" "services__osamaoracle_com__ns" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "services"
  type    = "NS"
  ttl     = "300"

  records = [
    "ns-1505.awsdns-60.org",
    "ns-1664.awsdns-16.co.uk",
    "ns-355.awsdns-44.com",
    "ns-635.awsdns-15.net",
  ]
}

resource "aws_route53_record" "osamaoracle_com__txt" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "300"

  records = [
    "google-site-verification=DH1LuW33uudwkfOdtYBcDYp7IEmaWcnPzRlPh45v2FY",
    "MS=ms72834453",
  ]
}

resource "aws_route53_record" "_amazonses__osamaoracle_com__txt" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "_amazonses"
  type    = "TXT"
  ttl     = "300"

  records = [
    "OVckarwOqbMRKpQoEFJLOJtCZ3/aCdge2+RZmvL6hJg=",
  ]
}

resource "aws_route53_record" "__afp_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "*.afp.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "23.97.189.40",
  ]
}

resource "aws_route53_record" "afp_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "afp.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "23.97.189.40",
  ]
}

resource "aws_route53_record" "__corona_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "*.corona.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "23.101.77.228",
  ]
}

resource "aws_route53_record" "corona_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "corona.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "23.101.77.228",
  ]
}

resource "aws_route53_record" "__covid19_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "*.covid19.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "51.136.34.175",
  ]
}

resource "aws_route53_record" "covid19_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "covid19.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "51.136.34.175",
  ]
}

resource "aws_route53_record" "ftp_satis__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "ftp.satis"
  type    = "A"
  ttl     = "300"
  records = [
    "208.113.221.41",
  ]
}

resource "aws_route53_record" "__fujitsu_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "*.fujitsu.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "104.214.223.135",
  ]
}

resource "aws_route53_record" "fujitsu_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "fujitsu.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "104.214.223.135",
  ]
}

resource "aws_route53_record" "graphgen__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "graphgen"
  type    = "A"
  ttl     = "300"
  records = [
    "176.34.95.57",
  ]
}

resource "aws_route53_record" "graphlytic__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "graphlytic"
  type    = "A"
  ttl     = "300"
  records = [
    "52.50.109.82",
  ]
}

resource "aws_route53_record" "__php__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "*.php"
  type    = "A"
  ttl     = "300"
  records = [
    "176.34.95.57",
  ]
}

resource "aws_route53_record" "satis__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "satis"
  type    = "A"
  ttl     = "300"
  records = [
    "208.113.221.41",
  ]
}

resource "aws_route53_record" "ssh_satis__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "ssh.satis"
  type    = "A"
  ttl     = "300"
  records = [
    "208.113.221.41",
  ]
}

resource "aws_route53_record" "__staging__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "*.staging"
  type    = "A"
  ttl     = "300"
  records = [
    "176.34.95.57",
  ]
}

resource "aws_route53_record" "staging__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "staging"
  type    = "A"
  ttl     = "300"
  records = [
    "176.34.95.57",
  ]
}

resource "aws_route53_record" "__stats__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "*.stats"
  type    = "A"
  ttl     = "300"
  records = [
    "176.34.95.57",
  ]
}

resource "aws_route53_record" "__testgame_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "*.testgame.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "51.144.246.46",
  ]
}

resource "aws_route53_record" "testgame_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "testgame.hume"
  type    = "A"
  ttl     = "300"
  records = [
    "51.144.246.46",
  ]
}

resource "aws_route53_record" "www_satis__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "www.satis"
  type    = "A"
  ttl     = "300"
  records = [
    "208.113.221.41",
  ]
}


resource "aws_route53_record" "ato_hume__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "ato.hume"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "corona.hume.osamaoracle.com",
  ]
}

resource "aws_route53_record" "calendar__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "calendar"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "ghs.googlehosted.com",
  ]
}

resource "aws_route53_record" "docs__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "docs"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "ghs.googlehosted.com",
  ]
}

resource "aws_route53_record" "login__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "login"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "dev-q3hrvyvr-cd-5yz60sk7ugeyvqpo.edge.tenants.eu.auth0.com",
  ]
}

resource "aws_route53_record" "mail__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "mail"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "ghs.googlehosted.com",
  ]
}

resource "aws_route53_record" "sites__osamaoracle_com" {
  zone_id = aws_route53_zone.osamaoracle_com.zone_id
  name    = "sites"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "ghs.googlehosted.com",
  ]
}
