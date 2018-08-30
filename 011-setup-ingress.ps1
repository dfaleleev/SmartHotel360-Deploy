#
#   This script initilizes ingress (nginx) on current k8s cluster.
#
#   Prerequisites:
#       * Kubernetes cluster has to be created
#       * Helm has to be installed 

function Create-Ingress() {
    # https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm
    Write-Host "Set RBAC for helm" -ForegroundColor Yellow
    kubectl apply -f .\yaml\helm-rbac.yaml

    Write-Host "Initilize tiller on k8s" -ForegroundColor Yellow
    helm init --service-account tiller

    # TODO Need to wait for tiller pod
    Write-Host "Wait for tiller pod"
    # Start-Sleep -s 10

    # https://docs.microsoft.com/en-us/azure/aks/ingress
    Write-Host "Install nginx-ingress"
    helm install stable/nginx-ingress --name sh360 --namespace ingress-nginx
}

function Get-IngressIp() {
    return $(kubectl get svc sh360-nginx-ingress-controller -n ingress-nginx -o=jsonpath="{.status.loadBalancer.ingress[0].ip}")
}

function Find-IngressIp() {
    $ip = Get-IngressIp
    Write-Host "Waiting for Ingress IP:" -ForegroundColor Yellow
    foreach ( $i in 1..30) {
        
        if ([string]::IsNullOrEmpty($ip)) {
            Write-Host "." 
            Start-Sleep -s 20
            $ip = Get-IngressIp
        } else {
            Write-Host "Ingress IP $ip "
            return $ip
        }
    } 
    Write-Host "Ingress IP not found." -ForegroundColor Red
    return $null
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

function Initialize-Ingress($apiDnsName) {

    Create-Ingress

    $ipAddress = Find-IngressIp

    if (![string]::IsNullOrEmpty($ipAddress)) {
        Set-DnsName $ipAddress $apiDnsName
    } else {
        Write-Host "Ingress IP Address not found. Try Again later." -ForegroundColor Red
    }
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json

Initialize-Ingress $config.apiDnsName
