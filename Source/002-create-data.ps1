
function New-Resources($location, $groupName) {

    az group create --name $groupName --location $location 

    az group deployment create --resource-group $groupName --parameters .\arm\azuredeploy.parameters.json --template-file .\arm\data.json --verbose --mode Incremental
}

Write-Host "! Script is temporary disabled." -ForegroundColor Red

# $config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

# New-Resources $config.dataLocation $config.dataGroupName



