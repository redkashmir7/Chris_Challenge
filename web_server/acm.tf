resource "aws_acm_certificate" "cert" {
  private_key      = file("${path.module}/privkey.pem")
  certificate_body = file("${path.module}/fullchain.pem")

}