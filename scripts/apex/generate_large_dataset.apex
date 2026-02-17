// Generate LARGE Test Data Set - 10,000 Cases
// This will add significant data volume for testing

System.debug('========================================');
System.debug('GENERATING LARGE TEST DATA SET');
System.debug('10,000 Cases');
System.debug('========================================\n');

// ============================================================================
// CONFIGURATION
// ============================================================================
Integer NUM_CASES = 10000;
Integer BATCH_SIZE = 200; // Process in batches to stay within limits

System.debug('Configuration:');
System.debug('- Total Cases to Create: ' + NUM_CASES);
System.debug('- Batch Size: ' + BATCH_SIZE);
System.debug('- Number of Batches: ' + (NUM_CASES / BATCH_SIZE));
System.debug('');

// ============================================================================
// Data Templates
// ============================================================================
List<String> subjects = new List<String>{
    'Product not working properly',
    'Need technical support urgently',
    'Billing question - Invoice discrepancy',
    'Feature request - New functionality',
    'Account access issue - Cannot login',
    'Installation problem - Setup failed',
    'Performance issue - System slow',
    'Documentation unclear - Need clarification',
    'Integration help needed - API errors',
    'Training request - New user onboarding',
    'Bug report - Application crash',
    'Configuration assistance needed',
    'License renewal question',
    'Data migration support',
    'Password reset request',
    'Upgrade assistance required',
    'Security concern - Potential breach',
    'Custom development request',
    'System maintenance notification',
    'User provisioning issue'
};
List<String> statuses = new List<String>{'New', 'Working', 'Escalated', 'Closed'};
List<String> priorities = new List<String>{'Low', 'Medium', 'High', 'Critical'};
List<String> origins = new List<String>{'Phone', 'Email', 'Web', 'Chat'};
List<String> types = new List<String>{'Question', 'Problem', 'Feature Request'};

// ============================================================================
// Generate Cases in Batches
// ============================================================================
Integer totalCreated = 0;
Integer batchNumber = 1;

System.debug('Starting case generation...\n');

for (Integer batchStart = 1; batchStart <= NUM_CASES; batchStart += BATCH_SIZE) {
    List<Case> cases = new List<Case>();
    Integer batchEnd = Math.min(batchStart + BATCH_SIZE - 1, NUM_CASES);
    
    System.debug('Batch ' + batchNumber + ': Creating cases ' + batchStart + ' to ' + batchEnd + '...');
    
    for (Integer i = batchStart; i <= batchEnd; i++) {
        Case c = new Case();
        
        c.Subject = subjects[Math.mod(i, subjects.size())] + ' #' + i;
        c.Description = 'Test case #' + i + ' created for large-scale storage testing.\n\n' +
                       'This case is part of a 10,000 record test data set designed to simulate ' +
                       'production-level data volumes for the Agentforce Data Steward solution.\n\n' +
                       'Case Details:\n' +
                       '- Case Number: ' + i + '\n' +
                       '- Batch: ' + batchNumber + '\n' +
                       '- Purpose: Storage management and archiving capability testing\n\n' +
                       'The inclusion of detailed description text helps create realistic data ' +
                       'volume similar to what would be seen in a production Salesforce org. ' +
                       'This allows for accurate testing of storage consumption reports, ' +
                       'archive policy creation, and data management workflows.\n\n' +
                       'Additional Notes: This case should be visible in storage analysis reports ' +
                       'and eligible for archiving based on configured retention policies. ' +
                       'The varying status values across the dataset allow testing of ' +
                       'conditional archiving rules (e.g., "archive closed cases only").';
        
        c.Status = statuses[Math.mod(i, statuses.size())];
        c.Priority = priorities[Math.mod(i, priorities.size())];
        c.Origin = origins[Math.mod(i, origins.size())];
        c.Type = types[Math.mod(i, types.size())];
        
        cases.add(c);
    }
    
    // Insert this batch
    insert cases;
    totalCreated += cases.size();
    System.debug('  ✓ Created ' + cases.size() + ' cases (Total: ' + totalCreated + ')');
    
    batchNumber++;
}

System.debug('');
System.debug('✓ All cases created successfully!');

// ============================================================================
// Query for final statistics
// ============================================================================
System.debug('');
System.debug('Calculating statistics...');

// Get total case count
Integer totalCases = [SELECT COUNT() FROM Case];

// Count by status
AggregateResult[] statusCounts = [
    SELECT Status, COUNT(Id) cnt 
    FROM Case 
    GROUP BY Status
];

// ============================================================================
// SUMMARY
// ============================================================================
System.debug('');
System.debug('========================================');
System.debug('DATA GENERATION COMPLETE!');
System.debug('========================================');
System.debug('');
System.debug('📊 Summary:');
System.debug('  ✓ Cases Created This Run: ' + totalCreated);
System.debug('  ✓ Total Cases in Org: ' + totalCases);
System.debug('');

System.debug('📋 Case Status Breakdown (Org Total):');
for (AggregateResult ar : statusCounts) {
    String status = (String)ar.get('Status');
    Integer count = (Integer)ar.get('cnt');
    
    if (status == 'Closed') {
        System.debug('  • ' + status + ': ' + count + ' (ready for archiving! 🎯)');
    } else {
        System.debug('  • ' + status + ': ' + count);
    }
}
System.debug('');

// Calculate approximate data size (rough estimate)
Decimal avgCaseSize = 1.5; // KB per case (rough estimate)
Decimal totalDataMB = (totalCases * avgCaseSize) / 1024;

System.debug('📈 Estimated Data Impact:');
System.debug('  • Approximate Case Data: ' + totalDataMB.setScale(2) + ' MB');
System.debug('  • This represents significant test volume!');
System.debug('');

System.debug('💡 What to try next:');
System.debug('  1. "Get storage limits" - See REAL storage usage now!');
System.debug('  2. "What\'s using the most storage?" - Case will be #1');
System.debug('  3. "Archive closed cases" - Archive 25% of your cases');
System.debug('  4. "List my archive policies" - Manage policies');
System.debug('');
System.debug('🎉 Your org now has SIGNIFICANT test data!');
System.debug('   Perfect for testing storage management at scale.');
