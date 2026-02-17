// Scope size = 1 so each execute() gets one batch (2000 records), under 10k DML limit
// Use 0 padding: org has field-level encryption; writing to Description fails without key
// Start Contact batch (500k records, no Description to avoid encryption error)
Id contactJobId = Database.executeBatch(new DataGenerator_ContactBatch(500000, 2000, 0), 1);
System.debug('Contact batch job started: ' + contactJobId);

// Start Case batch (500k records, no Description to avoid encryption error)
Id caseJobId = Database.executeBatch(new DataGenerator_CaseBatch(500000, 2000, 0), 1);
System.debug('Case batch job started: ' + caseJobId);

System.debug('Both jobs queued. Monitor in Setup → Environments → Jobs → Apex Jobs.');
