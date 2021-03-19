#! /bin/bash -x

# Requirements: google account, google cloud platform billing account


# Install gcloud
curl -s https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir=/tmp
export PATH=$PATH:/tmp/google-cloud-sdk/bin/

# Setup and authentification
gcloud init

PROJECT_ID=test-gke-$USER-$RANDOM
gcloud projects create ${PROJECT_ID}

#Associate project to billing account
xdg-open https://console.cloud.google.com/billing/linkedaccount?project=${PROJECT_ID}&folder=&hl=fr&organizationId=
read

# Enable APIs
gcloud services enable containerregistry.googleapis.com --project ${PROJECT_ID}
gcloud services enable container.googleapis.com --project ${PROJECT_ID}


# Create cluster
gcloud container clusters create hellocluster --project ${PROJECT_ID} --num-nodes=1 --zone europe-west6-a

# Pull image and deploy it
kubectl create deployment hellocluster --image=gcr.io/google-samples/hello-app:1.0

# Create a loadbalancer service
kubectl expose deployment hellocluster --type=LoadBalancer --port 8080

# Wait loadbalancer ready to have public access
watch kubectl get services hellocluster

# Test it
curl -s "$(kubectl get svc hellocluster --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")":8080
read

# Cleaning
gcloud container clusters delete --quiet hellocluster --project ${PROJECT_ID} --zone europe-west6-a
gcloud projects delete --quiet ${PROJECT_ID}
rm -rf /tmp/google-cloud-sdk
