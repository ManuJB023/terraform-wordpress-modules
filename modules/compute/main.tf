data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb"
  })
}

resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
  enabled             = true
  healthy_threshold   = 2
  interval            = 30
  matcher             = "200"
  path                = "/health.php"  # Change from "/"
  port                = "traffic-port"
  protocol            = "HTTP"
  timeout             = 5
  unhealthy_threshold = 2
}

  tags = merge(var.tags, {
    Name = "${var.project_name}-tg"
  })
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.project_name}-instance"
    })
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}