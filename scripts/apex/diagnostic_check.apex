// ============================================================================
// DIAGNOSTIC SCRIPT: Check AgentAction_CreateArchivePolicy Visibility
// ============================================================================
// Run this in Developer Console → Debug → Open Execute Anonymous Window
// Or: sf apex run --file scripts/apex/diagnostic_check.apex

System.debug('========================================');
System.debug('DIAGNOSTIC: AgentAction_CreateArchivePolicy');
System.debug('========================================\n');

// TEST 1: Check if class exists
System.debug('TEST 1: Class Existence');
Type classType = Type.forName('AgentAction_CreateArchivePolicy');
if (classType != null) {
    System.debug('✓ Class EXISTS in org');
} else {
    System.debug('✗ Class NOT FOUND in org');
}

// TEST 2: Check if we can instantiate inner classes
System.debug('\nTEST 2: Inner Classes');
try {
    Type requestType = Type.forName('AgentAction_CreateArchivePolicy.Request');
    Type responseType = Type.forName('AgentAction_CreateArchivePolicy.Response');
    System.debug('✓ Request class: ' + (requestType != null ? 'EXISTS' : 'NOT FOUND'));
    System.debug('✓ Response class: ' + (responseType != null ? 'EXISTS' : 'NOT FOUND'));
} catch (Exception e) {
    System.debug('✗ Error accessing inner classes: ' + e.getMessage());
}

// TEST 3: Try to call the method directly
System.debug('\nTEST 3: Direct Method Call');
try {
    AgentAction_CreateArchivePolicy.Request req = new AgentAction_CreateArchivePolicy.Request();
    req.policyName = 'DIAGNOSTIC_TEST_POLICY';
    req.targetObject = 'Account';
    req.retentionDays = 365;
    req.description = 'This is a diagnostic test policy';
    
    List<AgentAction_CreateArchivePolicy.Request> requests = 
        new List<AgentAction_CreateArchivePolicy.Request>{ req };
    
    List<AgentAction_CreateArchivePolicy.Response> responses = 
        AgentAction_CreateArchivePolicy.createArchivePolicy(requests);
    
    System.debug('✓ Method CALLED successfully');
    System.debug('  - Success: ' + responses[0].isSuccess);
    System.debug('  - Message: ' + responses[0].message);
    
    if (responses[0].isSuccess) {
        System.debug('✓ TEST PASSED - Policy created with ID: ' + responses[0].policyId);
        
        // Clean up test policy
        try {
            Database.delete(responses[0].policyId);
            System.debug('  ✓ Test policy cleaned up');
        } catch (Exception cleanup) {
            System.debug('  ⚠ Could not clean up test policy: ' + cleanup.getMessage());
        }
    } else {
        System.debug('⚠ Method called but returned error');
    }
    
} catch (Exception e) {
    System.debug('✗ Error calling method: ' + e.getMessage());
    System.debug('  Stack trace: ' + e.getStackTraceString());
}

// TEST 4: Check Own Archive package
System.debug('\nTEST 4: Own Archive Package');
try {
    Schema.DescribeSObjectResult archivePolicyDescribe = 
        Schema.getGlobalDescribe().get('OB_Archiver__ArchivingPolicy__c').getDescribe();
    System.debug('✓ Own Archive object EXISTS');
    System.debug('  - Label: ' + archivePolicyDescribe.getLabel());
    System.debug('  - Is Custom: ' + archivePolicyDescribe.isCustom());
    
    // Check required fields
    Map<String, Schema.SObjectField> fieldMap = archivePolicyDescribe.fields.getMap();
    List<String> requiredFields = new List<String>{
        'OB_Archiver__Query__c',
        'OB_Archiver__Active__c',
        'OB_Archiver__Description__c'
    };
    
    for (String fieldName : requiredFields) {
        if (fieldMap.containsKey(fieldName)) {
            System.debug('  ✓ Field exists: ' + fieldName);
        } else {
            System.debug('  ✗ Field MISSING: ' + fieldName);
        }
    }
    
} catch (Exception e) {
    System.debug('✗ Own Archive package NOT FOUND or not accessible');
    System.debug('  Error: ' + e.getMessage());
    System.debug('  ⚠ You need to install Own Archive (OB_Archiver) package');
}

