#! /bin/bash -x

# Installing minikube @debian based linux https://kubernetes.io/fr/docs/tasks/tools/install-minikube/
curl -LOs https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

# Installing kubectl CLI somewhere in $PATH https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/
KUBECTL="$HOME/bin/kubectl"
STABLE_VERS=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -s https://storage.googleapis.com/kubernetes-release/release/$STABLE_VERS/bin/linux/amd64/kubectl -o "$KUBECTL"
chmod +x "$KUBECTL"
source <(kubectl completion bash)

# Starts a local Kubernetes cluster https://minikube.sigs.k8s.io/docs/commands/start/
minikube start --cpus 2 --memory 2048
#Requested memory allocation (1024MB) is less than the recommended minimum 1907MB. Deployments may fail.

wget https://raw.githubusercontent.com/kubernetes/website/master/content/fr/examples/minikube/server.js

wget https://raw.githubusercontent.com/kubernetes/website/master/content/fr/examples/minikube/Dockerfile

eval $(minikube docker-env)
docker build -t hello-node:v1 .
screen minikube dashboard
#CTRL-A D to detach
kubectl create deployment hello-node --image=hello-node:v1
kubectl get deployments.apps


kubectl expose deployment hello-node --type=LoadBalancer --port=8080
kubectl get services

kubectl logs -f -l app=hello-node --max-log-requests=8

curl $(minikube service hello-node --url)

kubectl scale deployment --replicas=4 hello-node

kubectl get deployments.apps
kubectl get pods


#modify your app
docker build -t hello-node:v2 .

#update the image of our Deployment/hell
kubectl set image deployment/hello-node hello-node=hello-node:v2



# Uninstall
kubectl delete service hello-node
kubectl delete deployment hello-node
minikube stop
minikube delete --all
sudo apt-get purge -yq minikube
