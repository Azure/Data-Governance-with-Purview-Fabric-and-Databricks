param namePrefix string
param location string
param tags object
param adminUsers array
@allowed(['F2','F4','F8','F16','F32','F64','F128'])
param skuName string = 'F2'

@description('Optional Fabric capacity name override.')
param capacityName string = ''

@description('Environment name for unique resource naming')
param environmentName string

// Generate compliant Fabric capacity name (must start with letter, 3-63 chars)
var cleanNamePrefix = replace(replace(namePrefix, '-', ''), '_', '')
var uniqueSuffix = take(uniqueString(subscription().id, location, environmentName), 6)
var computedCapacityName = toLower('fc${take(cleanNamePrefix, 8)}${uniqueSuffix}')
var fabricCapacityName = capacityName != '' ? toLower(capacityName) : computedCapacityName

resource fabric 'Microsoft.Fabric/capacities@2023-11-01' = {
  name: fabricCapacityName
  location: location
  sku: {
    name: skuName
    tier: 'Fabric'
  }
  properties: {
    administration: {
      members: adminUsers
    }
  }
  tags: tags
}

output id string = fabric.id
output name string = fabricCapacityName
