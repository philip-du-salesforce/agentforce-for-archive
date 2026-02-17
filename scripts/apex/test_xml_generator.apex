// Test XML Generator for Native Archive Policies

System.debug('========================================');
System.debug('TEST: XML GENERATOR FOR NATIVE ARCHIVE');
System.debug('========================================\n');

// Create test request
AgentAction_GenerateArchivePolicyXML.Request req = new AgentAction_GenerateArchivePolicyXML.Request();
req.policyName = 'Archive Closed Cases Older Than 1 Year';
req.targetObject = 'Case';
req.retentionDays = 365;
req.additionalConditions = 'Status = \'Closed\'';
req.runFrequency = 'Monthly';
req.description = 'Automatically archives closed cases older than 1 year';

// Generate the archive policy
List<AgentAction_GenerateArchivePolicyXML.Response> responses = 
    AgentAction_GenerateArchivePolicyXML.generateArchivePolicy(
        new List<AgentAction_GenerateArchivePolicyXML.Request>{req}
    );

AgentAction_GenerateArchivePolicyXML.Response res = responses[0];

if (res.isSuccess) {
    System.debug('✓ Archive Policy XML Generated Successfully!\n');
    System.debug('Developer Name: ' + res.developerName);
    System.debug('File Path: ' + res.filePath);
    System.debug('Query Preview: ' + res.queryPreview);
    System.debug('\n========================================');
    System.debug('USER MESSAGE (What Einstein would say):');
    System.debug('========================================\n');
    System.debug(res.message);
    System.debug('\n========================================');
    System.debug('XML CONTENT:');
    System.debug('========================================\n');
    System.debug(res.xmlContent);
    System.debug('\n========================================');
    System.debug('DEPLOYMENT COMMANDS:');
    System.debug('========================================\n');
    System.debug(res.deploymentCommands);
} else {
    System.debug('✗ Generation Failed:\n');
    System.debug(res.message);
}

System.debug('\n========================================');
System.debug('TEST COMPLETE!');
System.debug('========================================');
