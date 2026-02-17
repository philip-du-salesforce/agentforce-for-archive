// Test Script: Create Archive Policy via Anonymous Apex
// Run this script in Developer Console → Debug → Open Execute Anonymous Window
// Or use: sf apex run --file scripts/apex/test_archive_policy.apex

// =============================================================================
// Example 1: Create a simple archive policy for Cases
// =============================================================================
System.debug('=== TEST 1: Create Archive Policy for Cases ===');

AgentAction_CreateArchivePolicy.Request req1 = new AgentAction_CreateArchivePolicy.Request();
req1.policyName = 'Archive Old Cases - Test';
req1.targetObject = 'Case';
req1.retentionDays = 365;
req1.description = 'Test policy to archive cases older than 1 year';

List<AgentAction_CreateArchivePolicy.Request> requests1 = new List<AgentAction_CreateArchivePolicy.Request>{ req1 };
List<AgentAction_CreateArchivePolicy.Response> responses1 = AgentAction_CreateArchivePolicy.createArchivePolicy(requests1);

for (AgentAction_CreateArchivePolicy.Response res : responses1) {
    System.debug('Success: ' + res.isSuccess);
    System.debug('Message: ' + res.message);
    System.debug('Policy ID: ' + res.policyId);
}

// =============================================================================
// Example 2: Create archive policy for Accounts (5 years retention)
// =============================================================================
System.debug('\n=== TEST 2: Create Archive Policy for Accounts ===');

AgentAction_CreateArchivePolicy.Request req2 = new AgentAction_CreateArchivePolicy.Request();
req2.policyName = 'Archive Old Accounts - 5 Years';
req2.targetObject = 'Account';
req2.retentionDays = 1825; // 5 years
req2.description = 'Archives inactive accounts older than 5 years';

List<AgentAction_CreateArchivePolicy.Request> requests2 = new List<AgentAction_CreateArchivePolicy.Request>{ req2 };
List<AgentAction_CreateArchivePolicy.Response> responses2 = AgentAction_CreateArchivePolicy.createArchivePolicy(requests2);

for (AgentAction_CreateArchivePolicy.Response res : responses2) {
    System.debug('Success: ' + res.isSuccess);
    System.debug('Message: ' + res.message);
    System.debug('Policy ID: ' + res.policyId);
}

// =============================================================================
// Example 3: Create policy for Custom Object
// =============================================================================
System.debug('\n=== TEST 3: Create Archive Policy for Custom Object ===');

AgentAction_CreateArchivePolicy.Request req3 = new AgentAction_CreateArchivePolicy.Request();
req3.policyName = 'Archive Old Payments';
req3.targetObject = 'Payment__c'; // Change to your custom object
req3.retentionDays = 730; // 2 years

List<AgentAction_CreateArchivePolicy.Request> requests3 = new List<AgentAction_CreateArchivePolicy.Request>{ req3 };
List<AgentAction_CreateArchivePolicy.Response> responses3 = AgentAction_CreateArchivePolicy.createArchivePolicy(requests3);

for (AgentAction_CreateArchivePolicy.Response res : responses3) {
    System.debug('Success: ' + res.isSuccess);
    System.debug('Message: ' + res.message);
    System.debug('Policy ID: ' + res.policyId);
}

// =============================================================================
// Example 4: Test error handling - Invalid object
// =============================================================================
System.debug('\n=== TEST 4: Error Handling - Invalid Object ===');

AgentAction_CreateArchivePolicy.Request req4 = new AgentAction_CreateArchivePolicy.Request();
req4.policyName = 'Test Invalid Object';
req4.targetObject = 'NonExistentObject__c';
req4.retentionDays = 365;

List<AgentAction_CreateArchivePolicy.Request> requests4 = new List<AgentAction_CreateArchivePolicy.Request>{ req4 };
List<AgentAction_CreateArchivePolicy.Response> responses4 = AgentAction_CreateArchivePolicy.createArchivePolicy(requests4);

