
sudo apt-get update 
sudo snap install microk8s --classic --channel=1.33
sudo usermod -a -G microk8s $USER
mkdir -p ~/.kube
chmod 0700 ~/.kube
microk8s status --wait-ready


microk8s enable rbac
sudo snap install kubectl --classic
microk8s config > .kube/config
kubectl get nodes
kubectl create ns example-dev
kubectl create ns example-prod
kubectl run nginx-dev --image=nginx --restart=Always -n example-dev
kubectl run nginx-dev --image=nginx --restart=Always -n example-prod
kubectl apply -f clusterrole.yaml
