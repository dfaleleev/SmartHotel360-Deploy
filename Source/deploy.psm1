function New-ResourceGroup($groupName)
{
    if ((az group exists --name $groupName) -eq $false)  {
        Write-Host "Create new group $groupName" -ForegroundColor Yellow
        az group create --name $groupName --location eastus
    }
}

function Get-AksId($groupName, $aksName)
{
    $result = $null
    try {
        $result = $(az aks show --resource-group $groupName --name $aksName --query "servicePrincipalProfile.clientId" --output tsv)        
    } catch {
        Write-Host "This is not an error." -ForegroundColor White
    }
    if ([string]::IsNullOrEmpty($result)) {
        [Console]::ResetColor() 
    }
    return $result
}

function Get-AcrId($acrGroupName, $acrName)
{
    $result = $null
    try {
        $result = $(az acr show --name $acrName --resource-group $acrGroupName --query "id" --output tsv)        
    } catch { 
        Write-Host "This is not an error." -ForegroundColor White
    }
    if ([string]::IsNullOrEmpty($result)) {
        [Console]::ResetColor() 
    }
    return $result
}

function Get-Config($configPath = "config.json") {
    $config = (Get-Content $configPath -Raw) | ConvertFrom-Json
    # Verify config settings
    # Update config variables

    Write-Host "Configuration:" -ForegroundColor Yellow
    Write-Host $($config | ConvertTo-Json) -ForegroundColor Yellow

    return $config;
}

function Set-BackendDeploymentVariables($config) {
    
    try {
        Push-LocationToBackendSetup $config
        
        & .\00-set-vars.ps1 `
            -subscription $config.subscription `
            -resourceGroup $config.aksGroupName `
            -clusterName $config.aksName `
            -registry $config.acrName `
            -location $config.location `
            -sh360AppName sh360 `
            -spnClientId $config.spnClientId `
            -spnPassword $config.spnPassword

    } finally {
        Pop-Location
    }
        
}

function Push-LocationToBackendSetup($config)
{
    Push-Location ..\..\backend\Source\setup
}


# Export Section

Export-ModuleMember -Function Get-Config
Export-ModuleMember -Function Set-BackendDeploymentVariables
Export-ModuleMember -Function Push-LocationToBackendSetup