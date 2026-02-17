// Demo: Enhanced Get Storage Limits with Beautiful Visualizations
// Shows the new progress bars, status icons, and smart recommendations

System.debug('========================================');
System.debug('ENHANCED STORAGE LIMITS VISUALIZATION');
System.debug('========================================\n');

// ============================================================================
// Example 1: Get All Storage Info (Default - with recommendations)
// ============================================================================
System.debug('=== EXAMPLE 1: Complete Storage Overview ===\n');

AgentAction_GetStorageLimits.Request req1 = new AgentAction_GetStorageLimits.Request();
// No parameters - shows everything!

List<AgentAction_GetStorageLimits.Response> responses1 = 
    AgentAction_GetStorageLimits.getStorageLimits(
        new List<AgentAction_GetStorageLimits.Request>{ req1 }
    );

System.debug('FULL OUTPUT:');
System.debug(responses1[0].usageMessage);
System.debug('\nSTATUS: ' + responses1[0].storageStatus);
System.debug('DATA USAGE: ' + responses1[0].dataUsagePercent + '%');
System.debug('FILE USAGE: ' + responses1[0].fileUsagePercent + '%');

// ============================================================================
// Example 2: Data Storage Only
// ============================================================================
System.debug('\n\n=== EXAMPLE 2: Data Storage Only ===\n');

AgentAction_GetStorageLimits.Request req2 = new AgentAction_GetStorageLimits.Request();
req2.limitType = 'Data';

List<AgentAction_GetStorageLimits.Response> responses2 = 
    AgentAction_GetStorageLimits.getStorageLimits(
        new List<AgentAction_GetStorageLimits.Request>{ req2 }
    );

System.debug(responses2[0].usageMessage);

// ============================================================================
// Example 3: File Storage Only
// ============================================================================
System.debug('\n\n=== EXAMPLE 3: File Storage Only ===\n');

AgentAction_GetStorageLimits.Request req3 = new AgentAction_GetStorageLimits.Request();
req3.limitType = 'File';

List<AgentAction_GetStorageLimits.Response> responses3 = 
    AgentAction_GetStorageLimits.getStorageLimits(
        new List<AgentAction_GetStorageLimits.Request>{ req3 }
    );

System.debug(responses3[0].usageMessage);

// ============================================================================
// Example 4: Without Recommendations (Clean View)
// ============================================================================
System.debug('\n\n=== EXAMPLE 4: Clean View (No Recommendations) ===\n');

AgentAction_GetStorageLimits.Request req4 = new AgentAction_GetStorageLimits.Request();
req4.includeRecommendations = false;

List<AgentAction_GetStorageLimits.Response> responses4 = 
    AgentAction_GetStorageLimits.getStorageLimits(
        new List<AgentAction_GetStorageLimits.Request>{ req4 }
    );

System.debug(responses4[0].usageMessage);

System.debug('\n========================================');
System.debug('DEMO COMPLETE');
System.debug('========================================');
System.debug('\n💡 The visualization includes:');
System.debug('  ✓ Progress bars with █ and ░ characters');
System.debug('  ✓ Color-coded status icons (🟢 🟡 🟠 🔴)');
System.debug('  ✓ Available space calculations');
System.debug('  ✓ Smart recommendations based on usage');
System.debug('  ✓ Context-aware next steps');
