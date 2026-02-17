# Agentforce for Archive POC

A Salesforce proof-of-concept for automated data stewardship and storage management using Agentforce and **SF_Archiver** (Salesforce native archiving).

## Overview

This project provides Apex actions that enable Agentforce agents to help users manage Salesforce data storage, identify storage consumers, and work with archive policies. It integrates with **SF_Archiver** for intelligent data lifecycle management.

## Agent Actions (6)

All six agent actions and the topics they support:

### 1. Get Storage Limits (`AgentAction_GetStorageLimits`)
- View current storage usage (Data and File storage)
- Monitor available storage capacity
- Get alerts when approaching limits  
- **Topic:** Storage & Capacity

### 2. Find Large Files (`AgentAction_FindLargeFiles`)
- Identify the largest files in your org
- See file sizes and types
- Discover storage optimization opportunities  
- **Topic:** Storage & Capacity

### 3. Top Storage Consumers (`AgentAction_TopStorageConsumers`)
- Identify which objects consume the most storage
- Analyze storage distribution across objects
- Prioritize archiving candidates  
- **Topic:** Storage & Capacity

### 4. Create Archive Policy (`AgentAction_CreateArchivePolicy`)
- Create archive policies for Salesforce objects using SF_Archiver
- Set retention rules and policy names
- Validate objects and parameters; batch create multiple policies  
- **Topic:** Archive & Retention

### 5. List Archive Policies
- List existing SF_Archiver archive policies in the org
- See policy names, objects, and status  
- **Topic:** Archive & Retention

### 6. Guide Archive Policy Creation
- Guides users step-by-step to create archive policies in the SF_Archiver UI
- No programmatic policy creation; uses native SF_Archiver flows  
- **Topic:** Archive & Retention

## Topics

| Topic | Purpose | Linked Actions |
|-------|---------|----------------|
| **Storage & Capacity** | Storage limits, large files, top consumers | Get Storage Limits, Find Large Files, Top Storage Consumers |
| **Archive & Retention** | Create/list policies, guide users to SF_Archiver | Create Archive Policy, List Archive Policies, Guide Archive Policy Creation |

## Prerequisites

- Salesforce org with API access
- **SF_Archiver** enabled (Salesforce native archiving)
- Agentforce enabled in your org
- Appropriate user permissions for:
  - Creating and viewing archive policies (SF_Archiver)
  - Querying ContentDocument
  - Viewing storage limits

## Installation

### 1. Deploy the Apex Classes

```bash
# Clone or download this repository
cd agentforce-for-archive

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

**Archive (SF_Archiver):**
```
User: "Archive cases older than 1 year"
Agent: [Uses Create Archive Policy] 
       "✓ Created policy 'Archive Old Cases' for Case records older than 365 days"

User: "List my archive policies"
Agent: [Uses List Archive Policies] Shows existing SF_Archiver policies

User: "How do I create an archive policy?"
Agent: [Uses Guide Archive Policy Creation] Walks user through SF_Archiver UI
```

## Project Structure

```
agentforce-for-archive/
├── force-app/main/default/
│   └── classes/
│       ├── AgentAction_CreateArchivePolicy.cls          # Create archive policy (SF_Archiver)
│       ├── AgentAction_CreateArchivePolicy_Test.cls
│       ├── AgentAction_GetStorageLimits.cls             # Storage limits
│       ├── AgentAction_GetStorageLimits_Test.cls
│       ├── AgentAction_FindLargeFiles.cls              # Find large files
│       ├── AgentAction_FindLargeFiles_Test.cls
│       ├── AgentAction_TopStorageConsumers.cls         # Top storage consumers
│       └── AgentAction_TopStorageConsumers_Test.cls
├── scripts/apex/
│   └── test_archive_policy.apex                         # Test script
├── ARCHIVE_POLICY_README.md                             # Archive policy (SF_Archiver) docs
├── AGENTFORCE_SETUP_GUIDE.md                            # Agent actions & topics setup
└── README.md                                            # This file
```

## Documentation

- **[ARCHIVE_POLICY_README.md](./ARCHIVE_POLICY_README.md)** - Create Archive Policy action (SF_Archiver)
- **[AGENTFORCE_SETUP_GUIDE.md](./AGENTFORCE_SETUP_GUIDE.md)** - Set up all 6 agent actions and topics

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

### SF_Archiver

Archive actions use **SF_Archiver** (Salesforce native archiving):

1. Enable SF_Archiver in your org (Setup → Archive Policies / SF_Archiver)
2. Configure retention and storage as needed
3. Grant users/agents permission to create and view archive policies

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

### "SF_Archiver not available"
- Enable SF_Archiver in your org (Setup)
- Verify archive policies are available in your edition

### "Permission denied"
- Grant create/view permission for archive policies (SF_Archiver)
- Assign appropriate permission sets for the agent

### "Object does not exist"
- Verify object API name in Setup → Object Manager
- Use exact API names including namespace and `__c` suffix

### Agent not recognizing requests
- Add more training utterances in Agent Builder
- Update agent system instructions
- Use topics: **Storage & Capacity** and **Archive & Retention** with the 6 actions linked

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

- **Documentation**: See ARCHIVE_POLICY_README.md and AGENTFORCE_SETUP_GUIDE.md
- **Test Scripts**: Use scripts in `scripts/apex/` for testing
- **Debug Logs**: Enable debug logs for troubleshooting
- **SF_Archiver**: Use Salesforce help for SF_Archiver and archive policies

## Version History

- **v1.0** (2026-02-02)
  - Initial release
  - Six agent actions: Get Storage Limits, Find Large Files, Top Storage Consumers, Create Archive Policy, List Archive Policies, Guide Archive Policy Creation
  - Topics: Storage & Capacity, Archive & Retention
  - SF_Archiver integration (no Own Archive / OB_Archiver)

## License

This project is provided as-is for use with Salesforce and Agentforce.

## Related Resources

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Agentforce Documentation](https://help.salesforce.com/s/articleView?id=sf.agentforce.htm)
- [Salesforce Archiving (SF_Archiver)](https://help.salesforce.com/) — native archive policies
