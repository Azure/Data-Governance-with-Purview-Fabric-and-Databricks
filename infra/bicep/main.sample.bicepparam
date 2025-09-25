using './main.bicep'

// Basic configuration
param location = 'centralus'
param name = 'wkpdg'
param postgresAdminUser = 'pgadmin'
param postgresAdminPassword = 'DataGov2025!'

// Resource naming overrides (optional)
param resourceNaming = {
  // resourceGroupName: 'rg-datagovernance-dev'
  // storageAccountName: 'stdatagovdev001'
  // databricksWorkspaceName: 'dbw-datagovernance-dev'
  // fabricCapacityName: 'fab-datagovernance-dev'
  // postgresServerName: 'pg-datagovernance-dev'
}
// Fabric configuration
param fabricConfig = {
  skuName: 'F2'
  adminUsers: ['admin@datagovcompany.com']
}

// Databricks configuration
param databricksConfig = {
  workspaceSku: 'premium'
  enableNoPublicIp: true
}

// Storage configuration
param storageConfig = {
  skuName: 'Standard_LRS'
  containers: [
    'staging'
    'bronze'
    'silver'
    'gold'
    'ehcapture'
  ]
}

// PostgreSQL configuration
param postgresConfig = {
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
  // New approach with Object IDs (recommended)
  azureAdAdministrators: [
    {
      objectId: '777777777-bbbb-4444-bbbb-6666666666' // Replace with the actual Azure AD Object ID
      principalName: 'admin@datagovcompany.com'
      principalType: 'User'
    }
  ]
}

// Event Hub configuration
param eventHubConfig = {
  skuName: 'Standard'
  capacity: 1
  topicName: 'market-data'
  partitionCount: 2
  messageRetentionInDays: 1
  consumerGroups: [
    'raw-loader'
    'analytics'
    'replay'
  ]
  captureEnabled: true
  captureIntervalInSeconds: 300
  captureSizeLimitInBytes: 314572800
  captureEncoding: 'Avro'
  captureArchiveNameFormat: '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'
  captureContainerName: 'ehcapture'
}

// Tags configuration
param tagsConfig = {
  environment: 'Demo'
  project: 'DataGovernance'
  'azd-env-name': 'wkpdgfsi'
  additionalTags: {
    owner: 'DataTeam'
    costCenter: 'DataPlatform'

  }
}
