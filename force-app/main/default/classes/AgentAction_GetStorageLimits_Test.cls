@isTest
public class AgentAction_GetStorageLimits_Test {
    
    @isTest
    static void testGetLimits_Generic() {
        // Test: Generic Request (should return BOTH)
        AgentAction_GetStorageLimits.Request req = new AgentAction_GetStorageLimits.Request();
        req.limitType = null; 
        List<AgentAction_GetStorageLimits.Request> reqList = new List<AgentAction_GetStorageLimits.Request>{req};

        Test.startTest();
        List<AgentAction_GetStorageLimits.Response> results = AgentAction_GetStorageLimits.getStorageLimits(reqList);
        Test.stopTest();

        // Assert: The message should contain key elements
        String msg = results[0].usageMessage;
        System.assert(msg.contains('DATA STORAGE'), 'Should mention Data Storage');
        System.assert(msg.contains('FILE STORAGE'), 'Should mention File Storage');
        System.assert(msg.contains('GB'), 'Should display units in GB');
        System.assert(msg.contains('%'), 'Should display percentage');
        
        // Assert: Should include visualizations
        System.assert(msg.contains('[') && (msg.contains('█') || msg.contains('░')), 'Should include progress bar');
        
        // Assert: Response fields populated
        System.assertNotEquals(null, results[0].dataUsagePercent, 'Data usage percent should be set');
        System.assertNotEquals(null, results[0].fileUsagePercent, 'File usage percent should be set');
        System.assertNotEquals(null, results[0].storageStatus, 'Storage status should be set');
        System.assertNotEquals(null, results[0].nextSteps, 'Next steps should be set');
    }

    @isTest
    static void testGetLimits_Specific() {
        // Test: Specific Request (should return ONLY Data)
        AgentAction_GetStorageLimits.Request req = new AgentAction_GetStorageLimits.Request();
        req.limitType = 'Data'; 
        List<AgentAction_GetStorageLimits.Request> reqList = new List<AgentAction_GetStorageLimits.Request>{req};

        Test.startTest();
        List<AgentAction_GetStorageLimits.Response> results = AgentAction_GetStorageLimits.getStorageLimits(reqList);
        Test.stopTest();

        String msg = results[0].usageMessage;
        System.assert(msg.contains('DATA STORAGE'), 'Should mention Data');
        System.assert(!msg.contains('FILE STORAGE'), 'Should NOT mention File');
    }
    
    @isTest
    static void testGetLimits_FileOnly() {
        // Test: File Storage only
        AgentAction_GetStorageLimits.Request req = new AgentAction_GetStorageLimits.Request();
        req.limitType = 'File'; 
        List<AgentAction_GetStorageLimits.Request> reqList = new List<AgentAction_GetStorageLimits.Request>{req};

        Test.startTest();
        List<AgentAction_GetStorageLimits.Response> results = AgentAction_GetStorageLimits.getStorageLimits(reqList);
        Test.stopTest();

        String msg = results[0].usageMessage;
        System.assert(msg.contains('FILE STORAGE'), 'Should mention File');
        System.assert(!msg.contains('DATA STORAGE'), 'Should NOT mention Data');
    }
    
    @isTest
    static void testGetLimits_NoRecommendations() {
        // Test: With recommendations disabled
        AgentAction_GetStorageLimits.Request req = new AgentAction_GetStorageLimits.Request();
        req.includeRecommendations = false;
        List<AgentAction_GetStorageLimits.Request> reqList = new List<AgentAction_GetStorageLimits.Request>{req};

        Test.startTest();
        List<AgentAction_GetStorageLimits.Response> results = AgentAction_GetStorageLimits.getStorageLimits(reqList);
        Test.stopTest();

        String msg = results[0].usageMessage;
        System.assert(!msg.contains('What you can do next'), 'Should NOT include recommendations');
    }
    
    @isTest
    static void testGetLimits_WithRecommendations() {
        // Test: With recommendations enabled (default)
        AgentAction_GetStorageLimits.Request req = new AgentAction_GetStorageLimits.Request();
        req.includeRecommendations = true;
        List<AgentAction_GetStorageLimits.Request> reqList = new List<AgentAction_GetStorageLimits.Request>{req};

        Test.startTest();
        List<AgentAction_GetStorageLimits.Response> results = AgentAction_GetStorageLimits.getStorageLimits(reqList);
        Test.stopTest();

        String msg = results[0].usageMessage;
        System.assert(msg.contains('What you can do next'), 'Should include recommendations');
        System.assert(msg.contains('Other options'), 'Should include other options');
    }
    
    @isTest
    static void testProgressBarVisualization() {
        // Test: Verify progress bar is generated
        AgentAction_GetStorageLimits.Request req = new AgentAction_GetStorageLimits.Request();
        List<AgentAction_GetStorageLimits.Request> reqList = new List<AgentAction_GetStorageLimits.Request>{req};

        Test.startTest();
        List<AgentAction_GetStorageLimits.Response> results = AgentAction_GetStorageLimits.getStorageLimits(reqList);
        Test.stopTest();

        String msg = results[0].usageMessage;
        System.assert(msg.contains('['), 'Should have progress bar brackets');
        System.assert(msg.contains('Available:'), 'Should show available space');
        System.assert(msg.contains('Status:'), 'Should show status');
    }
    
    @isTest
    static void testStatusIcons() {
        // Test: Verify status icons are included
        AgentAction_GetStorageLimits.Request req = new AgentAction_GetStorageLimits.Request();
        List<AgentAction_GetStorageLimits.Request> reqList = new List<AgentAction_GetStorageLimits.Request>{req};

        Test.startTest();
        List<AgentAction_GetStorageLimits.Response> results = AgentAction_GetStorageLimits.getStorageLimits(reqList);
        Test.stopTest();

        // Verify we get a storage status
        System.assertNotEquals(null, results[0].storageStatus, 'Should have storage status');
        System.assert(
            results[0].storageStatus == 'Excellent' || 
            results[0].storageStatus == 'Good' || 
            results[0].storageStatus == 'Moderate' || 
            results[0].storageStatus == 'High' || 
            results[0].storageStatus == 'Critical',
            'Status should be one of the valid values'
        );
    }
}