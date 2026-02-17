// Comprehensive Test: Enhanced Create Archive Policy
// Shows all new features with ContentDocuments, additional conditions, and templates

System.debug('========================================');
System.debug('ENHANCED CREATE ARCHIVE POLICY - DEMO');
System.debug('========================================\n');

// ============================================================================
// Example 1: Archive Closed Cases older than 1 year
// ============================================================================
System.debug('=== EXAMPLE 1: Closed Cases with Status Condition ===\n');

AgentAction_CreateArchivePolicy_Enhanced.Request req1 = 
    new AgentAction_CreateArchivePolicy_Enhanced.Request();
req1.policyName = 'Archive Closed Cases - 1 Year';
req1.targetObject = 'Case';
req1.retentionDays = 365;
req1.additionalConditions = 'IsClosed = true';
req1.archiveContentDocuments = true; // Archive files too!
req1.description = 'Archives closed cases older than 1 year including all related files';

List<AgentAction_CreateArchivePolicy_Enhanced.Response> responses1 = 
    AgentAction_CreateArchivePolicy_Enhanced.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy_Enhanced.Request>{ req1 }
    );

System.debug('Success: ' + responses1[0].isSuccess);
System.debug('Query: ' + responses1[0].queryPreview);
System.debug('\n' + responses1[0].message);
System.debug('\n' + responses1[0].policySummary);

// Cleanup
if(responses1[0].isSuccess) {
    try { Database.delete(responses1[0].policyId); } catch(Exception e) {}
}

// ============================================================================
// Example 2: Archive Won Opportunities (Using Template!)
// ============================================================================
System.debug('\n\n=== EXAMPLE 2: Won Opportunities Using Template ===\n');

AgentAction_CreateArchivePolicy_Enhanced.Request req2 = 
    new AgentAction_CreateArchivePolicy_Enhanced.Request();
req2.policyName = 'Archive Won Opportunities - 2 Years';
req2.retentionDays = 730;
req2.useTemplate = 'WonOpportunities'; // Template auto-fills!

List<AgentAction_CreateArchivePolicy_Enhanced.Response> responses2 = 
    AgentAction_CreateArchivePolicy_Enhanced.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy_Enhanced.Request>{ req2 }
    );

System.debug('Template Applied!');
System.debug('Query: ' + responses2[0].queryPreview);
System.debug('\n' + responses2[0].message);

// Cleanup
if(responses2[0].isSuccess) {
    try { Database.delete(responses2[0].policyId); } catch(Exception e) {}
}

// ============================================================================
// Example 3: Complex Conditions - Small Lost Opportunities
// ============================================================================
System.debug('\n\n=== EXAMPLE 3: Complex Conditions - Amount < $1000 AND Lost ===\n');

AgentAction_CreateArchivePolicy_Enhanced.Request req3 = 
    new AgentAction_CreateArchivePolicy_Enhanced.Request();
req3.policyName = 'Archive Small Lost Opportunities';
req3.targetObject = 'Opportunity';
req3.retentionDays = 180;
req3.additionalConditions = 'Amount < 1000 AND IsWon = false AND IsClosed = true';
req3.description = 'Archives small value opportunities that were lost';

List<AgentAction_CreateArchivePolicy_Enhanced.Response> responses3 = 
    AgentAction_CreateArchivePolicy_Enhanced.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy_Enhanced.Request>{ req3 }
    );

System.debug('Complex Query Built:');
System.debug(responses3[0].queryPreview);
System.debug('\n' + responses3[0].message);

// Cleanup
if(responses3[0].isSuccess) {
    try { Database.delete(responses3[0].policyId); } catch(Exception e) {}
}

// ============================================================================
// Example 4: Archive with ContentDocument Filter (Only PDFs)
// ============================================================================
System.debug('\n\n=== EXAMPLE 4: Archive Records + Only PDF Files ===\n');

AgentAction_CreateArchivePolicy_Enhanced.Request req4 = 
    new AgentAction_CreateArchivePolicy_Enhanced.Request();
req4.policyName = 'Archive Accounts with PDFs Only';
req4.targetObject = 'Account';
req4.retentionDays = 1825; // 5 years
req4.archiveContentDocuments = true;
req4.contentDocumentFilter = 'FileExtension = \'pdf\''; // Only PDF files!
req4.description = 'Archives old accounts but only their PDF attachments';

List<AgentAction_CreateArchivePolicy_Enhanced.Response> responses4 = 
    AgentAction_CreateArchivePolicy_Enhanced.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy_Enhanced.Request>{ req4 }
    );

System.debug('With ContentDocument Filter:');
System.debug('\n' + responses4[0].message);
System.debug('\n' + responses4[0].policySummary);

// Cleanup
if(responses4[0].isSuccess) {
    try { Database.delete(responses4[0].policyId); } catch(Exception e) {}
}

// ============================================================================
// Example 5: Using ClosedCases Template
// ============================================================================
System.debug('\n\n=== EXAMPLE 5: Using ClosedCases Template ===\n');

AgentAction_CreateArchivePolicy_Enhanced.Request req5 = 
    new AgentAction_CreateArchivePolicy_Enhanced.Request();
req5.policyName = 'Archive Closed Cases - Auto Template';
req5.retentionDays = 365;
req5.useTemplate = 'ClosedCases'; // Auto-applies Case object + IsClosed condition!

List<AgentAction_CreateArchivePolicy_Enhanced.Response> responses5 = 
    AgentAction_CreateArchivePolicy_Enhanced.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy_Enhanced.Request>{ req5 }
    );

System.debug('Template Result:');
System.debug('Query: ' + responses5[0].queryPreview);
System.debug('\n' + responses5[0].message);

// Cleanup
if(responses5[0].isSuccess) {
    try { Database.delete(responses5[0].policyId); } catch(Exception e) {}
}

// ============================================================================
// Example 6: Archive Large Files Only
// ============================================================================
System.debug('\n\n=== EXAMPLE 6: Archive with Large Files Filter ===\n');

AgentAction_CreateArchivePolicy_Enhanced.Request req6 = 
    new AgentAction_CreateArchivePolicy_Enhanced.Request();
req6.policyName = 'Archive Cases with Large Files';
req6.targetObject = 'Case';
req6.retentionDays = 365;
req6.additionalConditions = 'IsClosed = true';
req6.archiveContentDocuments = true;
req6.contentDocumentFilter = 'ContentSize > 5000000'; // Files > 5MB
req6.description = 'Archives closed cases and their large attachments (>5MB)';

List<AgentAction_CreateArchivePolicy_Enhanced.Response> responses6 = 
    AgentAction_CreateArchivePolicy_Enhanced.createArchivePolicy(
        new List<AgentAction_CreateArchivePolicy_Enhanced.Request>{ req6 }
    );

System.debug('Large Files Filter:');
System.debug('\n' + responses6[0].message);

// Cleanup
if(responses6[0].isSuccess) {
    try { Database.delete(responses6[0].policyId); } catch(Exception e) {}
}

System.debug('\n========================================');
System.debug('ALL EXAMPLES COMPLETED');
System.debug('========================================');
