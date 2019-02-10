
Write-Host "Create config services:" -ForegroundColor Yellow

kubectl apply -f .\yaml\config-deploy.yaml
kubectl apply -f .\yaml\config-service.yaml

