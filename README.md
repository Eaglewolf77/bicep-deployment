# Bicep Deployment – Examensarbete

Detta repository innehåller Bicep-mallar för att automatiskt skapa en testmiljö i Microsoft Azure som en del av examensarbetet: **"Jämförelse av Bicep och Terraform för småföretag i Azure"**.

## Syfte
Syftet är att med hjälp av Infrastructure as Code (IaC) skapa och jämföra två identiska infrastrukturer där Bicep används i detta repository.

## Infrastruktur
Följande resurser provisioneras:
- Resource Group
- Virtual Network + Subnets
- Jumpbox Linux VM
- Web Frontend Linux VM
- Azure Load Balancer
- Azure Key Vault
- Azure Automation Account
- Network Security Groups (NSG)

## Förutsättningar
- Azure Subscription
- Service Principal (med Contributor role)
- GitHub Actions Secrets:
  - `AZURE_CLIENT_ID`
  - `AZURE_CLIENT_SECRET`
  - `AZURE_SUBSCRIPTION_ID`
  - `AZURE_TENANT_ID`

## Användning
1. Forka eller klona repo:t
2. Sätt dina GitHub Secrets
3. Pusha till `main` → deployment körs automatiskt via GitHub Actions

## Examensarbete
Detta repository är en del av mitt examensarbete inom Cloud & IT-Infrastructure Engineer-programmet och används för att jämföra Bicep med Terraform i en verklig Azure-miljö.

## Licens
MIT License – se LICENSE-filen.
