
$scriptLocation = Get-Location

Push-Location .\..\azure-backend\deploy\k8s

try {

    # Deploy services into k8s cluster
    Write-Host "Deploy services into k8s cluster" -ForegroundColor Yellow
    .\deploy.ps1 `
        -configFile $scriptLocation\yaml\config_k8s.yaml `
        -registry sh360.azurecr.io `
        -imageTag latest `
        -deployInfrastructure $true `
        -buildImages $false `
        -dockerOrg 'smarthotels' `
        -pushImages $false
} finally {
    Pop-Location
}