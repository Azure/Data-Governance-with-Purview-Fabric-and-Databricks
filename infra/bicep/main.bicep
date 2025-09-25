targetScope = 'subscription'

import * as types from './types/common.bicep'

@description('Azure region for deployment')
@allowed([
  'eastus'
  'eastus2'
  'westeurope'
  'northeurope'
  'centralus'
  'westus2'
  'brazilsouth'
  'francecentral'
  'uksouth'
  'southeastasia'
])
param location string = 'centralus'

@description('Base name to seed resource names')
param name string

@description('Environment name for resource naming')
param environmentName string = name

@description('Resource group name override')
param resourceGroupName string = ''

@description('PostgreSQL administrator credentials')
param postgresAdminUser string

@secure()
@description('PostgreSQL administrator password')
param postgresAdminPassword string

@description('Resource naming overrides')
param resourceNaming types.resourceNamingType = {}

@description('Fabric configuration')
param fabricConfig types.fabricConfigType = {
  skuName: 'F2'
  adminUsers: null
}

@description('Databricks configuration')
param databricksConfig types.databricksConfigType = {
  workspaceSku: 'standard'
  enableNoPublicIp: true
  managedResourceGroupName: null
}

@description('Storage configuration')
param storageConfig types.storageConfigType = {
  skuName: 'Standard_LRS'
  containers: ['staging','bronze', 'silver', 'gold', 'ehcapture']
}

@description('PostgreSQL configuration')
param postgresConfig types.postgresConfigType = {
  version: '16'
  storageSizeGB: 64
  geoRedundantBackup: 'Disabled'
  autoGrow: 'Enabled'
  skuName: 'Standard_B4ms'
  skuTier: 'Burstable'
  storageIops: 240
  storageTier: 'P6'
  availabilityZone: '1'
  backupRetentionDays: 7
  azureAdAdminUsers: []
}

@description('Event Hub configuration')
param eventHubConfig types.eventHubConfigType = {
  skuName: 'Standard'
  capacity: 1
  topicName: 'market-data'
  partitionCount: 2
  messageRetentionInDays: 1
  consumerGroups: ['raw-loader','analytics','replay']
  captureEnabled: true
  captureIntervalInSeconds: 300
  captureSizeLimitInBytes: 314572800
  captureEncoding: 'Avro'
  captureArchiveNameFormat: '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'
  captureContainerName: 'ehcapture'
}

@description('Optional Key Vault name override')
param keyVaultName string = ''

@description('Environment and tagging configuration')
param tagsConfig types.environmentTagsType = {
  environment: 'demo'
  project: 'DataGovernance'
  'azd-env-name': name
  additionalTags: {}
}

// Variables
var resourceToken = toLower(uniqueString(subscription().id, location, environmentName))
var namePrefix = '${toLower(name)}-${resourceToken}'

var allTags = union({
  'azd-env-name': tagsConfig['azd-env-name']
  environment: tagsConfig.environment
  project: tagsConfig.project
}, tagsConfig.?additionalTags ?? {})

var rgName = !empty(resourceGroupName) ? resourceGroupName : (resourceNaming.?resourceGroupName ?? 'rg-${namePrefix}')

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: rgName
  location: location
  tags: allTags
}

// User-assigned managed identity for secure resource access
module identityMod './modules/identity.bicep' = {
  name: 'identity'
  scope: resourceGroup(rg.name)
  params: {
    namePrefix: namePrefix
    location: location
    tags: allTags
  }
}

// Storage Module
module storageMod './modules/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup(rg.name)
  params: {
    namePrefix: namePrefix
    location: location
    tags: allTags
    storageAccountName: resourceNaming.?storageAccountName ?? ''
    skuName: storageConfig.skuName
    containers: storageConfig.containers
  }
}

// Databricks Module
module databricksMod './modules/databricks.bicep' = {
  name: 'databricks'
  scope: resourceGroup(rg.name)
  params: {
    namePrefix: namePrefix
    location: location
    tags: allTags
    workspaceName: resourceNaming.?databricksWorkspaceName ?? ''
    workspaceSku: databricksConfig.workspaceSku
    enableNoPublicIp: databricksConfig.enableNoPublicIp
    managedResourceGroupName: databricksConfig.?managedResourceGroupName ?? ''
    environmentName: environmentName
  }
}

