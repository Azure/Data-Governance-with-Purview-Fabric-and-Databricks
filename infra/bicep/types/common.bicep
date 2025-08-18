// Common user-defined types for the Data Governance infrastructure

@export()
type resourceNamingType = {
  @description('Optional Resource Group name override.')
  resourceGroupName: string?
  
  @description('Optional Storage account name override.')
  storageAccountName: string?
  
  @description('Optional Databricks workspace name override.')
  databricksWorkspaceName: string?
  
  @description('Optional Fabric capacity name override.')
  fabricCapacityName: string?
  
  @description('Optional PostgreSQL server name override.')
  postgresServerName: string?
  
  @description('Optional Event Hub namespace name override.')
  eventHubNamespaceName: string?
}

@export()
type fabricConfigType = {
  @description('Fabric capacity SKU (F units).')
  skuName: ('F2' | 'F4' | 'F8' | 'F16' | 'F32' | 'F64' | 'F128')
  
  @description('Fabric capacity admin users (AAD object IDs or UPNs).')
  adminUsers: string[]?
}

@export()
type databricksConfigType = {
  @description('Databricks workspace pricing tier.')
  workspaceSku: ('standard' | 'premium' | 'trial')
  
  @description('Disable public IP for Databricks workspace.')
  enableNoPublicIp: bool
  
  @description('Custom managed resource group name.')
  managedResourceGroupName: string?
}

@export()
type storageConfigType = {
  @description('Storage account SKU.')
  skuName: ('Standard_LRS' | 'Standard_GRS' | 'Standard_RAGRS' | 'Standard_ZRS' | 'Premium_LRS' | 'Premium_ZRS')
  
  @description('Storage containers to create.')
  containers: string[]
}

@export()
type azureAdAdminType = {
  @description('Azure AD Object ID of the administrator')
  objectId: string

  @description('Principal name (email/UPN) of the administrator')
  principalName: string

  @description('Optional: Principal type (User or Group). Default is User.')
  principalType: string?
}

@export()
type postgresConfigType = {
  @description('PostgreSQL version.')
  version: ('11' | '12' | '13' | '14' | '15' | '16' | '17')
  
  @description('PostgreSQL storage size in GB.')
  storageSizeGB: int
  
  @description('PostgreSQL geo-redundant backup setting.')
  geoRedundantBackup: ('Enabled' | 'Disabled')
  
  @description('PostgreSQL auto-grow setting.')
  autoGrow: ('Enabled' | 'Disabled')
  
  @description('PostgreSQL compute SKU name (VM size).')
  skuName: ('Burstable_B1ms' | 'Burstable_B4ms' | 'Standard_B4ms' | 'Standard_D2s_v3' | 'Standard_D4s_v3')
  
  @description('PostgreSQL SKU tier.')
  skuTier: ('Burstable' | 'GeneralPurpose' | 'MemoryOptimized')
  
  @description('Storage IOPS for performance.')
  storageIops: int?
  
  @description('Storage tier for performance.')
  storageTier: ('P1' | 'P2' | 'P3' | 'P4' | 'P6' | 'P10' | 'P15' | 'P20' | 'P30' | 'P40' | 'P50' | 'P60' | 'P70' | 'P80')?
  
  @description('Availability zone for the server.')
  availabilityZone: string?
  
  @description('Backup retention days.')
  backupRetentionDays: int?
  
  @description('Azure AD administrators (array of objects with objectId and principalName properties).')
  azureAdAdministrators: azureAdAdminType[]?
  
  @description('Azure AD admin users (legacy approach using principal names/emails). This is deprecated in favor of azureAdAdministrators.')
  azureAdAdminUsers: string[]?
}

@export()
type eventHubConfigType = {
  @description('Event Hub namespace SKU.')
  skuName: ('Basic' | 'Standard' | 'Premium')
  
  @description('Event Hub namespace capacity (throughput units).')
  capacity: int
  
  @description('Event Hub topic name.')
  topicName: string
  
  @description('Event Hub topic partition count.')
  partitionCount: int
  
  @description('Event Hub topic message retention in days.')
  messageRetentionInDays: int
}

@export()
type environmentTagsType = {
  @description('Environment name (dev, staging, prod)')
  environment: string
  
  @description('Project identifier')
  project: string
  
  @description('AZD environment name')
  'azd-env-name': string
  
  @description('Additional custom tags')
  additionalTags: object?
}
