#
#   This script initilizes ingress (nginx) on current k8s cluster.
#
#   Prerequisites:
#       * Kubernetes cluster has to be created
#       * Helm has to be installed 

Import-Module .\deploy.psm1

$config = Get-Config
Set-IngressDnsName $config.apiDnsName

