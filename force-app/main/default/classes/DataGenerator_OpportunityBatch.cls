/**
 * Batch job to generate Opportunity records with rich data for archive testing:
 * - Varying StageName (Prospecting, Closed Won, Closed Lost, etc.) from org picklist
 * - CloseDate: past for closed stages, future for open
 * - Optional Simulated_Created_Date__c (1–5 years ago) if field exists
 * Use scope size 1 when calling executeBatch.
 */
public with sharing class DataGenerator_OpportunityBatch implements Database.Batchable<Integer> {
    private final Integer totalRecords;
    private final Integer batchSize;
    private Id accountId;
    private List<String> stageValues;

    public DataGenerator_OpportunityBatch(Integer totalRecords, Integer batchSize) {
        this.totalRecords = totalRecords != null && totalRecords > 0 ? totalRecords : 10000;
        this.batchSize = (batchSize != null && batchSize > 0 && batchSize <= 2000) ? batchSize : 2000;
    }

    public DataGenerator_OpportunityBatch(Integer totalRecords) {
        this(totalRecords, 2000);
    }

    public Iterable<Integer> start(Database.BatchableContext bc) {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        if (accounts.isEmpty()) {
            Account a = new Account(Name = 'Data Generator Account');
            insert a;
            accountId = a.Id;
        } else {
            accountId = accounts[0].Id;
        }
        stageValues = DataGenerator_Shared.getPicklistValues(Opportunity.SObjectType, 'StageName', new List<String>{ 'Prospecting', 'Closed Won', 'Closed Lost' });

        Integer numBatches = (Integer) Math.ceil((Decimal) totalRecords / batchSize);
        List<Integer> batchIndices = new List<Integer>();
        for (Integer i = 0; i < numBatches; i++) batchIndices.add(i);
        return batchIndices;
    }

    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        List<Opportunity> opps = new List<Opportunity>();
        Integer stageCount = stageValues.size();

        for (Integer batchIndex : scope) {
            Integer startRow = batchIndex * batchSize;
            for (Integer i = 0; i < batchSize && (startRow + i) < totalRecords; i++) {
                Integer globalIndex = startRow + i;
                String stage = stageValues[Math.mod(globalIndex, stageCount)];
                Boolean isClosed = stage.containsIgnoreCase('Closed');
                Date closeDate = isClosed ? Date.today().addDays(-(30 + Math.mod(globalIndex, 400))) : Date.today().addDays(30 + Math.mod(globalIndex, 90));

                Opportunity o = new Opportunity(
                    Name = 'Opportunity_' + globalIndex,
                    AccountId = accountId,
                    StageName = stage,
                    CloseDate = closeDate
                );
                DataGenerator_Shared.setSimulatedCreatedDate(o, DataGenerator_Shared.daysAgoFromIndex(globalIndex));
                opps.add(o);
            }
        }
        if (!opps.isEmpty()) {
            insert opps;
        }
    }

    public void finish(Database.BatchableContext bc) { }
}
