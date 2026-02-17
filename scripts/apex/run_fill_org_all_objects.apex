// Fill org with as much data as possible: Accounts, Contacts, Cases, Leads, Opportunities
// Scope size = 1 so each execute() inserts 2000 rows (under 10k DML limit). No Description (avoids encryption).

Integer totalPerObject = 500000;  // 500k per object = 2.5M records total. Increase if org has capacity.
Integer batchSize = 2000;
Integer scopeSize = 1;

Id jobAccounts = Database.executeBatch(new DataGenerator_AccountBatch(totalPerObject, batchSize), scopeSize);
Id jobContacts = Database.executeBatch(new DataGenerator_ContactBatch(totalPerObject, batchSize, 0), scopeSize);
Id jobCases    = Database.executeBatch(new DataGenerator_CaseBatch(totalPerObject, batchSize, 0), scopeSize);
Id jobLeads    = Database.executeBatch(new DataGenerator_LeadBatch(totalPerObject, batchSize), scopeSize);
Id jobOpps     = Database.executeBatch(new DataGenerator_OpportunityBatch(totalPerObject, batchSize), scopeSize);

System.debug('Accounts job: ' + jobAccounts);
System.debug('Contacts job: ' + jobContacts);
System.debug('Cases job: ' + jobCases);
System.debug('Leads job: ' + jobLeads);
System.debug('Opportunities job: ' + jobOpps);
System.debug('All 5 jobs queued. Monitor: Setup → Environments → Jobs → Apex Jobs.');
