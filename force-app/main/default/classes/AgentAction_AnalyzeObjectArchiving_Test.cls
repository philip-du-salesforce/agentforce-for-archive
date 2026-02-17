@IsTest
private class AgentAction_AnalyzeObjectArchiving_Test {
    
    @IsTest
    static void testAnalyzeCase() {
        // Test analyzing Case object
        AgentAction_AnalyzeObjectForArchiving.Request req = new AgentAction_AnalyzeObjectForArchiving.Request();
        req.objectName = 'Case';
        req.includeRecommendations = true;
        
        Test.startTest();
        List<AgentAction_AnalyzeObjectForArchiving.Response> responses = 
            AgentAction_AnalyzeObjectForArchiving.analyzeObject(
                new List<AgentAction_AnalyzeObjectForArchiving.Request>{req}
            );
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        AgentAction_AnalyzeObjectForArchiving.Response res = responses[0];
        System.assertNotEquals(null, res.analysisMessage, 'Should have analysis message');
        System.assertNotEquals(null, res.objectLabel, 'Should have object label');
    }
    
    @IsTest
    static void testAnalyzeAccount() {
        // Test analyzing Account object
        AgentAction_AnalyzeObjectForArchiving.Request req = new AgentAction_AnalyzeObjectForArchiving.Request();
        req.objectName = 'Account';
        
        Test.startTest();
        List<AgentAction_AnalyzeObjectForArchiving.Response> responses = 
            AgentAction_AnalyzeObjectForArchiving.analyzeObject(
                new List<AgentAction_AnalyzeObjectForArchiving.Request>{req}
            );
        Test.stopTest();
        
        AgentAction_AnalyzeObjectForArchiving.Response res = responses[0];
        System.assertNotEquals(null, res.analysisMessage, 'Should have analysis');
        System.assert(res.analysisMessage.contains('ARCHIVAL ANALYSIS'), 'Should have header');
    }
    
    @IsTest
    static void testInvalidObject() {
        // Test with invalid object
        AgentAction_AnalyzeObjectForArchiving.Request req = new AgentAction_AnalyzeObjectForArchiving.Request();
        req.objectName = 'InvalidObject__c';
        
        Test.startTest();
        List<AgentAction_AnalyzeObjectForArchiving.Response> responses = 
            AgentAction_AnalyzeObjectForArchiving.analyzeObject(
                new List<AgentAction_AnalyzeObjectForArchiving.Request>{req}
            );
        Test.stopTest();
        
        AgentAction_AnalyzeObjectForArchiving.Response res = responses[0];
        System.assert(res.analysisMessage.contains('Error'), 'Should show error for invalid object');
        System.assertEquals(false, res.hasOpportunities, 'Should have no opportunities');
    }
    
    @IsTest
    static void testWithoutRecommendations() {
        // Test without recommendations
        AgentAction_AnalyzeObjectForArchiving.Request req = new AgentAction_AnalyzeObjectForArchiving.Request();
        req.objectName = 'Case';
        req.includeRecommendations = false;
        
        Test.startTest();
        List<AgentAction_AnalyzeObjectForArchiving.Response> responses = 
            AgentAction_AnalyzeObjectForArchiving.analyzeObject(
                new List<AgentAction_AnalyzeObjectForArchiving.Request>{req}
            );
        Test.stopTest();
        
        AgentAction_AnalyzeObjectForArchiving.Response res = responses[0];
        System.assert(!res.analysisMessage.contains('Recommended Archive Policies'), 
                     'Should not include recommendations');
    }
    
    @IsTest
    static void testOutputFields() {
        // Test that all output fields are populated
        AgentAction_AnalyzeObjectForArchiving.Request req = new AgentAction_AnalyzeObjectForArchiving.Request();
        req.objectName = 'Case';
        
        Test.startTest();
        List<AgentAction_AnalyzeObjectForArchiving.Response> responses = 
            AgentAction_AnalyzeObjectForArchiving.analyzeObject(
                new List<AgentAction_AnalyzeObjectForArchiving.Request>{req}
            );
        Test.stopTest();
        
        AgentAction_AnalyzeObjectForArchiving.Response res = responses[0];
        System.assertNotEquals(null, res.totalRecords, 'Should have total records');
        System.assertNotEquals(null, res.objectLabel, 'Should have object label');
        System.assertNotEquals(null, res.hasOpportunities, 'Should have opportunities flag');
    }
}
