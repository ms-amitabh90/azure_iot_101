targetScope = 'resourceGroup'

param addressSpace string = '10.59.0.0/16'
param vnetName string = 'vnet-iotlab'
param location string = resourceGroup().location
param vmCount int = 2
param environment string = 'dev'
param bstName string = 'bst-iotlab101'
param vmSize string = 'Standard_D2_v2'
param vmAdm string = 'vmadmin'
param vmPass string = 'P@ssw0rd@123456'

var firstOutput = split(addressSpace, '.' )
var mask1 = firstOutput[0]
var mask2 = firstOutput[1]

var sub1 = '${mask1}.${mask2}.1.0/27'
var sub2 = '${mask1}.${mask2}.2.0/24'


var bstPIPName = 'iot-lab-101-bastion-pip'
var baseVmName = 'iotlab${uniqueString(resourceGroup().id)}'

var nsg1Name = 'iot-lab-101-bastion-nsg'
var nsg2Name = 'iot-lab-101-network-nsg'

resource nsgDef 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: nsg1Name
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow_Bastion_Subnet'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '*'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '${mask1}.${mask2}.1.0/24'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'allow_AzureLoadBalancer'
        properties: {
          priority: 1100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '*'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
        {
        name: 'allow_Subnet_Traffic'
        properties: {
          priority: 1900
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '*'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '${mask1}.${mask2}.2.0/24'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'deny_Other_All'
        properties: {
          priority: 2000
          access: 'Deny'
          direction: 'Inbound'
          destinationPortRange: '*'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
resource nsgbst 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: nsg2Name
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 120
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          priority: 130
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
        }
      }
        {
        name: 'AllowSshOutbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Outbound'
          destinationPortRange: '22'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
        {
        name: 'AllowRdpOutbound'
        properties: {
          priority: 101
          access: 'Allow'
          direction: 'Outbound'
          destinationPortRange: '3389'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          priority: 110
          access: 'Allow'
          direction: 'Outbound'
          destinationPortRange: '443'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  tags: {
    environment: environment
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      {
        name: 'iot-lab-101-edgedevice-snet'
        properties: {
          addressPrefix: sub2
          networkSecurityGroup: {
             id: nsgDef.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: sub1
          networkSecurityGroup: {
             id: nsgbst.id
          }
        }
      }
    ]
  }
}

resource bstPIP 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: bstPIPName
  location: location
  tags: {
    environment: environment
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource azureBastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: bstName
  location: location
  tags: {
    environment: environment
  }
  properties: {
    ipConfigurations: [
       {
         name: 'ipConf'
         properties: {
           publicIPAddress: {
             id: bstPIP.id
           }
           subnet: {
             id: '${virtualNetwork.id}/subnets/AzureBastionSubnet'
           }
         }
       }
    ]
  }
}

module lnxMDL 'modules/linuxvm.bicep'= [for i in range(0, vmCount): {
  name: '${i}deploy${baseVmName}'
  params: {
    vmname: '${i}vm${baseVmName}'
    comName: '${i}com'
    environment: environment
    location: location
    vmSize: vmSize
    vmPass: vmPass
    vmAdm: vmAdm
    subid: '${virtualNetwork.id}/subnets/iot-lab-101-edgedevice-snet'
  }
}]

output winNetworkID string = '${virtualNetwork.id}/subnets/iot-lab-101-edgedevice-snet'
output lnxNetworkID string = '${virtualNetwork.id}/subnets/AzureBastionSubnet'
