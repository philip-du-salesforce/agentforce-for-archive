// SOLUTION 2: Use a Custom Date Field (RECOMMENDED FOR REAL TESTING)
// This creates a custom field to simulate historical dates without modifying CreatedDate

System.debug('========================================');
System.debug('WORKAROUND: Custom Historical Date Field');
System.debug('========================================\n');

// NOTE: Before running this, create a custom field on Case:
// Field Label: Historical Created Date
// API Name: Historical_Created_Date__c
// Type: Date/Time
// This field will simulate CreatedDate for testing purposes

System.debug('⚠️ PREREQUISITE: Create Custom Field First!');
System.debug('Field: Historical_Created_Date__c (Date/Time) on Case object\n');

// Check if field exists
Boolean fieldExists = Schema.SObjectType.Case.fields.getMap().containsKey('Historical_Created_Date__c');

if (!fieldExists) {
    System.debug('❌ ERROR: Historical_Created_Date__c field does not exist!');
    System.debug('\nTO CREATE THE FIELD:');
    System.debug('1. Setup → Object Manager → Case');
    System.debug('2. Fields & Relationships → New');
    System.debug('3. Field Type: Date/Time');
    System.debug('4. Field Label: Historical Created Date');
    System.debug('5. Field Name: Historical_Created_Date');
    System.debug('6. Save');
} else {
    System.debug('✓ Field exists! Updating cases with historical dates...\n');
    
    // Get all cases
    List<Case> cases = [SELECT Id, Status FROM Case];
    System.debug('Found ' + cases.size() + ' cases to update');
    
    if (cases.isEmpty()) {
        System.debug('No cases to update. Run generate_3000_cases script first.');
    } else {
        Integer THREE_YEARS_DAYS = 1095;
        Integer updated = 0;
        
        // Update in batches to avoid limits
        for (Case c : cases) {
            // Random date between 0 and 3+ years ago
            Integer randomDaysAgo = (Integer)(Math.random() * THREE_YEARS_DAYS);
            DateTime historicalDate = DateTime.now().addDays(-randomDaysAgo);
            
            c.put('Historical_Created_Date__c', historicalDate);
            updated++;
            
            if (Math.mod(updated, 1000) == 0) {
                System.debug('  Processed ' + updated + ' cases...');
            }
        }
        
        System.debug('\nUpdating ' + cases.size() + ' cases...');
        update cases;
        System.debug('✓ Updated ' + cases.size() + ' cases with historical dates!');
        
        // Show breakdown
        System.debug('\n📊 HISTORICAL DATE BREAKDOWN:');
        
        Integer olderThan3Years = 0;
        Integer olderThan2Years = 0;
        Integer olderThan1Year = 0;
        Integer olderThan6Months = 0;
        Integer olderThan3Months = 0;
        Integer recent = 0;
        
        for (Case c : [SELECT Historical_Created_Date__c FROM Case]) {
            DateTime hcd = (DateTime)c.get('Historical_Created_Date__c');
            Integer daysAgo = DateTime.now().date().daysBetween(hcd.date());
            
            if (daysAgo > 1095) olderThan3Years++;
            else if (daysAgo > 730) olderThan2Years++;
            else if (daysAgo > 365) olderThan1Year++;
            else if (daysAgo > 180) olderThan6Months++;
            else if (daysAgo > 90) olderThan3Months++;
            else recent++;
        }
        
        System.debug('  • Older than 3 years: ' + olderThan3Years);
        System.debug('  • Older than 2 years: ' + olderThan2Years);
        System.debug('  • Older than 1 year: ' + olderThan1Year);
        System.debug('  • Older than 6 months: ' + olderThan6Months);
        System.debug('  • Older than 3 months: ' + olderThan3Months);
        System.debug('  • Recent (< 3 months): ' + recent);
        
        System.debug('\n💡 NEXT STEPS:');
        System.debug('To test archival analysis with this data, modify your queries to use:');
        System.debug('Historical_Created_Date__c < LAST_N_DAYS:365');
        System.debug('instead of:');
        System.debug('CreatedDate < LAST_N_DAYS:365');
    }
}

System.debug('\n========================================');
System.debug('COMPLETE!');
System.debug('========================================');
