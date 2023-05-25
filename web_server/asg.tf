resource "aws_launch_configuration" "asg_config" {
  name          = "asg_config"
  image_id      = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"

  security_groups = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apache2
    sudo systemctl restart apache2
    echo '<html>
    <head>
    <title>Hello World</title>
    </head>
    <body>
    <h1>Hello World!</h1>
    </body>
    </html>' | sudo tee /var/www/html/index.html

    # Enable SSL module and configure for HTTPS
    sudo a2enmod ssl
  
    echo '
    <VirtualHost *:443>
      ServerName www.chriscomcastcode.com
      DocumentRoot /var/www/html

      SSLEngine on
      SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
      SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    </VirtualHost>

    <VirtualHost *:443>
      ServerName chriscomcastcode.com
      DocumentRoot /var/www/html

      SSLEngine on
      SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
      SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    </VirtualHost>
    ' | sudo tee /etc/apache2/sites-available/chriscomcastcode.conf

    # Enable the SSL virtual hosts
    sudo a2ensite chriscomcastcode.conf

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

resource "aws_autoscaling_policy" "scale_up" {
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