// Key Vault Module (always deployed; use enableKeyVault to toggle usage in apps)
module keyVaultMod './modules/keyvault.bicep' = {
  name: 'keyvault'
  scope: resourceGroup(rg.name)
  params: {
    namePrefix: namePrefix
    location: location
    tags: allTags
    environmentName: environmentName
    keyVaultName: keyVaultName
    postgresAdminPassword: postgresAdminPassword
    identityPrincipalId: identityMod.outputs.principalId
    // Event Hub secret created after event hub exists; pass namespace & rule later via separate secret resource
    createEventHubConnectionSecret: false
  }
}

// Fabric Module
module fabricMod './modules/fabric.bicep' = {
  name: 'fabric'
  scope: resourceGroup(rg.name)
  params: {
    namePrefix: namePrefix
    location: location
    tags: allTags
    adminUsers: fabricConfig.?adminUsers ?? [postgresAdminUser]
    capacityName: resourceNaming.?fabricCapacityName ?? ''
    skuName: fabricConfig.skuName
    environmentName: environmentName
  }
}

// PostgreSQL Module
module postgresMod './modules/postgres.bicep' = {
  name: 'postgres'
  scope: resourceGroup(rg.name)
  params: {
    namePrefix: namePrefix
    location: location
    tags: allTags
    postgresAdminUser: postgresAdminUser
    postgresAdminPassword: postgresAdminPassword
    serverName: resourceNaming.?postgresServerName ?? ''
    version: postgresConfig.version
    storageSizeGB: postgresConfig.storageSizeGB
    geoRedundantBackup: postgresConfig.geoRedundantBackup
    autoGrow: postgresConfig.autoGrow
    skuName: postgresConfig.skuName
    skuTier: postgresConfig.skuTier
    storageIops: postgresConfig.?storageIops ?? 240
    storageTier: postgresConfig.?storageTier ?? 'P6'
    availabilityZone: postgresConfig.?availabilityZone ?? '1'
    backupRetentionDays: postgresConfig.?backupRetentionDays ?? 7
    azureAdAdministrators: postgresConfig.?azureAdAdministrators ?? []
    azureAdAdminUsers: postgresConfig.?azureAdAdminUsers ?? []
    environmentName: environmentName
  }
}

// Event Hub Module
module eventHubMod './modules/eventhub.bicep' = {
  name: 'eventhub'
  scope: resourceGroup(rg.name)
  params: {
    namePrefix: namePrefix
    location: location
    tags: allTags
    namespaceName: resourceNaming.?eventHubNamespaceName ?? ''
    topicName: eventHubConfig.topicName
    skuName: eventHubConfig.skuName
    capacity: eventHubConfig.capacity
    partitionCount: eventHubConfig.partitionCount
    messageRetentionInDays: eventHubConfig.messageRetentionInDays
    environmentName: environmentName
    consumerGroups: eventHubConfig.?consumerGroups ?? []
    captureEnabled: eventHubConfig.?captureEnabled ?? true
    captureIntervalInSeconds: eventHubConfig.?captureIntervalInSeconds ?? 300
    captureSizeLimitInBytes: eventHubConfig.?captureSizeLimitInBytes ?? 314572800
    captureEncoding: eventHubConfig.?captureEncoding ?? 'Avro'
    captureArchiveNameFormat: eventHubConfig.?captureArchiveNameFormat ?? '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'
    captureBlobContainer: eventHubConfig.?captureContainerName ?? 'ehcapture'
    captureStorageAccountResourceId: storageMod.outputs.id
  }
}


// Outputs
output RESOURCE_GROUP_ID string = rg.id

output resourceGroup object = {
  id: rg.id
  name: rg.name
  location: rg.location
}

output userAssignedIdentity object = {
  id: identityMod.outputs.id
  name: identityMod.outputs.name
  principalId: identityMod.outputs.principalId
  clientId: identityMod.outputs.clientId
}

output storage object = {
  id: storageMod.outputs.id
  name: storageMod.outputs.name
}

output databricks object = {
  id: databricksMod.outputs.id
  name: databricksMod.outputs.name
}

output fabric object = {
  id: fabricMod.outputs.id
  name: fabricMod.outputs.name
}

output postgres object = {
  id: postgresMod.outputs.id
  name: postgresMod.outputs.name
}

output eventHub object = {
  id: eventHubMod.outputs.id
  name: eventHubMod.outputs.name
  namespaceName: eventHubMod.outputs.namespaceName
  topicName: eventHubMod.outputs.topicName
  serviceBusEndpoint: eventHubMod.outputs.serviceBusEndpoint
}

output keyVaultId string = keyVaultMod.outputs.id
output keyVaultName string = keyVaultMod.outputs.name
output keyVaultUri string = keyVaultMod.outputs.uri
