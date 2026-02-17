// Enhanced Test: Create Archive Policy with URL and Summary
// Run this in Developer Console or via: sf apex run --file scripts/apex/test_enhanced_create_policy.apex

System.debug('========================================');
System.debug('TEST: Enhanced Create Archive Policy');
System.debug('========================================\n');

// Create a test policy
AgentAction_CreateArchivePolicy.Request req = new AgentAction_CreateArchivePolicy.Request();
req.policyName = 'Test Enhanced Policy - Opportunity';
req.targetObject = 'Opportunity';
req.retentionDays = 730; // 2 years
req.description = 'Archives old opportunities to free up storage space';

List<AgentAction_CreateArchivePolicy.Request> requests = 
    new List<AgentAction_CreateArchivePolicy.Request>{ req };

System.debug('Creating policy...\n');

List<AgentAction_CreateArchivePolicy.Response> responses = 
    AgentAction_CreateArchivePolicy.createArchivePolicy(requests);

AgentAction_CreateArchivePolicy.Response res = responses[0];

System.debug('=== RESULTS ===\n');
System.debug('Success: ' + res.isSuccess);
System.debug('Policy ID: ' + res.policyId);
System.debug('Policy URL: ' + res.policyUrl);

System.debug('\n=== USER MESSAGE ===\n');
System.debug(res.message);

System.debug('\n=== POLICY SUMMARY ===\n');
System.debug(res.policySummary);

// Clean up - delete the test policy
if (res.isSuccess) {
    try {
        Database.delete(res.policyId);
        System.debug('\n✓ Test policy cleaned up');
    } catch (Exception e) {
        System.debug('\n⚠ Could not clean up: ' + e.getMessage());
    }
}

System.debug('\n========================================');
System.debug('TEST COMPLETED');
System.debug('========================================');
