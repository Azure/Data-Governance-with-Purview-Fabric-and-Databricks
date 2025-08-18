@description('Base name prefix for resources')
param namePrefix string

@description('Azure region for deployment')
param location string

@description('Resource tags')
param tags object = {}

@description('Event Hub namespace name override')
param namespaceName string = ''

@description('Event Hub topic name')
param topicName string = 'data-governance-events'

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
  }
}

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