// TEST 5: Check user permissions
System.debug('\nTEST 5: User Permissions');
try {
    System.debug('✓ User ID: ' + UserInfo.getUserId());
    System.debug('  - Username: ' + UserInfo.getUserName());
    System.debug('  - Profile: ' + UserInfo.getProfileId());
    
    // Check if user can create policies
    Schema.DescribeSObjectResult policyDescribe = 
        Schema.getGlobalDescribe().get('OB_Archiver__ArchivingPolicy__c').getDescribe();
    
    System.debug('  - Can Create Policies: ' + policyDescribe.isCreateable());
    System.debug('  - Can Read Policies: ' + policyDescribe.isAccessible());
    System.debug('  - Can Update Policies: ' + policyDescribe.isUpdateable());
    
} catch (Exception e) {
    System.debug('⚠ Could not check permissions: ' + e.getMessage());
}

// TEST 6: Check API version
System.debug('\nTEST 6: API Version');
try {
    List<ApexClass> classes = [SELECT Id, Name, ApiVersion, Status 
                               FROM ApexClass 
                               WHERE Name = 'AgentAction_CreateArchivePolicy' 
                               LIMIT 1];
    
    if (!classes.isEmpty()) {
        System.debug('✓ Class found in metadata');
        System.debug('  - API Version: ' + classes[0].ApiVersion);
        System.debug('  - Status: ' + classes[0].Status);
        System.debug('  - Class ID: ' + classes[0].Id);
    } else {
        System.debug('✗ Class not found in ApexClass object');
    }
} catch (Exception e) {
    System.debug('⚠ Could not query ApexClass: ' + e.getMessage());
}

// TEST 7: Check for invocable methods
System.debug('\nTEST 7: Invocable Method Check');
try {
    // Query all invocable actions (if accessible)
    String query = 'SELECT Id, Name, Description FROM Action WHERE Name LIKE \'%Archive%\' LIMIT 10';
    List<SObject> actions = Database.query(query);
    
    if (!actions.isEmpty()) {
        System.debug('✓ Found ' + actions.size() + ' actions with "Archive" in name:');
        for (SObject action : actions) {
            System.debug('  - ' + action.get('Name'));
        }
    } else {
        System.debug('⚠ No actions found with "Archive" in name');
    }
} catch (Exception e) {
    System.debug('⚠ Could not query Action object: ' + e.getMessage());
    System.debug('  (This is expected in some orgs)');
}

// TEST 8: Org information
System.debug('\nTEST 8: Org Information');
try {
    System.debug('✓ Org ID: ' + UserInfo.getOrganizationId());
    System.debug('  - Org Name: ' + UserInfo.getOrganizationName());
    
    Organization org = [SELECT Id, Name, OrganizationType, IsSandbox 
                       FROM Organization 
                       LIMIT 1];
    System.debug('  - Org Type: ' + org.OrganizationType);
    System.debug('  - Is Sandbox: ' + org.IsSandbox);
    
} catch (Exception e) {
    System.debug('⚠ Could not get org info: ' + e.getMessage());
}

// FINAL SUMMARY
System.debug('\n========================================');
System.debug('DIAGNOSTIC SUMMARY');
System.debug('========================================');
System.debug('✓ = Test passed');
System.debug('⚠ = Warning or expected limitation');
System.debug('✗ = Test failed - needs attention');
System.debug('\nRECOMMENDATION:');
System.debug('If all tests passed, the class is working correctly.');
System.debug('If you cannot see it in Agent Actions UI:');
System.debug('1. Try using it in Flow Builder instead');
System.debug('2. Check your user has "Manage Agents" permission');
System.debug('3. Verify Agentforce is enabled in your org');
System.debug('4. Try a different browser or clear cache');
System.debug('========================================\n');
