function Start-AksVms()
{
    Write-Host "Start AKS node VMs" -ForegroundColor Yellow
    $vms = $(az vm list --query "[].id" -o tsv | Where-Object {
        $_ -like "*aks-nodepool*"
    })

    $vms | ForEach-Object {
        Write-Host $_ -ForegroundColor Yellow
        az vm start --id $_
    }
}

function Test-ApiMethods($hostName)
{
    $apiServer = "http://$hostName.eastus.cloudapp.azure.com"

    $urlTestApp = "$apiServer/wt"

    Write-Host "Try connection to Test API '$urlTestApp':" -ForegroundColor Yellow
    $testAppResponse = Invoke-RestMethod -Uri $urlTestApp
    if ( ($null -ne $testAppResponse) -and $testAppResponse.title -eq "API Root") {
        Write-Host "Connection to API test app succeded" -ForegroundColor Green
    } else {
        Write-Host "Connection to API test app failed" -ForegroundColor Red
    }

    $urlProfileApi = "$apiServer/profiles-api/profiles/shanselman@outlook.com"

    Write-Host "Try connection to Test API '$urlProfileApi':" -ForegroundColor Yellow
    $profileResponse = Invoke-RestMethod -Uri $urlProfileApi
    Write-Host $profileResponse
    if ( ($null -ne $profileResponse) -and $profileResponse.userId -eq "shanselman@outlook.com") {
        Write-Host "Connection to profile API succeded" -ForegroundColor Green
    } else {
        Write-Host "Connection to profile API failed" -ForegroundColor Red
    }
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

Start-AksVms 

Write-Host "Create SQL data group: " -ForegroundColor Yellow
.\000-create-data.ps1

Write-Host "Deploy AKS Services: " -ForegroundColor Yellow
.\020-deploy-services.ps1

Write-Host "Deploy Test Services: " -ForegroundColor Yellow
.\021-deploy-test-services.ps1

Write-Host "Configure Routes: " -ForegroundColor Yellow
.\030-configure-routes.ps1

# Wait a minute for kubernetes to start up properly.
# TODO: Make more efficient way to wait for services start up.
Start-Sleep -s 60

Test-ApiMethods $config.apiDnsName
