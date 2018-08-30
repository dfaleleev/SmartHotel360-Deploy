
Write-Host "Create test services:" -ForegroundColor Yellow

kubectl apply -f .\yaml\tst\webapitest-deploy.yaml
kubectl apply -f .\yaml\tst\webapitest-service.yaml
kubectl apply -f .\yaml\tst\nginx-hello-deploy.yaml
kubectl apply -f .\yaml\tst\nginx-hello-service.yaml

