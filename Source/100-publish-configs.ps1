
Write-Host "Build nginx docker image with config folder" -ForegroundColor Yellow
docker build .\config -t sh360-config

Write-Host "Login to Azure ACR" -ForegroundColor Yellow
az acr login -n sh360

Write-Host "Tag docker image for Azure ACR" -ForegroundColor Yellow
docker tag sh360-config:latest sh360.azurecr.io/smarthotels/sh360-config:latest

Write-Host "Push image to Azure ACR" -ForegroundColor Yellow
docker push  sh360.azurecr.io/smarthotels/sh360-config:latest