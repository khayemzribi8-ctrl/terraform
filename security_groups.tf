# Bastion SG
resource "aws_security_group" "bastion_sg" {
  name        = "k8s-bastion-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH from my IP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Master SG
resource "aws_security_group" "k8s_master_sg" {
  name        = "k8s-master-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Kubernetes Master node"

  # All inter-VPC traffic (Flannel, etcd, kubelet)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Worker SG
resource "aws_security_group" "k8s_worker_sg" {
  name        = "k8s-worker-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Kubernetes Worker nodes"

  # All inter-VPC traffic allowed
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB SG
resource "aws_security_group" "alb_sg" {
  name        = "k8s-alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Security group for the Application Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}