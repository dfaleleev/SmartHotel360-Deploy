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

function MainScript($acrName, $acrGroupName, $aksName, $aksGroupName)
{
    # Create resource groups 
    New-ResourceGroup $groupName;
    New-ResourceGroup $acrGroupName;

    # Need to grant permissions to AKS to access ACR
    # Get the id of the service principal configured for AKS
    $clientId = Get-AksId $groupName $aksName

    # Create new AKS cluster
    if ([string]::IsNullOrEmpty($clientId) ) {
        Write-Host "Create new AKS cluster $aksName ($groupName)" -ForegroundColor Yellow
        az aks create --resource-group $groupName --name $aksName --node-count 1 --generate-ssh-keys

        # Get the id of the service principal configured for AKS
        $clientId = Get-AksId $groupName $aksName

        # Get credentials from AKS cluster to work with kubectl
        az aks get-credentials --resource-group $groupName --name $aksName

        # Update roles
        Write-Host "Update admin roles to see k8s dashboard" -ForegroundColor Yellow
        kubectl create -f .\yaml\dashboard-admin.yaml
    } else {
        Write-Host "There are already AKS cluster in group $groupName" -ForegroundColor Yellow
    }

    # Get the ACR registry resource id
    $acrId = Get-AcrId $acrGroupName $acrName

    if ([string]::IsNullOrEmpty($acrId)) {
        Write-Host "Creating ACR $acrName in group $acrGroupName" -ForegroundColor Yellow
        az acr create --resource-group $acrGroupName --name $acrName --sku Basic
        $acrId = Get-AcrId $acrGroupName $acrName
        Write-Host $acrId -ForegroundColor White
    }

    # Create role assignment
    Write-Host "Assign AKS with Reader role to ACR" -ForegroundColor Yellow
    az role assignment create --assignee $clientId --role Reader --scope $acrId
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

Write-Host $config -ForegroundColor Yellow

$groupName = $config.aksGroupName;
$aksName = $config.aksName;

$acrName = $config.acrName;
$acrGroupName = $config.acrGroupName;

# Execution of Main entrypoint
MainScript $acrName $acrGroupName $aksName $aksGroupName


