
sudo apt-get update 
sudo snap install microk8s --classic --channel=1.33
sudo usermod -a -G microk8s $USER
mkdir -p ~/.kube
chmod 0700 ~/.kube
microk8s status --wait-ready


microk8s enable rbac
sudo snap install kubectl --classic
microk8s config > ~/.kube/config


k() {
    microk8s kubectl "$@"
}

k version
k get nodes
k create ns example-dev
k create ns example-prod
k run nginx-dev --image=nginx --restart=Always -n example-dev
k run nginx-dev --image=nginx --restart=Always -n example-prod
k apply -f clusterrole.yaml
