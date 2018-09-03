function New-Resources($location, $groupName) {

    az group create --name $groupName --location $location 

    Write-Host "Deploy func arm template" -ForegroundColor Yellow
    az group deployment create --resource-group $groupName --parameters .\arm\func.parameters.json --template-file .\arm\func.json --verbose --mode Incremental

    Write-Host "Deploy cosmosdb arm template" -ForegroundColor Yellow
    az group deployment create --resource-group $groupName --parameters .\arm\cosmosdb.parameters.json --template-file .\arm\cosmosdb.json --verbose --mode Incremental

    Write-Host "Deploy web arm template" -ForegroundColor Yellow
    az group deployment create --resource-group $groupName --parameters .\arm\web.parameters.json --template-file .\arm\web.json --verbose --mode Incremental
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

New-Resources $config.location $config.webGroupName
