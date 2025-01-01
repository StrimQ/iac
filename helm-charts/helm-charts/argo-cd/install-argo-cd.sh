#! /bin/bash
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm dep update argo-cd/

helm upgrade --install -n argo-cd --create-namespace argo-cd argo-cd/