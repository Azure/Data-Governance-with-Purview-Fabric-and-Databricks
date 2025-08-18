using './main.bicep'

// Basic configuration
param location = 'centralus'
param name = 'wkpdg'
param postgresAdminUser = 'pgadmin'
param postgresAdminPassword = 'S7rong!Passw0rd'

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
  adminUsers: ['admin@email.com']
}

// Databricks configuration
param databricksConfig = {
  workspaceSku: 'premium'
  enableNoPublicIp: true
}

// Storage configuration
param storageConfig = {
  skuName: 'Standard_LRS'
  containers: ['bronze'
  'silver'
  'gold']
}

// PostgreSQL configuration
param postgresConfig = {
  version: '17'
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
      objectId: '00000000-0000-0000-0000-000000000000' // Replace with the actual Azure AD Object ID
      principalName: 'admin@email.com'
      principalType: 'User'
    }
  ]
}

// Event Hub configuration
param eventHubConfig = {
  skuName: 'Standard'
  capacity: 1
  topicName: 'data-governance-events'
  partitionCount: 2
  messageRetentionInDays: 7
}

// Tags configuration
param tagsConfig = {
  environment: 'prod'
  project: 'DataGovernance'
  'azd-env-name': 'wkpdg'
  additionalTags: {
    owner: 'DataTeam'
    costCenter: 'DataPlatform'
  }
}
