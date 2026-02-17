// Test: Analyze Object for Archiving
// Demo with Cases in your org

System.debug('========================================');
System.debug('ANALYZE OBJECT FOR ARCHIVING - DEMO');
System.debug('========================================\n');

// Test 1: Analyze Cases
System.debug('=== Analyzing Case Object ===\n');

AgentAction_AnalyzeObjectForArchiving.Request req1 = new AgentAction_AnalyzeObjectForArchiving.Request();
req1.objectName = 'Case';
req1.includeRecommendations = true;

List<AgentAction_AnalyzeObjectForArchiving.Response> responses1 = 
    AgentAction_AnalyzeObjectForArchiving.analyzeObject(
        new List<AgentAction_AnalyzeObjectForArchiving.Request>{req1}
    );

System.debug(responses1[0].analysisMessage);
System.debug('\nTotal Records: ' + responses1[0].totalRecords);
System.debug('Archivable Records: ' + responses1[0].archivableRecords);
System.debug('Has Opportunities: ' + responses1[0].hasOpportunities);
System.debug('Recommended Conditions: ' + responses1[0].recommendedConditions);

System.debug('\n========================================');
System.debug('Analysis complete!');
System.debug('========================================');
