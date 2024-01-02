sudo firewall-cmd --permanent --zone=trusted --add-port=6443/tcp --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --zone=trusted --add-port=10251/tcp
sudo firewall-cmd --permanent --zone=trusted --add-port=10252/tcp
sudo firewall-cmd --permanent --zone=trusted --add-port=10250/tcp
sudo firewall-cmd --permanent --zone=trusted --add-port=30000-32767/tcp
sudo firewall-cmd --permanent --zone=trusted --add-port=80/tcp
sudo firewall-cmd --permanent --zone=trusted --add-port=443/tcp
sudo firewall-cmd --permanent --zone=trusted --add-port=22/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
sudo modprobe overlay
sudo modprobe br_netfilter
sudo cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
sudo apt update
sudo apt install containerd
sudo mkdir  -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key
sudo echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
#apt-cache policy kubelet | head -n 20
#VERSION=$(apt-cache policy kubelet | head -n 7 | tail -n 1 | cut -d' ' -f 6)
#apt install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl containerd
sudo systemctl enable --now containerd kubelet
sudo kubeadm init --ignore-preflight-errors=all


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl get nodes
kubectl get pods -A
