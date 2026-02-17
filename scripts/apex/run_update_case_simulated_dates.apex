// Set Simulated_Created_Date__c on all Cases to random dates between now and 3 years ago
// 200 cases per batch (under 10k DML)
Database.executeBatch(new DataGenerator_UpdateCaseSimulatedDates(), 200);