for (AgentAction_CreateArchivePolicy.Response res : responses4) {
    System.debug('Success: ' + res.isSuccess);
    System.debug('Message: ' + res.message);
    System.debug('Policy ID: ' + res.policyId);
}

// =============================================================================
// Example 5: Test error handling - Invalid retention days
// =============================================================================
System.debug('\n=== TEST 5: Error Handling - Invalid Retention Days ===');

AgentAction_CreateArchivePolicy.Request req5 = new AgentAction_CreateArchivePolicy.Request();
req5.policyName = 'Test Invalid Retention';
req5.targetObject = 'Account';
req5.retentionDays = -100; // Negative number

List<AgentAction_CreateArchivePolicy.Request> requests5 = new List<AgentAction_CreateArchivePolicy.Request>{ req5 };
List<AgentAction_CreateArchivePolicy.Response> responses5 = AgentAction_CreateArchivePolicy.createArchivePolicy(requests5);

for (AgentAction_CreateArchivePolicy.Response res : responses5) {
    System.debug('Success: ' + res.isSuccess);
    System.debug('Message: ' + res.message);
    System.debug('Policy ID: ' + res.policyId);
}

// =============================================================================
// Example 6: Batch create multiple policies
// =============================================================================
System.debug('\n=== TEST 6: Batch Create Multiple Policies ===');

List<AgentAction_CreateArchivePolicy.Request> batchRequests = new List<AgentAction_CreateArchivePolicy.Request>();

// Policy 1: Cases
AgentAction_CreateArchivePolicy.Request batch1 = new AgentAction_CreateArchivePolicy.Request();
batch1.policyName = 'Batch - Archive Cases';
batch1.targetObject = 'Case';
batch1.retentionDays = 365;
batchRequests.add(batch1);

// Policy 2: Opportunities
AgentAction_CreateArchivePolicy.Request batch2 = new AgentAction_CreateArchivePolicy.Request();
batch2.policyName = 'Batch - Archive Opportunities';
batch2.targetObject = 'Opportunity';
batch2.retentionDays = 730;
batchRequests.add(batch2);

// Policy 3: Leads
AgentAction_CreateArchivePolicy.Request batch3 = new AgentAction_CreateArchivePolicy.Request();
batch3.policyName = 'Batch - Archive Leads';
batch3.targetObject = 'Lead';
batch3.retentionDays = 180;
batchRequests.add(batch3);

List<AgentAction_CreateArchivePolicy.Response> batchResponses = AgentAction_CreateArchivePolicy.createArchivePolicy(batchRequests);

Integer successCount = 0;
Integer failureCount = 0;

for (AgentAction_CreateArchivePolicy.Response res : batchResponses) {
    System.debug('---');
    System.debug('Success: ' + res.isSuccess);
    System.debug('Message: ' + res.message);
    System.debug('Policy ID: ' + res.policyId);
    
    if (res.isSuccess) {
        successCount++;
    } else {
        failureCount++;
    }
}

System.debug('\n=== BATCH SUMMARY ===');
System.debug('Total Policies: ' + batchResponses.size());
System.debug('Successful: ' + successCount);
System.debug('Failed: ' + failureCount);

// =============================================================================
// Query created policies (if Own Archive is installed)
// =============================================================================
System.debug('\n=== Querying Created Policies ===');

try {
    List<SObject> policies = Database.query(
        'SELECT Id, Name, OB_Archiver__Active__c, OB_Archiver__Query__c, CreatedDate ' +
        'FROM OB_Archiver__ArchivingPolicy__c ' +
        'WHERE CreatedDate = TODAY ' +
        'ORDER BY CreatedDate DESC ' +
        'LIMIT 10'
    );
    
    System.debug('Found ' + policies.size() + ' policies created today:');
    for (SObject policy : policies) {
        System.debug('- ' + policy.get('Name') + ' (Active: ' + policy.get('OB_Archiver__Active__c') + ')');
    }
} catch (Exception e) {
    System.debug('Could not query policies: ' + e.getMessage());
    System.debug('This is expected if Own Archive package is not installed.');
}

System.debug('\n=== ALL TESTS COMPLETED ===');
