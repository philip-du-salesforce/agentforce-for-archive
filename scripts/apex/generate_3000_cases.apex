// Generate 3,000 Cases - Efficient Version
// Run multiple times to build up larger datasets

System.debug('========================================');
System.debug('GENERATING 3,000 CASES');
System.debug('========================================\n');

Integer NUM_CASES = 3000;

// ============================================================================
// Templates
// ============================================================================
List<String> subjects = new List<String>{
    'Product issue', 'Support needed', 'Billing question', 'Feature request',
    'Access issue', 'Install problem', 'Performance slow', 'Doc unclear',
    'Integration help', 'Training needed', 'Bug report', 'Config help'
};
List<String> statuses = new List<String>{'New', 'Working', 'Escalated', 'Closed'};
List<String> priorities = new List<String>{'Low', 'Medium', 'High', 'Critical'};
List<String> origins = new List<String>{'Phone', 'Email', 'Web', 'Chat'};

// ============================================================================
// Generate Cases
// ============================================================================
System.debug('Creating ' + NUM_CASES + ' cases...');

List<Case> cases = new List<Case>();

for (Integer i = 1; i <= NUM_CASES; i++) {
    Case c = new Case();
    c.Subject = subjects[Math.mod(i, subjects.size())] + ' #' + i;
    c.Description = 'Test case ' + i + ' for storage testing with detailed description text.';
    c.Status = statuses[Math.mod(i, statuses.size())];
    c.Priority = priorities[Math.mod(i, priorities.size())];
    c.Origin = origins[Math.mod(i, origins.size())];
    cases.add(c);
}

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
System.debug('📊 TOTAL CASES IN ORG: ' + totalCases);
System.debug('\n📋 Status Breakdown:');
for (AggregateResult ar : statusCounts) {
    String status = (String)ar.get('Status');
    Integer count = (Integer)ar.get('cnt');
    if (status == 'Closed') {
        System.debug('  • ' + status + ': ' + count + ' ⭐ (ready for archiving!)');
    } else {
        System.debug('  • ' + status + ': ' + count);
    }
}

System.debug('\n💡 To reach 15,000+ cases, run this script 5 times!');
System.debug('   Current: ' + totalCases + ' cases');
System.debug('   Target: 15,000 cases');
System.debug('   Runs needed: ' + Math.ceil((15000.0 - totalCases) / NUM_CASES));
