resource "aws_lb" "alb" {
  name               = "k8s-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

resource "aws_lb_target_group" "k8s_workers" {
  name = "k8s-workers-tg"
  # NodePort that will be configured for Nginx Ingress Controller
  port     = 32080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/healthz" # Standard health check endpoint for Ingress
    protocol            = "HTTP"
    matcher             = "200-399,404" # Ingress often returns 404 on root if no ingress is configured, which still means it's up.
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "workers" {
  count            = 2
  target_group_arn = aws_lb_target_group.k8s_workers.arn
  target_id        = aws_instance.worker[count.index].id
  port             = 32080
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_workers.arn
  }
}