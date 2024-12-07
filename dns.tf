resource "aws_route53_zone" "example" {
  name = "markoprimer.com"
}
# A zapis za c2 redirector #1
resource "aws_route53_record" "c2-http-rdr-a1" {
  zone_id = aws_route53_zone.example.id
  name    = "${var.sub1}.${var.domain_rdir}"
  type    = "A"
  ttl     = 6020
  records = [aws_instance.c2_server.public_ip]
}

# A zapis za c2 redirector #2
resource "aws_route53_record" "c2-http-rdr-a2" {
  zone_id = aws_route53_zone.example.id
  name    = "${var.sub2}.${var.domain_rdir}"
  type    = "A"
  ttl     = 6020
  records = [aws_instance.c2_server_redirector.public_ip]
}

# A zapis za c2 http #1
resource "aws_route53_record" "c2-http-a1" {
  zone_id = aws_route53_zone.example.id
  name    = "${var.sub3}.${var.domain_c2}"
  type    = "A"
  ttl     = 6020
  records = [aws_instance.c2_server.public_ip]
}

# A zapis za c2 http #2
resource "aws_route53_record" "c2-http-a2" {
  zone_id = aws_route53_zone.example.id
  name    = "${var.sub4}.${var.domain_c2}"
  type    = "A"
  ttl     = 6020
  records = [aws_instance.c2_server.public_ip]
}

# A zapis za phishing redirector #1
resource "aws_route53_record" "phishing-rdr-a0" {
  zone_id = aws_route53_zone.example.id
  name    = "${var.domain_rdir}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.phishing_server_redirector.public_ip]
}

# A zapis za phishing redirector #2
resource "aws_route53_record" "phishing-rdr-a1" {
  zone_id = aws_route53_zone.example.id
  name    = "${var.sub6}.${var.domain_rdir}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.phishing_server_redirector.public_ip]
}

# A zapis za mail relay
resource "aws_route53_record" "phishing-rdr-mail-a1" {
  zone_id = aws_route53_zone.example.id
  name    = "mail.${var.domain_rdir}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.phishing_server_redirector.public_ip]
}

# MX zapis za mail relay
resource "aws_route53_record" "phishing-rdr-mail-mx" {
  zone_id = aws_route53_zone.example.id
  name    = "${var.domain_rdir}"
  type    = "MX"
  ttl     = 60
  records = ["10 mail.${var.domain_rdir}."]
}

# TXT zapis za SPF
resource "aws_route53_record" "phishing-rdr-mail-spf" {
  zone_id = aws_route53_zone.example.id
  name    = "${var.domain_rdir}"
  type    = "TXT"
  ttl     = 60
  records = ["v=spf1 ip4:${aws_instance.phishing_server_redirector.public_ip} include:_spf.google.com ~all"]
}

# TXT zapis za DKIM placeholder
resource "aws_route53_record" "phishing-rdr-mail-dkim" {
  zone_id = aws_route53_zone.example.id
  name    = "mail._domainkey.${var.domain_rdir}"
  type    = "TXT"
  ttl     = 60
  records = ["I am DKIM, but change me with the DKIM provided by finalize.sh"]
}

# TXT zapis za DMARC
resource "aws_route53_record" "phishing-rdr-mail-dmarc" {
  zone_id = aws_route53_zone.example.id
  name    = "_dmarc.${var.domain_rdir}"
  type    = "TXT"
  ttl     = 60
  records = ["v=DMARC1; p=reject"]
}

# A zapis za phishing server
resource "aws_route53_record" "phishing-a1" {
  zone_id = aws_route53_zone.example.id
  name    = "${var.sub6}.${var.domain_c2}"
  type    = "A"
  ttl     = 120
  records = [aws_instance.phishing.public_ip]
}
