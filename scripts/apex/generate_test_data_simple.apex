// Simple Test Data Generator - Minimal Field Version
// Creates Cases only (no Account/Contact dependencies)

System.debug('========================================');
System.debug('GENERATING TEST DATA (SIMPLE VERSION)');
System.debug('========================================\n');

// ============================================================================
// CONFIGURATION
// ============================================================================
Integer NUM_CASES = 500;

System.debug('Configuration:');
System.debug('- Cases: ' + NUM_CASES);
System.debug('');

// ============================================================================
// Create Cases
// ============================================================================
System.debug('Creating ' + NUM_CASES + ' Cases...');

List<Case> cases = new List<Case>();
List<String> subjects = new List<String>{
    'Product not working',
    'Need technical support',
    'Billing question',
    'Feature request',
    'Account access issue',
    'Installation problem',
    'Performance issue',
    'Documentation unclear',
    'Integration help needed',
    'Training request'
};
List<String> statuses = new List<String>{'New', 'Working', 'Escalated', 'Closed'};
List<String> priorities = new List<String>{'Low', 'Medium', 'High'};
List<String> origins = new List<String>{'Phone', 'Email', 'Web', 'Chat'};

for (Integer i = 1; i <= NUM_CASES; i++) {
    Case c = new Case();
    c.Subject = subjects[Math.mod(i, subjects.size())] + ' - Case ' + i;
    c.Description = 'This is test case #' + i + '. ' +
                   'Created for testing storage and archiving functionality. ' +
                   'Contains sample description text to add data volume. ' +
                   'This text helps simulate real case data in the system. ' +
                   'Additional details would normally be provided by the customer or support agent.';
    c.Status = statuses[Math.mod(i, statuses.size())];
    c.Priority = priorities[Math.mod(i, priorities.size())];
    c.Origin = origins[Math.mod(i, origins.size())];
    cases.add(c);
}

insert cases;

System.debug('✓ Created ' + cases.size() + ' Cases');

// ============================================================================
// SUMMARY
// ============================================================================
System.debug('');
System.debug('========================================');
System.debug('DATA GENERATION COMPLETE!');
System.debug('========================================');
System.debug('');
System.debug('📊 Summary:');
System.debug('  ✓ Cases: ' + cases.size());
System.debug('');

// Count by status
Integer newCases = 0, workingCases = 0, escalatedCases = 0, closedCases = 0;
for (Case c : cases) {
    if (c.Status == 'New') newCases++;
    else if (c.Status == 'Working') workingCases++;
    else if (c.Status == 'Escalated') escalatedCases++;
    else if (c.Status == 'Closed') closedCases++;
}

System.debug('📋 Case Status Breakdown:');
System.debug('  • New: ' + newCases);
System.debug('  • Working: ' + workingCases);
System.debug('  • Escalated: ' + escalatedCases);
System.debug('  • Closed: ' + closedCases + ' (ready for archiving!)');
System.debug('');

System.debug('💡 What to try next:');
System.debug('  1. "Get storage limits" - See your updated storage usage');
System.debug('  2. "What\'s using the most storage?" - View top consumers');
System.debug('  3. "Archive closed cases older than 1 year" - Test archiving');
System.debug('');
System.debug('🎉 Your org now has test data!');
System.debug('');
System.debug('Note: If you need Accounts/Contacts, you may need to:');
System.debug('  - Resolve encryption key issues for required fields');
System.debug('  - Or create them manually in the UI');
