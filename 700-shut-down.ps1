function Remove-Group($groupName){
    Write-Host "Send request to delete group '$groupName'" -ForegroundColor Yellow
    az group delete --name $groupName --yes --no-wait
}

function Stop-AksVms()
{
    Write-Host "Deallocate AKS node VMs" -ForegroundColor Yellow
    $vms = $(az vm list --query "[].id" -o tsv | Where-Object {
        $_ -like "*aks-nodepool*"
    })

    $vms | ForEach-Object {
        Write-Host "Send request to deallocate VM: $_" -ForegroundColor Yellow
        az vm deallocate --id $_ --no-wait
    }
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

Stop-AksVms 
Remove-Group $config.dataGroupName
Remove-Group $config.webGroupName

