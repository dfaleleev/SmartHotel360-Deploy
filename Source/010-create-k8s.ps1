Import-Module .\deploy.psm1

$config = Get-Config
Set-BackendDeploymentVariables $config

try {
    Push-LocationToBackendSetup $config   

    .\01-Aks-Create.ps1
} finally {
    Pop-Location
}

