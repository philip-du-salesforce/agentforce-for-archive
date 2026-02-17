// Test Guided Archive Policy Creation

System.debug('========================================');
System.debug('TEST: GUIDED ARCHIVE POLICY CREATION');
System.debug('========================================\n');

// Create test request (simulating what Einstein would call)
AgentAction_GuideArchivePolicyCreation.Request req = new AgentAction_GuideArchivePolicyCreation.Request();
req.targetObject = 'Case';
req.retentionDays = 365;
req.additionalConditions = 'Status = \'Closed\'';
req.runFrequency = 'Monthly';
req.policyName = null; // Let it auto-generate

// Call the guide action
List<AgentAction_GuideArchivePolicyCreation.Response> responses = 
    AgentAction_GuideArchivePolicyCreation.guideCreation(
        new List<AgentAction_GuideArchivePolicyCreation.Request>{req}
    );

AgentAction_GuideArchivePolicyCreation.Response res = responses[0];

if (res.isSuccess) {
    System.debug('✓ Guide Generated Successfully!\n');
    System.debug('Suggested Policy Name: ' + res.suggestedPolicyName);
    System.debug('Setup URL: ' + res.setupUrl);
    System.debug('SOQL Query: ' + res.soqlQuery);
    System.debug('\n========================================');
    System.debug('EINSTEIN RESPONSE (What User Will See):');
    System.debug('========================================\n');
    System.debug(res.message);
} else {
    System.debug('✗ Guide Generation Failed:\n');
    System.debug(res.message);
}

System.debug('\n========================================');
System.debug('TEST COMPLETE!');
System.debug('========================================');
