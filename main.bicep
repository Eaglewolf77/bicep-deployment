param location string = 'swedencentral'
param sshPublicKey string
param adminUsername string
param spObjectId string

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
}

resource allowSSH 'Microsoft.Network/networkSecurityGroups/securityRules@2022-07-01' = {
  name: 'Allow-SSH'
  parent: nsg
  properties: {
    priority: 1001
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
  }
}

resource allowHTTP 'Microsoft.Network/networkSecurityGroups/securityRules@2022-07-01' = {
  name: 'Allow-HTTP'
  parent: nsg
  properties: {
    priority: 1002
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
  }
}

resource subnetAssoc 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  parent: vnet
  name: 'bicep-test-subnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: nsg.id
    }
  }
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
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'bicep-jumpbox'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
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
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'bicep-webserver'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
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
  name: 'keyvault-bicep-cloud23'
  location: location
  properties: {
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: spObjectId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
        }
      }
    ]
    sku: {
      family: 'A'
      name: 'standard'
    }
    publicNetworkAccess: true
  }
}

resource automation 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: 'bicep-automation'
  location: location
  properties: {}
}
