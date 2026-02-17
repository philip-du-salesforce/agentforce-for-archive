@isTest
public class AgentAction_TopStorageConsumers_Test {
    
    @isTest
    static void testTopConsumers() {
        // 1. Setup Data
        List<Account> accs = new List<Account>();
        for(Integer i=0; i<10; i++) {
            accs.add(new Account(Name='Storage Test ' + i));
        }
        insert accs;

        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i<5; i++) {
            leads.add(new Lead(LastName='LeadTest ' + i, Company='Test Co'));
        }
        insert leads;

        // 2. Execute
        AgentAction_TopStorageConsumers.Request req = new AgentAction_TopStorageConsumers.Request();
        req.numberToShow = 3; 
        List<AgentAction_TopStorageConsumers.Request> reqList = new List<AgentAction_TopStorageConsumers.Request>{req};

        Test.startTest();
        List<AgentAction_TopStorageConsumers.Response> results = AgentAction_TopStorageConsumers.identifyTopConsumers(reqList);
        Test.stopTest();

        // 3. Verify
        System.assertEquals(1, results.size());
        String output = results[0].analysisResult;
        
        System.debug('Output: ' + output);
        
        // Assert we DON'T have the header text anymore
        System.assert(!output.contains('Here are the objects'), 'Output should NOT contain a conversational header');
        
        // Assert it starts with ranking
        System.assert(output.contains('1. Account'), 'Output should start with the ranked list');
    }
}