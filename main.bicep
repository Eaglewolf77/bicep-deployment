param location string = 'swedencentral'

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'bicep-test-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'bicep-test-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'bicep-test-nsg'
  location: location
  properties: {}
}

resource jumpboxPip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'bicep-jumpbox-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource jumpboxNic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'bicep-jumpbox-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: jumpboxPip.id
          }
        }
      }
    ]
  }
}

resource jumpboxVm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'bicep-jumpbox'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'bicep-jumpbox'
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumpboxNic.id
        }
      ]
    }
  }
}

resource webPip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'bicep-web-lb-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2022-07-01' = {
  name: 'bicep-web-lb'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'PublicIPAddress'
        properties: {
          publicIPAddress: {
            id: webPip.id
          }
        }
      }
    ]
  }
}

resource webNic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'bicep-webserver-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          loadBalancerBackendAddressPools: [
            {
              id: lb.properties.backendAddressPools[0].id
            }
          ]
        }
      }
    ]
  }
}

resource webVm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'bicep-webserver'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'bicep-webserver'
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: webNic.id
        }
      ]
    }
  }
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'bicep-keyvault-test'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

resource automation 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: 'bicep-automation'
  location: location
  properties: {}
  sku: {
    name: 'Basic'
  }
}
