// Test Script: List Archive Policies
// Run this in Developer Console or via: sf apex run --file scripts/apex/test_list_policies.apex

System.debug('========================================');
System.debug('TEST: List Archive Policies Action');
System.debug('========================================\n');

// Test 1: List all policies
System.debug('=== TEST 1: List All Policies ===');
AgentAction_ListArchivePolicies.Request req1 = new AgentAction_ListArchivePolicies.Request();
req1.activeOnly = null;
req1.objectFilter = null;
req1.sortOrder = 'created';

List<AgentAction_ListArchivePolicies.Response> responses1 = 
    AgentAction_ListArchivePolicies.listPolicies(
        new List<AgentAction_ListArchivePolicies.Request>{ req1 }
    );

System.debug('Success: ' + responses1[0].isSuccess);
System.debug('Total Count: ' + responses1[0].totalCount);
System.debug('Active Count: ' + responses1[0].activeCount);
System.debug('Inactive Count: ' + responses1[0].inactiveCount);
System.debug('Has Policies: ' + responses1[0].hasPolicies);
System.debug('\nFormatted Output:\n' + responses1[0].policyList);

// Test 2: List active policies only
System.debug('\n\n=== TEST 2: List Active Policies Only ===');
AgentAction_ListArchivePolicies.Request req2 = new AgentAction_ListArchivePolicies.Request();
req2.activeOnly = true;

List<AgentAction_ListArchivePolicies.Response> responses2 = 
    AgentAction_ListArchivePolicies.listPolicies(
        new List<AgentAction_ListArchivePolicies.Request>{ req2 }
    );

System.debug('\nActive Policies:\n' + responses2[0].policyList);

// Test 3: Filter by specific object
System.debug('\n\n=== TEST 3: Filter by Object (Case) ===');
AgentAction_ListArchivePolicies.Request req3 = new AgentAction_ListArchivePolicies.Request();
req3.objectFilter = 'Case';

List<AgentAction_ListArchivePolicies.Response> responses3 = 
    AgentAction_ListArchivePolicies.listPolicies(
        new List<AgentAction_ListArchivePolicies.Request>{ req3 }
    );

System.debug('\nCase Policies:\n' + responses3[0].policyList);

// Test 4: Sort by name
System.debug('\n\n=== TEST 4: Sort by Name ===');
AgentAction_ListArchivePolicies.Request req4 = new AgentAction_ListArchivePolicies.Request();
req4.sortOrder = 'name';

List<AgentAction_ListArchivePolicies.Response> responses4 = 
    AgentAction_ListArchivePolicies.listPolicies(
        new List<AgentAction_ListArchivePolicies.Request>{ req4 }
    );

System.debug('\nSorted by Name:\n' + responses4[0].policyList);

// Test 5: Sort by object
System.debug('\n\n=== TEST 5: Sort by Object ===');
AgentAction_ListArchivePolicies.Request req5 = new AgentAction_ListArchivePolicies.Request();
req5.sortOrder = 'object';

List<AgentAction_ListArchivePolicies.Response> responses5 = 
    AgentAction_ListArchivePolicies.listPolicies(
        new List<AgentAction_ListArchivePolicies.Request>{ req5 }
    );

System.debug('\nSorted by Object:\n' + responses5[0].policyList);

System.debug('\n========================================');
System.debug('ALL TESTS COMPLETED');
System.debug('========================================');
