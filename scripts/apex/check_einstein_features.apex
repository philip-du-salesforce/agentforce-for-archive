// Check Einstein Agent Features and Permissions

System.debug('========================================');
System.debug('CHECKING EINSTEIN AGENT FEATURES');
System.debug('========================================\n');

// Check if Einstein is enabled
Boolean einsteinEnabled = false;
try {
    // Try to query GenAiFunction (Agent Actions)
    List<SObject> functions = Database.query('SELECT Id, Label FROM GenAiFunction LIMIT 1');
    einsteinEnabled = true;
    System.debug('✓ Einstein Agent Actions: ENABLED');
    System.debug('  Found ' + functions.size() + ' Agent Action(s)');
} catch (Exception e) {
    System.debug('✗ Einstein Agent Actions: NOT ACCESSIBLE');
    System.debug('  Error: ' + e.getMessage());
}

System.debug('');

// Check user permissions
System.debug('USER PERMISSIONS:');
System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
User currentUser = [SELECT Id, Name, Profile.Name, UserType FROM User WHERE Id = :UserInfo.getUserId()];
System.debug('User: ' + currentUser.Name);
System.debug('Profile: ' + currentUser.Profile.Name);
System.debug('UserType: ' + currentUser.UserType);

System.debug('');

// Try to query all Agent Actions
System.debug('QUERYING AGENT ACTIONS:');
System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
try {
    List<SObject> allFunctions = Database.query('SELECT Id, Label, ReferenceAction, Status FROM GenAiFunction ORDER BY Label');
    System.debug('✓ Total Agent Actions: ' + allFunctions.size());
    if (allFunctions.size() > 0) {
        System.debug('\nAgent Actions Found:');
        for (SObject func : allFunctions) {
            String label = (String) func.get('Label');
            String status = (String) func.get('Status');
            String refAction = (String) func.get('ReferenceAction');
            System.debug('  • ' + label + ' (Status: ' + status + ')');
            if (String.isNotBlank(refAction)) {
                System.debug('    Reference: ' + refAction);
            }
        }
    }
} catch (Exception e) {
    System.debug('✗ Cannot query Agent Actions');
    System.debug('  Error: ' + e.getMessage());
}

System.debug('');

// Check org features
System.debug('ORG FEATURES:');
System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
Organization org = [SELECT Id, Name, OrganizationType, IsSandbox FROM Organization LIMIT 1];
System.debug('Org Name: ' + org.Name);
System.debug('Org Type: ' + org.OrganizationType);
System.debug('Is Sandbox: ' + org.IsSandbox);

System.debug('');
System.debug('========================================');
System.debug('CHECK COMPLETE');
System.debug('========================================');
