$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

Write-Host $config -ForegroundColor Yellow


$scriptLocation = Get-Location
$configLocation = "$scriptLocation\yaml\config-k8s.yaml"

if (-not (Test-Path -Path $configLocation) ) {
    Write-Host "Specified configuration file '$configLocation' not found." -ForegroundColor Red
    exit;
}

Push-Location ..\..\backend\Source\setup
    
try {

    .\00-set-vars.ps1 `
        -subscription $config.subscription `
        -resourceGroup $config.aksGroupName `
        -clusterName $config.aksName `
        -registry $config.acrName `
        -location $config.location `
        -sh360AppName sh360 `
        -spnClientId $config.spnClientId `
        -spnPassword $config.spnPassword

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