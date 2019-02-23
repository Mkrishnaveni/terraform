resource "aws_instance" "httpd" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = "${aws_subnet.public_subnet.id}"
  associate_public_ip_address = true

  tags {
    Name        = "httpd-instance"
    }
user_data = <<HEREDOC
  #!/bin/bash
  yum update -y
  yum install -y httpd
  service httpd start
HEREDOC

}
resource "aws_security_group" "elb" {
  name        = "elb_sg"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.vpc.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_elb" "httpd" {
  name = "httpd-elb"

  # The same availability zone as our instance
  subnets = ["${aws_subnet.public_subnet.id}"]

  security_groups = ["${aws_security_group.elb.id}"]

  listener {
   instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
   healthy_threshold   = 2
   unhealthy_threshold = 2
   timeout             = 3
   target              = "HTTP:80/"
   interval            = 30
  }

  instances                   = ["${aws_instance.httpd.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

resource "aws_lb_cookie_stickiness_policy" "default" {
  name                     = "lbpolicy"
  load_balancer            = "${aws_elb.httpd.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

