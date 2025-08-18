# Summary of PostgreSQL Azure AD Administrator Changes

## Problem
The PostgreSQL module was using an incorrect approach to create Azure AD administrators for the PostgreSQL Flexible Server. It was using the `guid()` function to generate administrator resource names, rather than using the actual Azure AD Object IDs of the administrators. This caused deployment failures when the generated GUIDs didn't match existing Azure AD users.

## Solution Implemented
1. Updated the `common.bicep` types file to include:
   - New `azureAdAdminType` with `objectId`, `principalName`, and `principalType` properties
   - Updated `postgresConfigType` to include both the new `azureAdAdministrators` array and the legacy `azureAdAdminUsers` for backward compatibility

2. Updated the `postgres.bicep` module to:
   - Accept the new `azureAdAdministrators` parameter
   - Maintain support for the legacy approach through `azureAdAdminUsers`
   - Implement a more robust deployment that uses actual Object IDs for the administrators

3. Updated the `main.bicep` file to pass both administrator parameters to the PostgreSQL module

4. Updated the `main.bicepparam` file with an example of the new approach, demonstrating how to properly specify Azure AD administrators with Object IDs

5. Created a documentation file (`postgres-azure-ad-admins.md`) explaining:
   - The changes made to the PostgreSQL module
   - How to properly configure Azure AD administrators
   - How to find Azure AD Object IDs using different methods
   - Troubleshooting tips for common issues

6. Updated the infrastructure README.md to include a reference to the new documentation

## How to Use
Users now have two options for configuring Azure AD administrators:

1. **Recommended Approach**: Use the `azureAdAdministrators` parameter with objects containing:
   - `objectId`: The Azure AD Object ID of the administrator
   - `principalName`: The email/UPN of the administrator
   - `principalType`: 'User' or 'Group' (defaults to 'User' if not specified)

2. **Legacy Approach (Deprecated)**: Continue using the `azureAdAdminUsers` parameter with an array of principal names/emails, but this may cause deployment failures

## Verification
The Bicep template has been verified to compile successfully with the new changes. The expected warnings about using preview API versions are present but won't affect deployment.

## Next Steps
1. Test the deployment with actual Azure AD user Object IDs
2. Consider removing the legacy approach in a future release once all deployments have been updated
