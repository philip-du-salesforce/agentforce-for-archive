// Save and Deploy Archive Policy - Helper Script
// This demonstrates creating a policy and saving the XML for deployment

System.debug('========================================');
System.debug('GENERATE NATIVE ARCHIVE POLICY');
System.debug('========================================\n');

// Create policy request
AgentAction_CreateArchivePolicy_Native.Request req = new AgentAction_CreateArchivePolicy_Native.Request();
req.policyName = 'Archive Closed Cases Older Than 1 Year';
req.targetObject = 'Case';
req.retentionDays = 365;
req.additionalConditions = 'Status = \'Closed\'';
req.runFrequency = 'Monthly';
req.description = 'Archives closed cases older than 1 year to free up storage space';

// Generate the policy
List<AgentAction_CreateArchivePolicy_Native.Response> responses = 
    AgentAction_CreateArchivePolicy_Native.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy_Native.Request>{req}
    );

AgentAction_CreateArchivePolicy_Native.Response res = responses[0];

if (res.isSuccess) {
    System.debug('✓ Policy Generated Successfully!\n');
    System.debug(res.message);
    System.debug('\n\n========================================');
    System.debug('GENERATED XML CONTENT');
    System.debug('========================================\n');
    System.debug(res.xmlContent);
    System.debug('\n\n========================================');
    System.debug('SAVE THIS XML TO:');
    System.debug('========================================');
    System.debug('force-app/main/default/archivePolicies/' + res.developerName + '.archivePolicy-meta.xml');
    System.debug('\n\n========================================');
    System.debug('DEPLOYMENT COMMAND');
    System.debug('========================================');
    System.debug(res.deploymentCommand);
} else {
    System.debug('✗ Policy Generation Failed:\n');
    System.debug(res.message);
}

System.debug('\n\n========================================');
System.debug('COMPLETE!');
System.debug('========================================');
