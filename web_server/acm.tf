# resource "aws_acm_certificate" "cert" {
#   domain_name       = "chriscomcastcode.com"
#   validation_method = "DNS"
#   subject_alternative_names = ["www.chriscomcastcode.com"]#
#   lifecycle {
#     create_before_destroy = true
#   }
# }