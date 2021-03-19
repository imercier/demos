#! /bin/bash -x

# installing minikube @debian based linux https://kubernetes.io/fr/docs/tasks/tools/install-minikube/
curl -J -O 'https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb'
sudo dpkg -i minikube_latest_amd64.deb

# installing kubectl cli somewhere in $path https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/
kubectl="$home/bin/kubectl"
stable_vers=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -s https://storage.googleapis.com/kubernetes-release/release/$stable_vers/bin/linux/amd64/kubectl -o "$kubectl"
chmod +x "$kubectl"
source <(kubectl completion bash)

# starts a local kubernetes cluster https://minikube.sigs.k8s.io/docs/commands/start/
minikube start

# Deploy container image hello-app from google registry
# https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/blob/master/hello-app/main.go
kubectl create deployment helloweb --image=gcr.io/google-samples/hello-app:1.0

# Create a Service object that exposes the deployment
kubectl expose deployment helloweb --type=LoadBalancer --port 8080

# Test service
watch -c curl -s "$(minikube service helloweb --url)"


# Uninstall
minikube delete --all
sudo apt-get purge -yq minikube
