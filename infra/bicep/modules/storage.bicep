param namePrefix string
param location string
param tags object
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_LRS'
param containers array = [
  'raw'
  'curated'
  'sandbox'
]

@description('Optional Storage account name override (must be globally unique, 3-24 lowercase alphanumeric characters only).')
@maxLength(24)
param storageAccountName string = ''

// Build a compliant and globally-unique storage account name: st + up to 8 chars from prefix + uniqueString (13) = max 23 chars
var computedStorageAccountName = toLower('st${take(replace(replace(namePrefix, '-', ''), '_', ''), 8)}${take(uniqueString(resourceGroup().id, namePrefix), 11)}')
// Ensure the effective name meets storage account requirements and is within 24 char limit
var effectiveStorageAccountName = storageAccountName != '' ? toLower(storageAccountName) : computedStorageAccountName

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: effectiveStorageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  tags: tags
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
  }
}

// Blob service (required for containers)
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storage
  name: 'default'
}

// Create blob containers from parameterized list
resource containersRes 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [for c in containers: {
  parent: blobService
  name: c
  properties: {
    publicAccess: 'None'
  }
}]

output id string = storage.id
output name string = effectiveStorageAccountName
