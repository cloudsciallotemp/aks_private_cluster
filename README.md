# AKS Private Cluster Sample Code with Terraform
###### This repository contains sample code to deploy an AKS cluster with no public endpoints using Terraform. 

#### Refer to the following Azure Docs to learn more:

- https://docs.microsoft.com/en-us/azure/aks/private-clusters
- https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype
- https://docs.microsoft.com/en-us/azure/aks/internal-lb
- https://docs.microsoft.com/en-us/azure/aks/ingress-internal-ip

#### Deployment Instructions
- Sign into the Azure CLI
- `terraform init`
- `terraform apply --auto-approve`

#### Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |
| azure-cli | >=2.20.0 |

#### Providers

| Name | Version |
|------|---------|
| azurerm | >=2.50.0 |

#### Resources

| Name |
|------|
| [azurerm_firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) |
| [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) |
| [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) |
| [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) |
| [azurerm_route](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) |
| [azurerm_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) |
| [azurerm_subnet_route_table_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) |
| [azurerm_user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) |
| [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) |

#### Inputs

No input.

#### Outputs

No output.