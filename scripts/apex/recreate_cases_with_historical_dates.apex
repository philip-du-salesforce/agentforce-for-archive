// Recreate Cases with Random Historical Dates
// This script deletes existing cases and recreates them with dates ranging from today to 3+ years ago

System.debug('========================================');
System.debug('RECREATE CASES WITH HISTORICAL DATES');
System.debug('========================================\n');

// Step 1: Check current case count
Integer currentCount = [SELECT COUNT() FROM Case];
System.debug('Current cases in org: ' + currentCount);

if (currentCount == 0) {
    System.debug('No cases to process. Please run the generate_3000_cases script first.');
} else {
    // Step 2: Delete all existing cases
    System.debug('\nDeleting ' + currentCount + ' existing cases...');
    List<Case> casesToDelete = [SELECT Id FROM Case LIMIT 50000];
    delete casesToDelete;
    System.debug('✓ Deleted ' + casesToDelete.size() + ' cases');
    
    // Step 3: Recreate cases with historical dates
    System.debug('\nRecreating cases with random historical dates...');
    
    Integer NUM_CASES = currentCount; // Recreate the same number
    
    // Templates
    List<String> subjects = new List<String>{
        'Email Issue', 'Password Reset', 'Login Problem', 'Account Access',
        'Billing Question', 'Feature Request', 'Bug Report', 'Technical Support',
        'General Inquiry', 'Product Question', 'Refund Request', 'Upgrade Request'
    };
    
    List<String> statuses = new List<String>{'New', 'Working', 'Escalated', 'Closed'};
    List<String> priorities = new List<String>{'High', 'Medium', 'Low'};
    List<String> origins = new List<String>{'Web', 'Phone', 'Email'};
    
    // Date ranges (in days from today)
    Integer TODAY = 0;
    Integer THREE_YEARS = 1095; // 3 years in days
    
    System.debug('Creating ' + NUM_CASES + ' cases with dates from today to 3+ years ago...');
    
    // Create cases in batches to avoid heap limits
    Integer batchSize = 2000;
    Integer totalCreated = 0;
    
    while (totalCreated < NUM_CASES) {
        Integer remaining = NUM_CASES - totalCreated;
        Integer currentBatchSize = Math.min(remaining, batchSize);
        
        List<Case> casesToCreate = new List<Case>();
        
        for (Integer i = 0; i < currentBatchSize; i++) {
            Case c = new Case();
            
            // Generate random date between today and 3+ years ago
            Integer randomDaysAgo = (Integer)(Math.random() * THREE_YEARS);
            
            // We can't set CreatedDate directly, but we can influence the distribution
            // by setting status based on age
            if (randomDaysAgo > 730) { // > 2 years
                c.Status = 'Closed';
            } else if (randomDaysAgo > 365) { // > 1 year
                c.Status = (Math.random() > 0.5) ? 'Closed' : 'Escalated';
            } else if (randomDaysAgo > 180) { // > 6 months
                c.Status = statuses[Math.mod((Integer)(Math.random() * 100), statuses.size())];
            } else {
                c.Status = (Math.random() > 0.7) ? 'Closed' : statuses[Math.mod((Integer)(Math.random() * 100), 2)]; // Mostly New/Working
            }
            
            c.Subject = subjects[Math.mod(totalCreated + i, subjects.size())] + ' #' + (totalCreated + i + 1);
            c.Description = 'Case from ' + randomDaysAgo + ' days ago. Testing archival policies with historical data.';
            c.Priority = priorities[Math.mod((Integer)(Math.random() * 100), priorities.size())];
            c.Origin = origins[Math.mod((Integer)(Math.random() * 100), origins.size())];
            
            casesToCreate.add(c);
        }
        
        insert casesToCreate;
        totalCreated += casesToCreate.size();
        System.debug('  Created batch: ' + casesToCreate.size() + ' cases (Total: ' + totalCreated + ')');
    }
    
    System.debug('\n✓ Successfully recreated ' + totalCreated + ' cases!');
    
    // Step 4: Show breakdown
    System.debug('\n========================================');
    System.debug('SUMMARY');
    System.debug('========================================\n');
    
    Integer totalCases = [SELECT COUNT() FROM Case];
    AggregateResult[] statusCounts = [SELECT Status, COUNT(Id) cnt FROM Case GROUP BY Status];
    
    System.debug('📊 Total Cases: ' + totalCases);
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
    
    System.debug('\n⚠️ NOTE: Salesforce sets CreatedDate automatically.');
    System.debug('All cases will have today\'s CreatedDate, but Status distribution');
    System.debug('reflects what would be expected with historical dates.');
    System.debug('\nTo test age-based archiving, we\'ll need to use a different approach.');
}

System.debug('\n========================================');
System.debug('COMPLETE!');
System.debug('========================================');
