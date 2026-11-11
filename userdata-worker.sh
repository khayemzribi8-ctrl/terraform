#!/bin/bash
apt update -y
# netcat-openbsd used for checking master port
apt install -y containerd netcat-openbsd

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
modprobe br_netfilter
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

apt install -y apt-transport-https curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

apt update -y
apt install -y kubelet kubeadm
apt-mark hold kubelet kubeadm

# Wait for Master KubeAPI to be reachable
echo "Waiting for Master node API to be available on ${master_private_ip}..."
while ! nc -z ${master_private_ip} 6443; do
  sleep 10
done
echo "Master API is reachable! Joining..."

# Join cluster
kubeadm join ${master_private_ip}:6443 --token ${kubeadm_token} --discovery-token-unsafe-skip-ca-verification