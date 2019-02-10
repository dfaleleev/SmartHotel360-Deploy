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

function Test-UrlResponse($title, $url, $property, $value){

    Write-Host "Try connection to $title '$url':" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $url
    if ( ($null -ne $response) ) {
        $succeed = $false
        if (-not [string]::IsNullOrEmpty($property)) {
            $propertyValue = $($response | Select-Object -ExpandProperty $property)
            Write-Host "Property: $propertyValue"
            $succeed = ($propertyValue -like $value)
        } else {
            $succeed = $true
        }

        if ($succeed -eq $true) {
            Write-Host "Connection to $title succeded" -ForegroundColor Green
            return
        } else {
            Write-Host $response
        }
    }
    
    Write-Host "Connection to $title failed" -ForegroundColor Red
}

function Test-ApiMethods($hostName)
{
    $apiServer = "http://$hostName.eastus.cloudapp.azure.com"

    # Wait a minute for kubernetes to start up properly.
    # TODO: Make more efficient way to wait for services start up.
    Start-Sleep -s 60

    Test-UrlResponse "Test API" "$apiServer/wt" "title" "API Root"

    Test-UrlResponse "Profile API" "$apiServer/profiles-api/profiles/shanselman@outlook.com" "userId" "shanselman@outlook.com"

    Test-UrlResponse "Web Config" "$apiServer/cfg/web.json" "" ""
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

Start-AksVms 

Write-Host "Create SQL data group: " -ForegroundColor Yellow
.\000-create-data.ps1

Write-Host "Deploy AKS Services: " -ForegroundColor Yellow
.\020-deploy-services.ps1

Write-Host "Deploy Test Services: " -ForegroundColor Yellow
.\021-deploy-test-services.ps1

Write-Host "Deploy Web-Site on k8s: " -ForegroundColor Yellow
.\022-deploy-web-site.ps1

Write-Host "Configure Routes: " -ForegroundColor Yellow
.\030-configure-routes.ps1

Write-Host "Deploy configs on kubernetes server." -ForegroundColor Yellow
.\101-deploy-config-service.ps1

# Write-Host "Deploy web site related resources." -ForegroundColor Yellow
# .\110-create-web-resources.ps1

Test-ApiMethods $config.apiDnsName


