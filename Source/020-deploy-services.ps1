Import-Module .\deploy.psm1

$location = Get-Location

$config = Get-Config
Set-BackendDeploymentVariables $config

try {
    Push-LocationToBackendSetup $config   

    # Deploy services into k8s cluster
    Write-Host "Deploy services into k8s cluster" -ForegroundColor Yellow
    .\02-Deploy-Apis.ps1 -httpRouting $true -createAcr $false

} finally {
    Set-Location $location
}