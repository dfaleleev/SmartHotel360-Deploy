Import-Module .\deploy.psm1

$location = Get-Location
$config = Get-Config
Set-BackendDeploymentVariables $config

try {
    Push-LocationToBackendSetup $config   

    .\01-Aks-Create.ps1
} finally {
    Set-Location $location
}

