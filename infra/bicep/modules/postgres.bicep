param namePrefix string
param location string
param tags object
param postgresAdminUser string
@secure()
param postgresAdminPassword string
@allowed(['11' ,'12','13','14','15','16','17'])
param version string = '17'
param storageSizeGB int = 64
@allowed(['Enabled','Disabled'])
param geoRedundantBackup string = 'Disabled'
@allowed(['Enabled','Disabled'])
param autoGrow string = 'Enabled'
@allowed(['Burstable_B1ms','Burstable_B4ms','Standard_B4ms','Standard_D2s_v3','Standard_D4s_v3'])
param skuName string = 'Standard_B4ms'
@allowed(['Burstable','GeneralPurpose','MemoryOptimized'])
param skuTier string = 'Burstable'

@description('Optional PostgreSQL flexible server name override.')
param serverName string = ''

@description('Environment name for unique resource naming')
param environmentName string

@description('Azure AD admin users for PostgreSQL server (legacy approach using principal names/emails)')
param azureAdAdminUsers string[] = []

@description('Azure AD administrators with object IDs (new approach)')
param azureAdAdministrators array = []

@description('Azure AD tenant ID')
param tenantId string = tenant().tenantId

@description('Storage IOPS (required for performance tiers)')
param storageIops int = 240

@description('Storage tier for performance')
@allowed(['P1','P2','P3','P4','P6','P10','P15','P20','P30','P40','P50','P60','P70','P80'])
param storageTier string = 'P6'

@description('Availability zone for the server')
param availabilityZone string = '1'

@description('Backup retention days')
param backupRetentionDays int = 7

// Generate compliant PostgreSQL server name (3-63 chars, lowercase + hyphens + numbers)
var cleanNamePrefix = replace(replace(namePrefix, '-', ''), '_', '')
var uniqueSuffix = take(uniqueString(subscription().id, location, environmentName), 6)
var computedPostgresName = toLower('pg${take(cleanNamePrefix, 8)}${uniqueSuffix}')
var postgresName = serverName != '' ? toLower(serverName) : computedPostgresName

// Handle backwards compatibility for Azure AD admins
var hasLegacyAdmins = !empty(azureAdAdminUsers)
var hasNewAdmins = !empty(azureAdAdministrators)
var hasAnyAdmins = hasLegacyAdmins || hasNewAdmins

resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2025-01-01-preview' = {
  name: postgresName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    replica: {
      role: 'Primary'
    }
    storage: {
      iops: storageIops
      tier: storageTier
      storageSizeGB: storageSizeGB
      autoGrow: autoGrow
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    dataEncryption: {
      type: 'SystemManaged'
    }
    authConfig: {
      activeDirectoryAuth: hasAnyAdmins ? 'Enabled' : 'Disabled'
      passwordAuth: 'Enabled'
      tenantId: tenantId
    }
    version: version
    administratorLogin: postgresAdminUser
    administratorLoginPassword: postgresAdminPassword
    availabilityZone: availabilityZone
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
    replicationRole: 'Primary'
  }
  tags: tags
}

// Azure AD Administrators - New approach with object IDs
resource postgresAzureAdAdministrators 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2025-01-01-preview' = [for admin in azureAdAdministrators: if (hasNewAdmins) {
  parent: postgres
  name: admin.objectId
  properties: {
    principalType: !empty(admin.principalType) ? admin.principalType : 'User'
    principalName: admin.principalName
    tenantId: tenantId
  }
}]

// Legacy approach for backwards compatibility - Warning: this will fail if the admins don't exist in the tenant
// For legacy support only. Please switch to the new azureAdAdministrators parameter.
resource postgresAzureAdAdminsLegacy 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2025-01-01-preview' = [for (admin, i) in azureAdAdminUsers: if (hasLegacyAdmins && !hasNewAdmins) {
  parent: postgres
  // Warning: This will generate a GUID instead of using the actual Azure AD Object ID
  // and will cause deployment failures if the user doesn't exist in the tenant
  name: guid(admin, postgres.id)
  properties: {
    principalType: 'User'
    principalName: admin
    tenantId: tenantId
  }
}]

// Advanced Threat Protection
resource advancedThreatProtection 'Microsoft.DBforPostgreSQL/flexibleServers/advancedThreatProtectionSettings@2025-01-01-preview' = {
  parent: postgres
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
}

// Allow Azure services firewall rule
resource allowAzureServices 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2025-01-01-preview' = {
  parent: postgres
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output id string = postgres.id
output name string = postgresName
output fullyQualifiedDomainName string = postgres.properties.fullyQualifiedDomainName
