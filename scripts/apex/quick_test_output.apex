// Quick test to see the proper formatted output
AgentAction_CreateArchivePolicy.Request req = new AgentAction_CreateArchivePolicy.Request();
req.policyName = 'Test Contact Archive Policy';
req.targetObject = 'Contact';
req.retentionDays = 365;

List<AgentAction_CreateArchivePolicy.Response> responses = 
    AgentAction_CreateArchivePolicy.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy.Request>{ req }
    );

System.debug('=== FORMATTED MESSAGE (What user should see) ===');
System.debug(responses[0].message);

System.debug('\n=== POLICY URL ===');
System.debug(responses[0].policyUrl);

System.debug('\n=== POLICY SUMMARY ===');
System.debug(responses[0].policySummary);
