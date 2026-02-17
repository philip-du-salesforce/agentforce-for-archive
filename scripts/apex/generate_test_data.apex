// Generate Test Data for Salesforce Org
// Creates Accounts, Contacts, and Cases with realistic data

System.debug('========================================');
System.debug('GENERATING TEST DATA');
System.debug('========================================\n');

// ============================================================================
// CONFIGURATION - Adjust these numbers as needed
// ============================================================================
Integer NUM_ACCOUNTS = 100;
Integer CONTACTS_PER_ACCOUNT = 3;
Integer CASES_PER_ACCOUNT = 5;

System.debug('Configuration:');
System.debug('- Accounts: ' + NUM_ACCOUNTS);
System.debug('- Contacts per Account: ' + CONTACTS_PER_ACCOUNT);
System.debug('- Cases per Account: ' + CASES_PER_ACCOUNT);
System.debug('- Total Contacts: ' + (NUM_ACCOUNTS * CONTACTS_PER_ACCOUNT));
System.debug('- Total Cases: ' + (NUM_ACCOUNTS * CASES_PER_ACCOUNT));
System.debug('');

// ============================================================================
// STEP 1: Create Accounts
// ============================================================================
System.debug('Creating ' + NUM_ACCOUNTS + ' Accounts...');

List<Account> accounts = new List<Account>();
List<String> industries = new List<String>{'Technology', 'Healthcare', 'Finance', 'Retail', 'Manufacturing', 'Education', 'Media'};
List<String> types = new List<String>{'Customer', 'Prospect', 'Partner', 'Other'};

for (Integer i = 1; i <= NUM_ACCOUNTS; i++) {
    Account acc = new Account();
    acc.Name = 'Test Company ' + i;
    acc.Industry = industries[Math.mod(i, industries.size())];
    acc.Type = types[Math.mod(i, types.size())];
    acc.Phone = '555-' + String.valueOf(1000 + i);
    acc.Website = 'www.testcompany' + i + '.com';
    
    // Try to set custom fields if they exist and aren't encrypted
    try {
        SObjectField extField = Schema.SObjectType.Account.fields.getMap().get('ebikesaws__ExtAccountId__c');
        if (extField != null) {
            // Only set if not encrypted
            DescribeFieldResult fieldDescribe = extField.getDescribe();
            if (!fieldDescribe.isEncrypted()) {
                acc.put('ebikesaws__ExtAccountId__c', 'EXT-' + String.valueOf(10000 + i));
            } else {
                // Field is encrypted, skip setting it
                System.debug('Skipping encrypted field ebikesaws__ExtAccountId__c');
            }
        }
    } catch (Exception e) {
        // Field doesn't exist or can't be accessed, continue without it
    }
    
    accounts.add(acc);
}

insert accounts;
System.debug('✓ Created ' + accounts.size() + ' Accounts');

// ============================================================================
// STEP 2: Create Contacts
// ============================================================================
System.debug('Creating Contacts...');

List<Contact> contacts = new List<Contact>();
List<String> firstNames = new List<String>{'John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Emily', 'James', 'Jessica'};
List<String> lastNames = new List<String>{'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'};
List<String> titles = new List<String>{'CEO', 'CFO', 'CTO', 'VP Sales', 'VP Marketing', 'Manager', 'Director', 'Consultant'};

Integer contactCount = 0;
for (Account acc : accounts) {
    for (Integer j = 1; j <= CONTACTS_PER_ACCOUNT; j++) {
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = firstNames[Math.mod(contactCount, firstNames.size())];
        con.LastName = lastNames[Math.mod(contactCount, lastNames.size())] + ' ' + j;
        con.Title = titles[Math.mod(contactCount, titles.size())];
        con.Email = con.FirstName.toLowerCase() + '.' + con.LastName.toLowerCase().replace(' ', '') + '@testcompany.com';
        con.Phone = '555-' + String.valueOf(2000 + contactCount);
        contacts.add(con);
        contactCount++;
    }
}

insert contacts;
System.debug('✓ Created ' + contacts.size() + ' Contacts');

// ============================================================================
// STEP 3: Create Cases
// ============================================================================
System.debug('Creating Cases...');

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

Integer caseCount = 0;
// Create map of contacts by account for assignment
Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();
for (Contact con : contacts) {
    if (!contactsByAccount.containsKey(con.AccountId)) {
        contactsByAccount.put(con.AccountId, new List<Contact>());
    }
    contactsByAccount.get(con.AccountId).add(con);
}

for (Account acc : accounts) {
    List<Contact> accountContacts = contactsByAccount.get(acc.Id);
    
    for (Integer k = 1; k <= CASES_PER_ACCOUNT; k++) {
        Case c = new Case();
        c.AccountId = acc.Id;
        
        // Assign to a contact from this account
        if (accountContacts != null && !accountContacts.isEmpty()) {
            c.ContactId = accountContacts[Math.mod(k, accountContacts.size())].Id;
        }
        
        c.Subject = subjects[Math.mod(caseCount, subjects.size())] + ' - Case ' + k;
        c.Description = 'This is a test case for ' + acc.Name + '. ' +
                       'Case number ' + k + ' created for testing purposes. ' +
                       'Contains sample description text to add some data volume.';
        c.Status = statuses[Math.mod(caseCount, statuses.size())];
        c.Priority = priorities[Math.mod(caseCount, priorities.size())];
        c.Origin = origins[Math.mod(caseCount, origins.size())];
        
        cases.add(c);
        caseCount++;
    }
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
System.debug('  ✓ Accounts: ' + accounts.size());
System.debug('  ✓ Contacts: ' + contacts.size());
System.debug('  ✓ Cases: ' + cases.size());
System.debug('');

// Count closed cases
Integer closedCases = 0;
for (Case c : cases) {
    if (c.Status == 'Closed') {
        closedCases++;
    }
}
System.debug('📋 Case Status Breakdown:');
System.debug('  • Closed Cases: ' + closedCases + ' (ready for archiving!)');
System.debug('  • Open Cases: ' + (cases.size() - closedCases));
System.debug('');

System.debug('💡 What to try next:');
System.debug('  1. "Get storage limits" - See your updated storage usage');
System.debug('  2. "What\'s using the most storage?" - View top consumers');
System.debug('  3. "Find large files" - See file storage');
System.debug('  4. "Archive closed cases older than 1 year" - Test archiving');
System.debug('');
System.debug('🎉 Your org is now populated with test data!');
