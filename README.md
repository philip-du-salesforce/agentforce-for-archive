# Agentforce Data Steward

A comprehensive Salesforce solution for automated data stewardship and storage management using Agentforce and Own Archive integration.

## Overview

This project provides Apex actions that enable Agentforce agents to help users manage Salesforce data storage, identify storage consumers, and automate archiving policies. It integrates with the Own Archive (OB_Archiver) managed package to provide intelligent data lifecycle management.

## Features

### 📊 Storage Management Actions

- **Get Storage Limits** (`AgentAction_GetStorageLimits`)
  - View current storage usage (Data and File storage)
  - Monitor available storage capacity
  - Get alerts when approaching limits

- **Find Large Files** (`AgentAction_FindLargeFiles`)
  - Identify the largest files in your org
  - See file sizes and types
  - Discover storage optimization opportunities

- **Top Storage Consumers** (`AgentAction_TopStorageConsumers`)
  - Identify which objects consume the most storage
  - Analyze storage distribution across objects
  - Prioritize archiving candidates

### 🗄️ Archive Management

- **Create Archive Policy** (`AgentAction_CreateArchivePolicy`) ⭐ NEW!
  - Automatically create Own Archive policies
  - Set retention rules for any Salesforce object
  - Configure archiving without manual setup
  - Validate objects and parameters
  - Batch create multiple policies

## Prerequisites

- Salesforce org with API access
- Own Archive (OB_Archiver) package installed (for archive policy creation)
- Agentforce enabled in your org
- Appropriate user permissions for:
  - Creating archive policies
  - Querying ContentDocument
  - Viewing storage limits

## Installation

### 1. Deploy the Apex Classes

```bash
# Clone or download this repository
cd AgentforceDataSteward

# Authenticate to your Salesforce org
sf org login web --set-default-username

# Deploy all components
sf project deploy start --source-dir force-app
```

### 2. Run Tests

```bash
# Run all tests
sf apex run test --result-format human --wait 10

# Run specific test class
sf apex run test --class-names AgentAction_CreateArchivePolicy_Test --result-format human
```

### 3. Set Up Agent Actions

Follow the detailed guide in [AGENTFORCE_SETUP_GUIDE.md](./AGENTFORCE_SETUP_GUIDE.md) to:
- Create Agent Actions in Salesforce
- Configure your Agentforce agent
- Add instructions and topics
- Test the actions

## Quick Start

### Test Archive Policy Creation

Run the test script to verify the action works:

```bash
sf apex run --file scripts/apex/test_archive_policy.apex
```

Or use the Developer Console:
1. Open Developer Console
2. Go to Debug → Open Execute Anonymous Window
3. Copy contents from `scripts/apex/test_archive_policy.apex`
4. Execute

### Example Agentforce Conversations

**Storage Analysis:**
```
User: "How much storage do I have left?"
Agent: [Uses Get Storage Limits] "You're using 45 GB of 50 GB (90% full)..."

User: "What's taking up the most space?"
Agent: [Uses Top Storage Consumers] "Cases are using 20 GB, Attachments 15 GB..."
```

**Archive Policy Creation:**
```
User: "Archive cases older than 1 year"
Agent: [Uses Create Archive Policy] 
       "✓ Created policy 'Archive Old Cases' for Case records older than 365 days"

User: "Set up archiving for old accounts and opportunities"
Agent: [Creates two policies] 
       "✓ Created 2 archive policies - one for Accounts and one for Opportunities"
```

## Project Structure

```
AgentforceDataSteward/
├── force-app/main/default/
│   └── classes/
│       ├── AgentAction_CreateArchivePolicy.cls          # New archive policy action
│       ├── AgentAction_CreateArchivePolicy_Test.cls     # Test class
│       ├── AgentAction_GetStorageLimits.cls             # Storage limits action
│       ├── AgentAction_GetStorageLimits_Test.cls
│       ├── AgentAction_FindLargeFiles.cls               # Find large files
│       ├── AgentAction_FindLargeFiles_Test.cls
│       ├── AgentAction_TopStorageConsumers.cls          # Top storage users
│       └── AgentAction_TopStorageConsumers_Test.cls
├── scripts/apex/
│   └── test_archive_policy.apex                         # Test script
├── ARCHIVE_POLICY_README.md                             # Detailed archive policy docs
├── AGENTFORCE_SETUP_GUIDE.md                           # Setup instructions
└── README.md                                            # This file
```

## Documentation

