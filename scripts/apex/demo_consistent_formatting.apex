// Demo: Consistent Formatting Across All Actions
// Shows the unified look and feel

System.debug('========================================');
System.debug('TESTING CONSISTENT FORMATTING');
System.debug('========================================\n');

// Test 1: Get Storage Limits
System.debug('=== ACTION 1: Get Storage Limits ===\n');
AgentAction_GetStorageLimits.Request req1 = new AgentAction_GetStorageLimits.Request();
req1.includeRecommendations = true;
List<AgentAction_GetStorageLimits.Response> responses1 = 
    AgentAction_GetStorageLimits.getStorageLimits(new List<AgentAction_GetStorageLimits.Request>{req1});
System.debug(responses1[0].usageMessage);

System.debug('\n\n========================================\n');

// Test 2: Top Storage Consumers
System.debug('=== ACTION 2: Top Storage Consumers ===\n');
AgentAction_TopStorageConsumers.Request req2 = new AgentAction_TopStorageConsumers.Request();
req2.numberToShow = 5;
List<AgentAction_TopStorageConsumers.Response> responses2 = 
    AgentAction_TopStorageConsumers.identifyTopConsumers(new List<AgentAction_TopStorageConsumers.Request>{req2});
System.debug(responses2[0].analysisResult);

System.debug('\n\n========================================\n');

// Test 3: Find Large Files
System.debug('=== ACTION 3: Find Large Files ===\n');
AgentAction_FindLargeFiles.Request req3 = new AgentAction_FindLargeFiles.Request();
req3.numberOfFiles = 5;
List<AgentAction_FindLargeFiles.Response> responses3 = 
    AgentAction_FindLargeFiles.findLargeFiles(new List<AgentAction_FindLargeFiles.Request>{req3});
System.debug(responses3[0].fileDetails);

System.debug('\n\n========================================\n');

// Test 4: Analyze Object for Archiving
System.debug('=== ACTION 4: Analyze Object for Archiving ===\n');
AgentAction_AnalyzeObjectForArchiving.Request req4 = new AgentAction_AnalyzeObjectForArchiving.Request();
req4.objectName = 'Case';
req4.includeRecommendations = true;
List<AgentAction_AnalyzeObjectForArchiving.Response> responses4 = 
    AgentAction_AnalyzeObjectForArchiving.analyzeObject(new List<AgentAction_AnalyzeObjectForArchiving.Request>{req4});
System.debug(responses4[0].analysisMessage);

System.debug('\n\n========================================');
System.debug('ALL ACTIONS NOW HAVE CONSISTENT FORMATTING!');
System.debug('========================================');
System.debug('\nKey improvements:');
System.debug('✓ All actions use section headers with emojis');
System.debug('✓ All actions use divider lines (━━━━━━━━━━━━━━━━━━━━━━━━━━━━)');
System.debug('✓ All actions include "What you can do next?" suggestions');
System.debug('✓ All actions use consistent bullet formatting');
System.debug('✓ All actions use formatted numbers with commas');
