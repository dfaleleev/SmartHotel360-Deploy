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
    Write-Host "Set location $($config.backend.scriptLocation)";

    Push-Location $config.backend.scriptLocation
}

function Get-PublicIngressIp() {
    return $(kubectl get svc addon-http-application-routing-nginx-ingress -n kube-system -o=jsonpath="{.status.loadBalancer.ingress[0].ip}")
}

function Set-DnsName ($ip, $dnsName) {
    Write-Host "Seting DNS '$dnsName' to '$ip' IP " -ForegroundColor Yellow
    # Get the resource-id of the public ip
    $ipQuery = "[?ipAddress!=null]|[?contains(ipAddress, '$ip')].[id]"
    
    $publicIpId = $(az network public-ip list --query $ipQuery --output tsv)

    if (-not [string]::IsNullOrEmpty($publicIpId)) {
        # Update public ip address with DNS name
        az network public-ip update --ids $publicIpId --dns-name $dnsName
    } else {
        Write-Host "Specified public ip '$ip' not found." -ForegroundColor Red
    }
}

function Set-IngressDnsName($apiDnsName) {
    $ipAddress = Get-PublicIngressIp

    if (![string]::IsNullOrEmpty($ipAddress)) {
        Set-DnsName $ipAddress $apiDnsName
    } else {
        Write-Host "Ingress IP Address not found. Try Again later." -ForegroundColor Red
    }
}

# Export Section

Export-ModuleMember -Function Get-Config
Export-ModuleMember -Function Set-BackendDeploymentVariables
Export-ModuleMember -Function Push-LocationToBackendSetup
Export-ModuleMember -Function Get-PublicIngressIp
Export-ModuleMember -Function Set-DnsName
Export-ModuleMember -Function Set-IngressDnsName