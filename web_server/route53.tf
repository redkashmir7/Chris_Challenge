resource "aws_route53_zone" "my_zone" {
  name = "chriscomcastcode.com"
}
#create 2 a type
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.my_zone.zone_id
  name    = "www.chriscomcastcode.com"
  type    = "A"

  alias {
    name                   = aws_lb.web_lb.dns_name
    zone_id                = aws_lb.web_lb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "non_www" {
  zone_id = aws_route53_zone.my_zone.zone_id
  name    = "chriscomcastcode.com"
  type    = "A"

  alias {
    name                   = aws_lb.web_lb.dns_name
    zone_id                = aws_lb.web_lb.zone_id
    evaluate_target_health = false
  }
}