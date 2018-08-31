function Remove-Group($groupName){
    Write-Host "Send request to delete group '$groupName'" -ForegroundColor Yellow
    az group delete --name $groupName --yes --no-wait
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

Remove-Group $config.dataGroupName
Remove-Group $config.webGroupName
Remove-Group $config.aksGroupName

