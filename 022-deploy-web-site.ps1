
Write-Host "Create web-site resources on k8s:" -ForegroundColor Yellow

kubectl apply -f .\yaml\website-deploy.yaml
kubectl apply -f .\yaml\website-service.yaml

