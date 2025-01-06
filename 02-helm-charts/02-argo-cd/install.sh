#! /bin/bash
helm repo add argo-cd https://argoproj.github.io/argo-helm

helm dep update 02-argo-cd/

helm upgrade --install -n argo-cd --create-namespace argo-cd 02-argo-cd/