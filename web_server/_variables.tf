#general
variable "aws_region" {
  description = "The AWS region to use."
  type        = string
  default     = "us-east-1"
}

#alb.tf
variable "tg_health_check_threshold" {
  description = "The threshold for healthy and unhealthy checks."
  type        = number
  default     = 3
}

variable "tg_health_check_timeout" {
  description = "The timeout for health checks."
  type        = number
  default     = 5
}

variable "tg_cookie_duration" {
  description = "The duration of the stickiness cookie."
  type        = number
  default     = 1800
}

variable "tg_health_check_interval" {
  description = "The interval for health checks."
  type        = number
  default     = 30
}

#asg.tf
variable "user_data_script" {
  description = "User data script for instance initialization."
  type        = string
  default     = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apache2
    sudo systemctl enable apache2
    sudo systemctl start apache2

    # Generate a self-signed certificate
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj "/CN=localhost"

    # Enable SSL
    sudo a2enmod ssl
    sudo a2enmod rewrite

    # Create a basic HTML file
    echo '<html><head><title>Hello World</title></head><body><h1>Hello World!</h1></body></html>' | sudo tee /var/www/html/index.html

    # Configure a VirtualHost to use SSL and redirect HTTP to HTTPS
    sudo bash -c 'cat > /etc/apache2/sites-available/000-default.conf << EOL
    <VirtualHost *:80>
      ServerName localhost
      RewriteEngine On
      RewriteCond $${HTTPS}$$ off
      RewriteRule (.*) https://$${HTTP_HOST}$${REQUEST_URI}
    </VirtualHost>

    <VirtualHost *:443>
      ServerName localhost
      DocumentRoot /var/www/html

      SSLEngine on
      SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
      SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    </VirtualHost>
    EOL'

    # Enable the configuration and restart Apache
    sudo a2ensite 000-default.conf
    sudo systemctl restart apache2
  EOF
}

variable "asg_min_size" {
  description = "The minimum number of instances in the autoscaling group."
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "The desired number of instances in the autoscaling group."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "The maximum number of instances in the autoscaling group."
  type        = number
  default     = 5
}

variable "asg_policy_target_value" {
  description = "The target value for the autoscaling policy."
  type        = number
  default     = 50.0
}

#vpc

variable "all_traffic" {
  description = "Allows for full range of traffic to access"
  type        = string
  default     = "0.0.0.0/0"
}