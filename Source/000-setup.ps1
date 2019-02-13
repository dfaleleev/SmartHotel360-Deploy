# setup dev-spaces extension
#az extension add --name dev-spaces-preview

# setup service provider for AKS

$spClient = $(az ad sp list --spn "http://sh360-aks-sp")
if ($spClient.Length -gt 3) {
    $spClient
} else {
    az ad sp create-for-rbac -n "http://sh360-aks-sp" --skip-assignment
}



