@description('Base name prefix for resources')
param namePrefix string

@description('Azure region for deployment')
param location string

@description('Resource tags')
param tags object = {}

@description('Event Hub namespace name override')
param namespaceName string = ''

@description('Event Hub name (topic)')
param topicName string = 'market-data'

@description('Event Hub SKU')
@allowed(['Basic', 'Standard', 'Premium'])
param skuName string = 'Standard'

@description('Event Hub capacity (throughput units)')
param capacity int = 1

@description('Event Hub topic partition count')
param partitionCount int = 2

@description('Event Hub topic message retention in days')
param messageRetentionInDays int = 15

@description('Environment name for unique resource naming')
param environmentName string

@description('Consumer groups to create for the Event Hub (one per downstream consumer)')
param consumerGroups array = []

@description('Enable Capture feature to archive events to Blob Storage')
param captureEnabled bool = true

@description('Capture encoding')
@allowed(['Avro','AvroDeflate'])
param captureEncoding string = 'Avro'

@description('Capture interval in seconds (must be between 60 and 900 and a multiple acceptable by service)')
param captureIntervalInSeconds int = 300

@description('Capture size limit in bytes (between 10485760 and 524288000)')
param captureSizeLimitInBytes int = 314572800

@description('Archive naming format for capture destination')
param captureArchiveNameFormat string = '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'

@description('Storage Account Resource ID for Capture destination')
param captureStorageAccountResourceId string = ''

@description('Blob container name for Capture destination (must exist)')
param captureBlobContainer string = 'ehcapture'

// Generate compliant Event Hub namespace name (must start with letter, 6-50 chars, alphanumeric + hyphens)
var cleanNamePrefix = replace(replace(namePrefix, '_', ''), ' ', '')
var uniqueSuffix = take(uniqueString(subscription().id, location, environmentName), 6)
var eventHubNamespaceName = !empty(namespaceName) ? namespaceName : 'eh${take(cleanNamePrefix, 8)}${uniqueSuffix}'

// Event Hub Namespace
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuName
    capacity: capacity
  }
  properties: {
    disableLocalAuth: false
    zoneRedundant: false
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: true
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Event Hub (Topic)
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: topicName
  properties: {
    messageRetentionInDays: messageRetentionInDays
    partitionCount: partitionCount
    status: 'Active'
    captureDescription: captureEnabled ? {
      enabled: true
      encoding: captureEncoding
      intervalInSeconds: captureIntervalInSeconds
      sizeLimitInBytes: captureSizeLimitInBytes
      destination: {
        name: 'EventHubArchive.AzureBlockBlob'
        properties: {
          archiveNameFormat: captureArchiveNameFormat
          blobContainer: captureBlobContainer
          storageAccountResourceId: captureStorageAccountResourceId
        }
      }
    } : null
  }
}

// Consumer Groups
resource eventHubConsumerGroups 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-01-01' = [for cg in consumerGroups: {
  parent: eventHub
  name: cg
  properties: {}
}]

// Default authorization rule for the namespace
resource namespaceAuthRule 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' = {
  parent: eventHubNamespace
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

// Outputs
output id string = eventHubNamespace.id
output name string = eventHubNamespace.name
output namespaceName string = eventHubNamespace.name
output topicName string = eventHub.name
output serviceBusEndpoint string = eventHubNamespace.properties.serviceBusEndpoint
output authRuleName string = namespaceAuthRule.name
output consumerGroups array = consumerGroups
output captureEnabledOut bool = captureEnabled
