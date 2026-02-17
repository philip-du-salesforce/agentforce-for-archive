// Generate Test Data - Contacts and Cases Only
// No Account dependencies

System.debug('========================================');
System.debug('GENERATING TEST DATA');
System.debug('Contacts + Cases (No Accounts)');
System.debug('========================================\n');

// ============================================================================
// CONFIGURATION
// ============================================================================
Integer NUM_CONTACTS = 200;
Integer NUM_CASES = 1000;

System.debug('Configuration:');
System.debug('- Contacts: ' + NUM_CONTACTS);
System.debug('- Cases: ' + NUM_CASES);
System.debug('');

// ============================================================================
// STEP 1: Create Contacts
// ============================================================================
System.debug('Creating ' + NUM_CONTACTS + ' Contacts...');

List<Contact> contacts = new List<Contact>();
List<String> firstNames = new List<String>{
    'John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Emily', 
    'James', 'Jessica', 'William', 'Ashley', 'Richard', 'Amanda', 'Joseph',
    'Melissa', 'Thomas', 'Nicole', 'Charles', 'Jennifer'
};
List<String> lastNames = new List<String>{
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 
    'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 
    'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'
};
List<String> titles = new List<String>{
    'CEO', 'CFO', 'CTO', 'VP Sales', 'VP Marketing', 'Manager', 
    'Director', 'Consultant', 'Analyst', 'Specialist', 'Coordinator',
    'Engineer', 'Developer', 'Designer', 'Administrator'
};

for (Integer i = 1; i <= NUM_CONTACTS; i++) {
    Contact con = new Contact();
    con.FirstName = firstNames[Math.mod(i, firstNames.size())];
    con.LastName = lastNames[Math.mod(i, lastNames.size())] + ' ' + i;
    con.Title = titles[Math.mod(i, titles.size())];
    con.Email = con.FirstName.toLowerCase() + '.' + 
                con.LastName.toLowerCase().replace(' ', '') + '@testuser' + i + '.com';
    con.Phone = '555-' + String.valueOf(2000 + i).leftPad(4, '0');
    con.MobilePhone = '555-' + String.valueOf(3000 + i).leftPad(4, '0');
    contacts.add(con);
}

try {
    insert contacts;
    System.debug('✓ Created ' + contacts.size() + ' Contacts');
} catch (Exception e) {
    System.debug('⚠️ Could not create Contacts: ' + e.getMessage());
    System.debug('   Continuing with Cases only...');
    contacts.clear(); // Clear the list so we don't reference them later
}

// ============================================================================
// STEP 2: Create Cases
// ============================================================================
System.debug('Creating ' + NUM_CASES + ' Cases...');

List<Case> cases = new List<Case>();
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
    'Password reset request'
};
List<String> statuses = new List<String>{'New', 'Working', 'Escalated', 'Closed'};
List<String> priorities = new List<String>{'Low', 'Medium', 'High', 'Critical'};
List<String> origins = new List<String>{'Phone', 'Email', 'Web', 'Chat'};
List<String> types = new List<String>{'Question', 'Problem', 'Feature Request'};

for (Integer i = 1; i <= NUM_CASES; i++) {
    Case c = new Case();
    
    // Link to contact if we have contacts
    if (!contacts.isEmpty() && Math.mod(i, 2) == 0) {
        c.ContactId = contacts[Math.mod(i, contacts.size())].Id;
    }
    
    c.Subject = subjects[Math.mod(i, subjects.size())] + ' #' + i;
    c.Description = 'Test case #' + i + ' created for storage and archiving testing.\n\n' +
                   'This case contains sample description text to simulate real data volume. ' +
                   'In a production environment, this would include detailed information about ' +
                   'the customer issue, troubleshooting steps taken, and resolution notes.\n\n' +
                   'Additional context: This is case number ' + i + ' in a series of test cases. ' +
                   'The purpose is to generate sufficient data volume to test storage management ' +
                   'and archiving capabilities in the Agentforce Data Steward solution.\n\n' +
                   'Expected outcome: This case should be visible in storage reports and eligible ' +
                   'for archiving based on its age and status.';
    
    c.Status = statuses[Math.mod(i, statuses.size())];
    c.Priority = priorities[Math.mod(i, priorities.size())];
    c.Origin = origins[Math.mod(i, origins.size())];
    c.Type = types[Math.mod(i, types.size())];
    
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
System.debug('  ✓ Contacts: ' + contacts.size());
System.debug('  ✓ Cases: ' + cases.size());
System.debug('');

// Count cases by status
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

// Count cases with contacts
Integer casesWithContacts = 0;
for (Case c : cases) {
    if (c.ContactId != null) casesWithContacts++;
}
if (!contacts.isEmpty()) {
    System.debug('📞 Contact Relationships:');
    System.debug('  • Cases with Contacts: ' + casesWithContacts);
    System.debug('  • Cases without Contacts: ' + (cases.size() - casesWithContacts));
    System.debug('');
}

System.debug('💡 What to try next:');
System.debug('  1. "Get storage limits" - See your updated storage usage');
System.debug('  2. "What\'s using the most storage?" - View top consumers');
System.debug('  3. "Find large files" - Check file storage');
System.debug('  4. "Archive closed cases" - Test archiving closed cases');
System.debug('');
System.debug('🎉 Your org now has realistic test data!');
