// Creates a resource group and virtual network
//@description('Azure region of the deployment')
//param location string 


//@description('Name of the resource Group')
//param name string


// Setting target scope
targetScope = 'subscription'

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'czm14-conm-stg-aue-vmfactory-rg'
  location: 'Australia East'
}
