// Generate 5,000 Cases - Optimized Version
// Can run multiple times to build up large datasets

System.debug('========================================');
System.debug('GENERATING 5,000 CASES');
System.debug('========================================\n');

Integer NUM_CASES = 5000;

System.debug('Creating ' + NUM_CASES + ' cases...\n');

// ============================================================================
// Templates
// ============================================================================
List<String> subjects = new List<String>{
    'Product issue', 'Support needed', 'Billing question', 'Feature request',
    'Access issue', 'Install problem', 'Performance slow', 'Doc unclear',
    'Integration help', 'Training needed', 'Bug report', 'Config help',
    'License question', 'Data migration', 'Password reset'
};
List<String> statuses = new List<String>{'New', 'Working', 'Escalated', 'Closed'};
List<String> priorities = new List<String>{'Low', 'Medium', 'High', 'Critical'};
List<String> origins = new List<String>{'Phone', 'Email', 'Web', 'Chat'};

// ============================================================================
// Generate All Cases
// ============================================================================
List<Case> cases = new List<Case>();

for (Integer i = 1; i <= NUM_CASES; i++) {
    Case c = new Case();
    c.Subject = subjects[Math.mod(i, subjects.size())] + ' #' + i;
    c.Description = 'Test case ' + i + ' for storage testing. ' +
                   'Contains data to simulate production volume.';
    c.Status = statuses[Math.mod(i, statuses.size())];
    c.Priority = priorities[Math.mod(i, priorities.size())];
    c.Origin = origins[Math.mod(i, origins.size())];
    cases.add(c);
}

System.debug('Inserting ' + cases.size() + ' cases...');
insert cases;
System.debug('✓ Created ' + cases.size() + ' cases!\n');

// ============================================================================
// Summary
// ============================================================================
Integer totalCases = [SELECT COUNT() FROM Case];
AggregateResult[] statusCounts = [SELECT Status, COUNT(Id) cnt FROM Case GROUP BY Status];

System.debug('========================================');
System.debug('COMPLETE!');
System.debug('========================================\n');
System.debug('📊 Total Cases in Org: ' + totalCases);
System.debug('\n📋 Status Breakdown:');
for (AggregateResult ar : statusCounts) {
    System.debug('  • ' + ar.get('Status') + ': ' + ar.get('cnt'));
}
System.debug('\n💡 Try: "Get storage limits" to see the impact!');
