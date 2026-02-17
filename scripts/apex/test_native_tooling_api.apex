// Test Native Archive Policy Creation via Tooling API
// This tests the complete end-to-end flow

System.debug('========================================');
System.debug('TEST: NATIVE ARCHIVE VIA TOOLING API');
System.debug('========================================\n');

// Test: Create Archive Policy
System.debug('=== Creating Archive Policy for Closed Cases ===\n');

AgentAction_CreateNativeArchivePolicy.Request req = new AgentAction_CreateNativeArchivePolicy.Request();
req.policyName = 'Test Archive Closed Cases';
req.targetObject = 'Case';
req.retentionDays = 365;
req.additionalConditions = 'Status = \'Closed\'';
req.runFrequency = 'Monthly';
req.description = 'Test policy to archive closed cases older than 1 year';

List<AgentAction_CreateNativeArchivePolicy.Response> responses = 
    AgentAction_CreateNativeArchivePolicy.createArchivePolicy(
        new List<AgentAction_CreateNativeArchivePolicy.Request>{req}
    );

AgentAction_CreateNativeArchivePolicy.Response res = responses[0];

if (res.isSuccess) {
    System.debug('✓ Policy Creation Initiated!\n');
    System.debug('Developer Name: ' + res.developerName);
    System.debug('Query Preview: ' + res.queryPreview);
    System.debug('\n' + res.message);
    System.debug('\n========================================');
    System.debug('NEXT STEPS');
    System.debug('========================================');
    System.debug('1. Wait 30-60 seconds for async deployment');
    System.debug('2. Check Setup → Archive Policies');
    System.debug('3. Or run: sf apex run --file scripts/apex/list_archive_policies.apex');
    System.debug('4. Look for policy: ' + req.policyName);
} else {
    System.debug('✗ Policy Creation Failed:\n');
    System.debug(res.message);
    System.debug('\n========================================');
    System.debug('TROUBLESHOOTING');
    System.debug('========================================');
    System.debug('Check:');
    System.debug('1. Remote Site Setting exists: Setup → Security → Remote Site Settings');
    System.debug('2. Look for "SalesforceToolingAPI"');
    System.debug('3. URL should be: https://ebikes3.demo.my.salesforce.com');
    System.debug('4. Active checkbox should be checked');
}

System.debug('\n========================================');
System.debug('COMPLETE!');
System.debug('========================================');
