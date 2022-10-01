param location string
param environment string
param vmSize string
param vmname string
param comName string
param vmAdm string
@secure()
param vmPass string
param subid string

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: '${vmname}-win-nic01'
  location: location
  tags: {
    environment: environment
    ContactEmailAddress: 'christian.steinacher@zeiss.com, yusuf.demir@zeiss.com'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subid
          }
        }
      }
    ]
  }
}

resource winVM 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmname
  location: location
  tags: {
    environment: environment
    ContactEmailAddress: 'christian.steinacher@zeiss.com, yusuf.demir@zeiss.com'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: comName
      adminUsername: vmAdm
      adminPassword: vmPass
      windowsConfiguration: {
        timeZone: 'GMT Standard Time'
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '20h1-pro'
        version: 'latest'
      }
      dataDisks: [
        {
          lun: 0
          name: '${vmname}_datadisk_0'
          createOption: 'Empty'
          diskSizeGB: 256
        }
      ]
      osDisk: {
        name: '${vmname}_win_osdisk_0'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

