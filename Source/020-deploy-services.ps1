$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

Write-Host $config -ForegroundColor Yellow


$scriptLocation = Get-Location
$configLocation = "$scriptLocation\yaml\config-k8s.yaml"

if (-not (Test-Path -Path $configLocation) ) {
    Write-Host "Specified configuration file '$configLocation' not found." -ForegroundColor Red
    exit;
}

$config = Get-Config
Set-BackendDeploymentVariables $config

    
try {
    Push-LocationToBackendSetup $config   

    # Deploy services into k8s cluster
    Write-Host "Deploy services into k8s cluster" -ForegroundColor Yellow
    Write-Host "Use config file: '$configLocation'"

    .\02-Deploy-Apis.ps1 -httpRouting $true -createAcr $false

    # .\deploy.ps1 `
    #     -configFile  $configLocation `
    #     -registry sh360.azurecr.io `
    #     -imageTag latest `
    #     -deployInfrastructure $true `
    #     -buildImages $false `
    #     -dockerOrg 'smarthotels' `
    #     -pushImages $false
} finally {
    Pop-Location
}