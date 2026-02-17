# Quick Setup Guide: Create Archive Policy Action in Agentforce

This guide walks you through setting up the Create Archive Policy action in your Agentforce agent.

## Step 1: Create the Agent Action

1. Go to **Setup** → **Agent Actions**
2. Click **New**
3. Fill in the details:
   - **Name**: `Create Archive Policy`
   - **API Name**: `Create_Archive_Policy`
   - **Type**: Select **Apex Action**
   - **Apex Class**: Select `AgentAction_CreateArchivePolicy`
   - **Apex Method**: Select `createArchivePolicy`
   - **Description**: 
     ```
     Creates an automated archive policy for a Salesforce object using Own Archive. 
     Specify the object name, retention period in days, and policy name to automatically 
     set up archiving rules.
     ```

4. Click **Save**

## Step 2: Configure Action Instructions

Add these instructions to help the agent understand when and how to use this action:

```
Use this action to create archive policies for Salesforce objects. 

When to use:
- User wants to archive old records
- User mentions data retention or archiving
- User wants to free up storage space
- User asks to set up automatic archiving

Required information:
- Object Name: The Salesforce object to archive (e.g., Case, Account, Opportunity)
- Retention Days: How many days to keep records before archiving
- Policy Name: A descriptive name for the policy

Example prompts:
- "Archive cases older than 365 days"
- "Create an archive policy for old accounts"
- "Set up archiving for opportunities from more than 2 years ago"

Input mapping:
- policyName: Create a descriptive name like "Archive Old [Object] Records"
- targetObject: Use the API name of the object (Case, Account, Custom__c)
- retentionDays: Convert years/months to days (1 year = 365 days, 2 years = 730 days)
- description: Provide a clear description of what the policy does

Always confirm the object name and retention period with the user before creating the policy.
```

## Step 3: Add Action to Your Agent

1. Go to **Setup** → **Agents** or open **Agent Builder**
2. Select your Data Steward agent (or create a new one)
3. Go to the **Actions** tab
4. Click **Add Action**
5. Search for and select `Create Archive Policy`
6. Click **Save**

## Step 4: Test the Action

Test the action with these example prompts:

### Example 1: Basic Archive Policy
**Prompt**: "Create an archive policy to archive cases older than 1 year"

**Expected Behavior**: 
- Agent asks for policy name or suggests one
- Agent creates policy with 365 retention days
- Agent confirms creation with policy ID

### Example 2: Custom Object
**Prompt**: "I need to archive Payment__c records older than 2 years"

**Expected Behavior**:
- Agent converts 2 years to 730 days
- Agent creates policy for Payment__c
- Agent confirms with details

### Example 3: Multiple Objects
**Prompt**: "Set up archiving for old accounts and old opportunities, both older than 18 months"

**Expected Behavior**:
- Agent creates two separate policies
- Uses 547 days (18 months ≈ 547 days)
- Confirms both policy creations

## Step 5: Set Up Topic or Classification (Optional)

To help the agent recognize archive-related requests:

1. In Agent Builder, go to **Topics**
2. Create a new topic: **Data Archiving**
3. Add sample utterances:
   - "Archive old records"
   - "Create archive policy"
   - "Set up data archiving"
   - "Archive cases/accounts/opportunities"
   - "Free up storage by archiving"
4. Link the `Create Archive Policy` action to this topic

## Agent Prompt Enhancement

Add this to your agent's system instructions:

```
You are a Data Steward agent specialized in helping users manage Salesforce data storage 
and archiving. 

When users ask about archiving:
1. Understand which object they want to archive
2. Determine the retention period (how old records should be before archiving)
3. Suggest a clear policy name
4. Use the Create Archive Policy action to create the policy
5. Confirm the policy was created and explain what it does

Remember:
- 1 year = 365 days
- 2 years = 730 days
- 5 years = 1825 days
- 6 months = 180 days

Always verify the object name exists and confirm retention period before creating policies.
```

## Testing Checklist

- [ ] Action appears in Agent Builder
- [ ] Agent recognizes archiving requests
- [ ] Agent asks for missing information (object name, retention days)
- [ ] Agent creates policy successfully
- [ ] Agent provides confirmation with policy ID
- [ ] Error handling works for invalid inputs
- [ ] Policy appears in Own Archive interface

## Verification

After the agent creates a policy, verify it in Salesforce:

1. Go to **Own Archive** app
2. Click on **Policies** tab
3. Find the newly created policy
4. Verify:
   - Policy is Active
   - Query is correct
   - Object name is correct
   - Policy name matches

## Common Issues & Solutions

### Issue 1: "Own Archive package not installed"
**Solution**: Install the Own Archive (OB_Archiver) managed package from AppExchange

### Issue 2: "Permission denied"
**Solution**: Grant the user/agent permission to create `OB_Archiver__ArchivingPolicy__c` records

### Issue 3: "Object does not exist"
**Solution**: Verify the object API name is correct (use Setup → Object Manager)

### Issue 4: Agent doesn't recognize archive requests
**Solution**: Add more training utterances or update agent instructions

## Integration with Other Actions

Combine with other Data Steward actions:

1. **Get Storage Limits** → Identify storage issues
2. **Find Large Files** → Identify storage consumers  
3. **Top Storage Consumers** → Find objects to archive
4. **Create Archive Policy** → Set up automated archiving

Example conversation flow:
```
User: "Why is my storage full?"
Agent: Uses Get Storage Limits → Shows 95% full

Agent: "Would you like me to find what's using the most space?"
User: "Yes"
Agent: Uses Top Storage Consumers → Shows Cases consuming 45%

Agent: "Would you like to archive old cases?"
User: "Yes, archive cases older than 1 year"
Agent: Uses Create Archive Policy → Creates policy

Agent: "✓ Archive policy created! Cases older than 365 days will be archived."
```

## Next Steps

1. ✅ Deploy the Apex classes (Already done!)
2. ✅ Create the Agent Action (Follow Step 1)
3. ✅ Add to your agent (Follow Step 2-3)
4. ✅ Test with sample prompts (Follow Step 4)
5. ✅ Monitor and refine based on user feedback

## Support

For questions or issues, refer to:
- Main documentation: `ARCHIVE_POLICY_README.md`
- Debug logs: Setup → Debug Logs
- Own Archive documentation: Own Archive Help Center
- Test class: `AgentAction_CreateArchivePolicy_Test.cls`

---

**Version**: 1.0  
**Last Updated**: 2026-02-02