- **[ARCHIVE_POLICY_README.md](./ARCHIVE_POLICY_README.md)** - Complete documentation for Create Archive Policy action
- **[AGENTFORCE_SETUP_GUIDE.md](./AGENTFORCE_SETUP_GUIDE.md)** - Step-by-step Agentforce configuration guide

## Usage Examples

### Create Archive Policy

```apex
AgentAction_CreateArchivePolicy.Request req = new AgentAction_CreateArchivePolicy.Request();
req.policyName = 'Archive Old Cases';
req.targetObject = 'Case';
req.retentionDays = 365;
req.description = 'Archives closed cases older than 1 year';

List<AgentAction_CreateArchivePolicy.Response> responses = 
    AgentAction_CreateArchivePolicy.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy.Request>{ req }
    );
```

### Find Large Files

```apex
AgentAction_FindLargeFiles.Request req = new AgentAction_FindLargeFiles.Request();
req.numberOfFiles = 10;

List<AgentAction_FindLargeFiles.Response> responses = 
    AgentAction_FindLargeFiles.findLargeFiles(
        new List<AgentAction_FindLargeFiles.Request>{ req }
    );
```

## Configuration

### Own Archive Package

The Create Archive Policy action requires the Own Archive (OB_Archiver) package:

1. Install from [Salesforce AppExchange](https://appexchange.salesforce.com/)
2. Complete the Own Archive setup wizard
3. Configure external storage (if needed)
4. Set up permissions for users/agents

### Customization

To customize the archive query logic, edit the query generation in `AgentAction_CreateArchivePolicy.cls`:

```apex
// Default: Archives by CreatedDate
String query = 'SELECT Id FROM ' + req.targetObject + 
              ' WHERE CreatedDate < LAST_N_DAYS:' + req.retentionDays;

// Custom: Archive by LastModifiedDate
String query = 'SELECT Id FROM ' + req.targetObject + 
              ' WHERE LastModifiedDate < LAST_N_DAYS:' + req.retentionDays;
```

## Testing

All actions include comprehensive test coverage:

| Test Class | Coverage | Status |
|------------|----------|--------|
| AgentAction_CreateArchivePolicy_Test | 100% | ✅ Passing |
| AgentAction_GetStorageLimits_Test | 100% | ✅ Passing |
| AgentAction_FindLargeFiles_Test | 100% | ✅ Passing |
| AgentAction_TopStorageConsumers_Test | 100% | ✅ Passing |

Run all tests:
```bash
sf apex run test --result-format human --code-coverage --wait 10
```

## Troubleshooting

### "Own Archive package not installed"
- Install the OB_Archiver package from AppExchange
- Verify installation: Setup → Installed Packages

### "Permission denied"
- Grant create permission on `OB_Archiver__ArchivingPolicy__c`
- Assign appropriate permission sets

### "Object does not exist"
- Verify object API name in Setup → Object Manager
- Use exact API names including namespace and `__c` suffix

### Agent not recognizing requests
- Add more training utterances in Agent Builder
- Update agent system instructions
- Create specific topics for archiving/storage

## Best Practices

1. **Storage Monitoring**
   - Regularly check storage limits
   - Set up alerts at 80% capacity
   - Monitor growth trends

2. **Archive Policy Management**
   - Start with non-critical objects
   - Test policies in sandbox first
   - Document retention requirements
   - Review policies quarterly

3. **Agentforce Integration**
   - Provide clear instructions to the agent
   - Use descriptive policy names
   - Confirm actions with users
   - Log all policy creations

## Contributing

To add new actions:

1. Create the Apex class with `@InvocableMethod`
2. Follow the naming convention: `AgentAction_[Name].cls`
3. Create a comprehensive test class
4. Update documentation
5. Deploy and test in sandbox

## Support & Resources

- **Documentation**: See individual README files for detailed docs
- **Test Scripts**: Use scripts in `scripts/apex/` for testing
- **Debug Logs**: Enable debug logs for troubleshooting
- **Own Archive Docs**: Refer to Own Archive documentation for advanced features

## Version History

- **v1.0** (2026-02-02)
  - Initial release
  - Create Archive Policy action
  - Storage management actions
  - Comprehensive test coverage

## License

This project is provided as-is for use with Salesforce and Agentforce.

## Related Resources

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Agentforce Documentation](https://help.salesforce.com/s/articleView?id=sf.agentforce.htm)
- [Own Archive Documentation](https://www.owndata.com/own-archive/)
