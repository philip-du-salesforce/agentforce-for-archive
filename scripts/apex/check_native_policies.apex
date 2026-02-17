// Check if native archive policies were created

System.debug('========================================');
System.debug('CHECK: NATIVE ARCHIVE POLICIES');
System.debug('========================================\n');

// Query all ArchivePolicyDefinition records
List<ArchivePolicyDefinition> policies = [
    SELECT Id, MasterLabel, DeveloperName, IsActive, RootEntityName, 
           Type, RunFrequency, Query, Description, CreatedDate
    FROM ArchivePolicyDefinition
    ORDER BY CreatedDate DESC
    LIMIT 10
];

System.debug('📊 Found ' + policies.size() + ' native archive policies:\n');

if (policies.isEmpty()) {
    System.debug('No policies found yet.');
    System.debug('\n⏳ If you just created a policy, wait a bit longer.');
    System.debug('Tooling API deployments can take up to 60 seconds.');
} else {
    Integer count = 1;
    for (ArchivePolicyDefinition policy : policies) {
        System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        System.debug('Policy ' + count + ': ' + policy.MasterLabel);
        System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        System.debug('Developer Name: ' + policy.DeveloperName);
        System.debug('Object: ' + policy.RootEntityName);
        System.debug('Type: ' + policy.Type);
        System.debug('Active: ' + (policy.IsActive ? '✓ Yes' : '✗ No'));
        System.debug('Schedule: ' + policy.RunFrequency);
        System.debug('Query: ' + policy.Query);
        System.debug('Description: ' + policy.Description);
        System.debug('Created: ' + policy.CreatedDate.format('MMM d, yyyy h:mm a'));
        System.debug('');
        count++;
    }
}

System.debug('\n========================================');
System.debug('VERIFICATION COMPLETE!');
System.debug('========================================');
