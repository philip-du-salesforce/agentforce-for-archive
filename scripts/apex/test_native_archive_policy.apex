// Test Salesforce Native Archive Policy Creation
// This demonstrates the new ArchivePolicyDefinition integration

System.debug('========================================');
System.debug('TEST: SALESFORCE NATIVE ARCHIVE POLICY');
System.debug('========================================\n');

// Test 1: Create Archive Policy for Closed Cases
System.debug('=== Test 1: Create Policy for Closed Cases ===\n');

AgentAction_CreateArchivePolicy_Enhanced.Request req1 = new AgentAction_CreateArchivePolicy_Enhanced.Request();
req1.policyName = 'Archive Closed Cases Older Than 1 Year';
req1.targetObject = 'Case';
req1.retentionDays = 365;
req1.additionalConditions = 'Status = \'Closed\'';
req1.runFrequency = 'Monthly';
req1.description = 'Archives closed cases older than 1 year to free up storage space';

List<AgentAction_CreateArchivePolicy_Enhanced.Response> responses1 = 
    AgentAction_CreateArchivePolicy_Enhanced.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy_Enhanced.Request>{req1}
    );

if (responses1[0].isSuccess) {
    System.debug('✓ Policy Created!');
    System.debug('Policy ID: ' + responses1[0].policyId);
    System.debug('Policy URL: ' + responses1[0].policyUrl);
    System.debug('\n' + responses1[0].message);
} else {
    System.debug('✗ Policy Creation Failed:');
    System.debug(responses1[0].message);
}

System.debug('\n\n========================================\n');

// Test 2: List Archive Policies
System.debug('=== Test 2: List All Archive Policies ===\n');

AgentAction_ListArchivePolicies.Request req2 = new AgentAction_ListArchivePolicies.Request();
req2.activeOnly = false;
req2.sortOrder = 'created';

List<AgentAction_ListArchivePolicies.Response> responses2 = 
    AgentAction_ListArchivePolicies.listPolicies(
        new List<AgentAction_ListArchivePolicies.Request>{req2}
    );

if (responses2[0].isSuccess) {
    System.debug('✓ Found ' + responses2[0].totalCount + ' policies');
    System.debug('\n' + responses2[0].policyList);
} else {
    System.debug('✗ List Policies Failed:');
    System.debug(responses2[0].message);
}

System.debug('\n\n========================================\n');

// Test 3: Query ArchivePolicyDefinition directly
System.debug('=== Test 3: Direct Query of ArchivePolicyDefinition ===\n');

List<ArchivePolicyDefinition> policies = [
    SELECT Id, MasterLabel, DeveloperName, IsActive, RootEntityName, Type, RunFrequency, Query
    FROM ArchivePolicyDefinition
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('Found ' + policies.size() + ' policies via direct query:\n');
for (ArchivePolicyDefinition policy : policies) {
    System.debug('• ' + policy.MasterLabel + ' (' + policy.DeveloperName + ')');
    System.debug('  Object: ' + policy.RootEntityName);
    System.debug('  Type: ' + policy.Type);
    System.debug('  Active: ' + policy.IsActive);
    System.debug('  Frequency: ' + policy.RunFrequency);
    System.debug('  Query: ' + policy.Query);
    System.debug('');
}

System.debug('\n========================================');
System.debug('ALL TESTS COMPLETE!');
System.debug('========================================');
System.debug('\nKey Changes from OB_Archiver:');
System.debug('✓ Using Salesforce native ArchivePolicyDefinition');
System.debug('✓ DeveloperName auto-generated from policy name');
System.debug('✓ Type set to "Archiving"');
System.debug('✓ RootEntityName specifies the object');
System.debug('✓ RunFrequency controls schedule (None, Daily, Weekly, Monthly)');
System.debug('✓ No ContentDocument archiving (native handles differently)');
