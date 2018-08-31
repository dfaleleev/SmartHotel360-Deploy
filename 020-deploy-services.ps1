
$scriptLocation = Get-Location
$configLocation = "$scriptLocation\yaml\config-k8s.yaml"

if (-not (Test-Path -Path $configLocation) ) {
    Write-Host "Specified configuration file '$configLocation' not found." -ForegroundColor Red
    exit;
}

Push-Location .\..\azure-backend\deploy\k8s

try {

    # Deploy services into k8s cluster
    Write-Host "Deploy services into k8s cluster" -ForegroundColor Yellow
    Write-Host "Use config file: '$configLocation'"
    .\deploy.ps1 `
        -configFile  $configLocation `
        -registry sh360.azurecr.io `
        -imageTag latest `
        -deployInfrastructure $true `
        -buildImages $false `
        -dockerOrg 'smarthotels' `
        -pushImages $false
} finally {
    Pop-Location
}