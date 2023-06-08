# istio-controlplane
Istio control plane deployment with ability for blue green upgrades

# Installing Istio using helm charts

### Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Choose a version and modify values
Helm values files for each istio deployment can be found in `helm/<version>/values`. 

### Apply ArgoCD app manifests, first applying controlplane components
```bash
kubectl apply -f helm/<version>/01-istio-base.yaml

kubectl apply -f helm/<version>/02-istiod.yaml

kubectl apply -f helm/<version>/03-istio-ingress.yaml

kubectl apply -f helm/<version>/04-istio-eastwest.yaml
```

# Installing Istio via Lifecycle Manager

### Install controlplane components
```bash
kubectl apply -f LifecycleManager/01-ilm.yaml

kubectl apply -f LifecycleManager/02-glm-ingress.yaml

kubectl apply -f LifecycleManager/03-glm-eastwest.yaml
```