resource "aws_launch_configuration" "asg_config" {
  name          = "asg_config"
  image_id      = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"

  security_groups = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
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


  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.asg_config.name
  min_size             = 1
  desired_capacity     = 2
  max_size             = 5
  vpc_zone_identifier  = aws_subnet.public.*.id
  target_group_arns    = [aws_lb_target_group.web_tg.arn]

  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asg_policy" {
  name                   = "scale-up"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
