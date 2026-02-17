// SOLUTION 1: Create Cases with Test.setCreatedDate() (Best for testing)
// Note: This ONLY works within a test method, not in execute anonymous!
// Use this as a reference for creating a test class

@isTest
public class CreateHistoricalCasesTest {
    
    @isTest
    static void createHistoricalCases() {
        System.debug('Creating cases with historical dates...');
        
        List<Case> casesToCreate = new List<Case>();
        
        // Templates
        List<String> subjects = new List<String>{
            'Email Issue', 'Password Reset', 'Login Problem', 'Account Access',
            'Billing Question', 'Feature Request', 'Bug Report', 'Technical Support'
        };
        
        List<String> statuses = new List<String>{'New', 'Working', 'Escalated', 'Closed'};
        List<String> priorities = new List<String>{'High', 'Medium', 'Low'};
        List<String> origins = new List<String>{'Web', 'Phone', 'Email'};
        
        Integer NUM_CASES = 1000; // Create 1000 cases with historical dates
        Integer THREE_YEARS_DAYS = 1095;
        
        for (Integer i = 0; i < NUM_CASES; i++) {
            Case c = new Case();
            
            // Random date between 0 and 3+ years ago
            Integer randomDaysAgo = (Integer)(Math.random() * THREE_YEARS_DAYS);
            
            // Status based on age
            if (randomDaysAgo > 730) { // > 2 years - mostly closed
                c.Status = 'Closed';
            } else if (randomDaysAgo > 365) { // > 1 year - mixed
                c.Status = (Math.random() > 0.5) ? 'Closed' : 'Escalated';
            } else { // < 1 year - varied
                c.Status = statuses[Math.mod((Integer)(Math.random() * 100), statuses.size())];
            }
            
            c.Subject = subjects[Math.mod(i, subjects.size())] + ' #' + (i + 1);
            c.Description = 'Test case from ~' + randomDaysAgo + ' days ago';
            c.Priority = priorities[Math.mod((Integer)(Math.random() * 100), priorities.size())];
            c.Origin = origins[Math.mod((Integer)(Math.random() * 100), origins.size())];
            
            casesToCreate.add(c);
        }
        
        // Insert cases
        insert casesToCreate;
        
        // NOW set the CreatedDate to historical values
        for (Integer i = 0; i < casesToCreate.size(); i++) {
            Integer randomDaysAgo = (Integer)(Math.random() * THREE_YEARS_DAYS);
            DateTime historicalDate = DateTime.now().addDays(-randomDaysAgo);
            Test.setCreatedDate(casesToCreate[i].Id, historicalDate);
        }
        
        System.debug('✓ Created ' + NUM_CASES + ' cases with historical dates!');
        
        // Verify
        List<Case> oldCases = [SELECT Id, CreatedDate, Status 
                               FROM Case 
                               WHERE CreatedDate < LAST_N_DAYS:365];
        System.debug('Cases older than 1 year: ' + oldCases.size());
    }
}

/* TO RUN THIS:
   1. Save this as a proper Apex class
   2. Run: sf apex run test --class-names CreateHistoricalCasesTest
   
   WARNING: Test data is rolled back after test execution!
   This won't persist actual data in your org.
*/
