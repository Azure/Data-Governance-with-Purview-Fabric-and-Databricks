param namePrefix string
param location string
param tags object
@allowed(['standard','premium','trial'])
param workspaceSku string = 'standard'
param enableNoPublicIp bool = true
param managedResourceGroupName string = ''

@description('Optional Databricks workspace name override.')
param workspaceName string = ''

@description('Environment name for unique resource naming')
param environmentName string

// Generate compliant Databricks workspace name (consistent pattern)
var cleanNamePrefix = replace(replace(namePrefix, '-', ''), '_', '')
var uniqueSuffix = take(uniqueString(subscription().id, location, environmentName), 6)
var computedDatabricksName = toLower('dbw${take(cleanNamePrefix, 8)}${uniqueSuffix}')
var databricksName = workspaceName != '' ? toLower(workspaceName) : computedDatabricksName
var mrgName = managedResourceGroupName != '' ? managedResourceGroupName : '${resourceGroup().name}-databricks'

resource databricks 'Microsoft.Databricks/workspaces@2024-05-01' = {
  name: databricksName
  location: location
  sku: {
    name: workspaceSku
  }
  properties: {
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', mrgName)
    parameters: {
      enableNoPublicIp: {
        value: enableNoPublicIp
      }
    }
  }
  tags: tags
}

output id string = databricks.id
output name string = databricksName
