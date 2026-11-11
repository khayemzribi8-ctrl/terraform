resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_a.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = { Name = "k8s-bastion" }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private_a.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.k8s_master_sg.id]

  user_data = templatefile("${path.module}/userdata-master.sh", {
    kubeadm_token = local.kubeadm_token
  })

  root_block_device {
    encrypted   = true
    volume_size = 30
  }

  tags = { Name = "k8s-master" }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "worker" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = count.index % 2 == 0 ? aws_subnet.private_a.id : aws_subnet.private_b.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.k8s_worker_sg.id]

  user_data = templatefile("${path.module}/userdata-worker.sh", {
    kubeadm_token     = local.kubeadm_token
    master_private_ip = aws_instance.master.private_ip
  })

  root_block_device {
    encrypted   = true
    volume_size = 30
  }

  tags = { Name = "k8s-worker-${count.index + 1}" }

  lifecycle {
    ignore_changes = [ami]
  }
}