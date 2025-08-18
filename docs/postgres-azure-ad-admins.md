# PostgreSQL Azure AD Administrators Configuration

This document explains how to properly configure Azure AD administrators for PostgreSQL Flexible Server in the Data Governance infrastructure.

## Configuration Update

The PostgreSQL module has been updated to support proper Azure AD administrator configuration. Previously, the module attempted to generate administrator resource names using the `guid()` function, which resulted in deployment errors because the actual Azure AD Object IDs of the administrators were not being used.

## How to Configure Azure AD Administrators

### New Approach (Recommended)

Use the `azureAdAdministrators` parameter with proper Object IDs:

```bicep
param postgresConfig = {
  // Other PostgreSQL configurations...
  
  // Azure AD administrators with Object IDs
  azureAdAdministrators: [
    {
      objectId: '7fd6ef31-b70f-499f-b2da-668405acf2f4'  // Replace with actual Azure AD Object ID
      principalName: 'user@yourdomain.com'
      principalType: 'User'  // 'User' or 'Group'
    }
  ]
}
```

### Legacy Approach (Deprecated)

The legacy approach using just principal names is still supported for backward compatibility but is discouraged as it can lead to deployment errors:

```bicep
param postgresConfig = {
  // Other PostgreSQL configurations...
  
  // Legacy approach (not recommended)
  azureAdAdminUsers: ['user@yourdomain.com']
}
```

## How to Find Azure AD Object IDs

### Using Azure Portal

1. Go to Microsoft Entra ID (formerly Azure Active Directory)
2. Search for the user or group
3. Copy the Object ID from the Overview page

### Using Azure CLI

For users:
```bash
az ad user show --id user@yourdomain.com --query objectId --output tsv
```

For groups:
```bash
az ad group show --group "GroupName" --query objectId --output tsv
```

### Using PowerShell

For users:
```powershell
Get-AzADUser -UserPrincipalName user@yourdomain.com | Select-Object -ExpandProperty Id
```

For groups:
```powershell
Get-AzADGroup -DisplayName "GroupName" | Select-Object -ExpandProperty Id
```

## Troubleshooting

If you encounter errors like:

```
"Code":"BadRequest","Message":"The principal with objectId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' was not found in tenant 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'."
```

This indicates that the Object ID provided doesn't exist in your Azure tenant. Make sure to:

1. Use the correct Object ID for users or groups
2. Ensure the user or group exists in the same tenant as your Azure subscription
3. Check for typos in the Object ID
