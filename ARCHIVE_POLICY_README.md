# Create Archive Policy - Apex Action for SF_Archiver

This Apex action automates the creation of archive policies for **SF_Archiver** (Salesforce native archiving). It allows users to quickly set up archiving rules without manually configuring them in the SF_Archiver interface.

## Overview

The `AgentAction_CreateArchivePolicy` class is an invocable Apex action that can be used in:
- Agentforce Actions
- Flow Builder
- Process Builder
- API calls

## Prerequisites

1. **SF_Archiver**: SF_Archiver (Salesforce native archiving) must be enabled in your org
2. **Permissions**: Users must have permission to create archive policy records (SF_Archiver)

## Features

✅ Creates archive policies programmatically
✅ Validates input parameters
✅ Checks if target object exists
✅ Sets policy to active immediately
✅ Generates descriptive error messages
✅ Supports multiple policies in batch

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| **Policy Name** | String | Yes | Name of the new archive policy |
| **Object to Archive** | String | Yes | API Name of the object (e.g., `Case`, `Account`, `Opportunity`) |
| **Retention Days** | Integer | Yes | Archive records older than this many days (must be > 0) |
| **Description** | String | No | Optional description for the policy |

## Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| **Success Message** | String | Result message with details or error information |
| **Policy ID** | String | ID of the created policy (null if failed) |
| **Is Success** | Boolean | Whether the operation was successful |

## Usage Examples

### Example 1: Archive Old Cases
```
Policy Name: "Archive Closed Cases Over 1 Year"
Object to Archive: "Case"
Retention Days: 365
Description: "Archives closed cases older than 1 year"
```

This will create a policy that archives all Case records where `CreatedDate < LAST_N_DAYS:365`.

### Example 2: Archive Old Accounts
```
Policy Name: "Archive Inactive Accounts"
Object to Archive: "Account"
Retention Days: 1825
Description: "Archives accounts older than 5 years"
```

### Example 3: Archive Custom Objects
```
Policy Name: "Archive Old Payment Records"
Object to Archive: "Payment__c"
Retention Days: 730
Description: "Archives payment records older than 2 years"
```

## How It Works

1. **Input Validation**: Checks that all required fields are provided and valid
2. **Object Verification**: Confirms the target object exists in the org
3. **Query Generation**: Creates a SOQL query: `SELECT Id FROM [Object] WHERE CreatedDate < LAST_N_DAYS:[Days]`
4. **Policy Creation**: Dynamically creates the SF_Archiver archive policy record
5. **Activation**: Sets the policy to active immediately
6. **Response**: Returns success/failure message with details

## Query Format

The action generates queries in the format expected by SF_Archiver:

```sql
SELECT Id FROM [ObjectName] WHERE CreatedDate < LAST_N_DAYS:[RetentionDays]
```

For example:
- `SELECT Id FROM Case WHERE CreatedDate < LAST_N_DAYS:365`
- `SELECT Id FROM Account WHERE CreatedDate < LAST_N_DAYS:1825`

## Setting Up in Agentforce

1. **Create an Agent Action**:
   - Go to Setup → Agent Actions
   - Click "New"
   - Select "Apex Action"
   - Choose `AgentAction_CreateArchivePolicy.createArchivePolicy`

2. **Configure the Action**:
   - Name: "Create Archive Policy"
   - Description: "Creates an automated archive policy for a Salesforce object"
   - Add to your Agentforce agent

3. **Test the Action**:
   - Open the agent in the Agent Builder
   - Ask: "Create an archive policy for Cases older than 365 days"
   - The agent will use the action to create the policy automatically

## Error Handling

The action includes comprehensive error handling for:

❌ Missing or invalid policy name
❌ Missing or invalid object name
❌ Invalid retention days (< 1)
❌ Non-existent object
❌ SF_Archiver not enabled
❌ Permission issues

Error messages are user-friendly and include guidance on how to resolve issues.

## Testing

A comprehensive test class `AgentAction_CreateArchivePolicy_Test` is included with 6 test methods covering:

- ✅ Successful policy creation
- ✅ Policy creation without description (auto-generated)
- ✅ Invalid object handling
- ✅ Invalid retention days handling
- ✅ Empty policy name handling
- ✅ Multiple policies in batch

To run tests:
```bash
sf apex run test --class-names AgentAction_CreateArchivePolicy_Test --result-format human --detailed
```

## Files Included

- `AgentAction_CreateArchivePolicy.cls` - Main Apex class
- `AgentAction_CreateArchivePolicy.cls-meta.xml` - Metadata file
- `AgentAction_CreateArchivePolicy_Test.cls` - Test class
- `AgentAction_CreateArchivePolicy_Test.cls-meta.xml` - Test metadata

## Customization

If you need to customize the query logic, edit the query generation section in the `createArchivePolicy` method:

```apex
String query = 'SELECT Id FROM ' + req.targetObject + 
              ' WHERE CreatedDate < LAST_N_DAYS:' + req.retentionDays;
```

You can modify this to support:
- Different date fields (e.g., `LastModifiedDate`)
- Additional WHERE conditions
- Status-based filtering (e.g., `Status = 'Closed'`)

## Support

For issues or questions:
1. Check that SF_Archiver is enabled: Setup → Archive Policies / SF_Archiver
2. Verify object API names: Setup → Object Manager
3. Check user permissions for archive policy creation
4. Review debug logs for detailed error information

## Version History

- **v1.0** (2026-02-02): Initial release with SF_Archiver support

## Related Files

- `AgentAction_GetStorageLimits.cls` - Get org storage information
- `AgentAction_FindLargeFiles.cls` - Find largest files consuming storage
- `AgentAction_TopStorageConsumers.cls` - Identify top storage consumers

These actions work together to create a complete Data Stewardship solution in Agentforce.
