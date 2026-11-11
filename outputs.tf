output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "IP address to connect to Bastion Host via SSH"
}

output "master_private_ip" {
  value       = aws_instance.master.private_ip
  description = "Private IP address of the Master Node (for kubeadm join debugging)"
}

output "worker_private_ips" {
  value       = aws_instance.worker[*].private_ip
  description = "Private IPs of the Worker Nodes"
}

output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "The URL of the Application Load Balancer serving the e-commerce Symfony site."
}