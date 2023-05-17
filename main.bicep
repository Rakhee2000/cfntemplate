param adminUsername string
param adminPassword secureString

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'az_dfx_vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'az_dfx_vnet_subnet01'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'az_dfx_linuxvm_public_ip'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'az_dfx_vnet_subnet01_nsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'az_dfx_linux_vm_nic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'az_dfx_linux_vm_nic_ipconfig'
        properties: {
          subnet: {
            id: vnet.subnets[0].id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
    publicIp
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'az_dfx_linux_vm'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'az_dfx_linux_vm'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
  dependsOn: [
    nic
  ]
}

output vmFQDN string = vm.id.apply(id => id.split('/').[8])
output sshCommand string = 'ssh ' + adminUsername + '@' + vmFQDN
