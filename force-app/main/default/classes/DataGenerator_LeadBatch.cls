/**
 * Batch job to generate Lead records with rich data for archive testing:
 * - Varying Status (Open, Closed - Converted, etc.) from org picklist
 * - Optional Simulated_Created_Date__c (1–5 years ago) if field exists
 * Use scope size 1 when calling executeBatch.
 */
public with sharing class DataGenerator_LeadBatch implements Database.Batchable<Integer> {
    private final Integer totalRecords;
    private final Integer batchSize;
    private static final String DEFAULT_COMPANY = 'Data Generator Company';
    private List<String> statusValues;

    public DataGenerator_LeadBatch(Integer totalRecords, Integer batchSize) {
        this.totalRecords = totalRecords != null && totalRecords > 0 ? totalRecords : 10000;
        this.batchSize = (batchSize != null && batchSize > 0 && batchSize <= 2000) ? batchSize : 2000;
    }

    public DataGenerator_LeadBatch(Integer totalRecords) {
        this(totalRecords, 2000);
    }

    public Iterable<Integer> start(Database.BatchableContext bc) {
        statusValues = DataGenerator_Shared.getPicklistValues(Lead.SObjectType, 'Status', new List<String>{ 'Open - Not Contacted', 'Working - Contacted', 'Closed - Converted', 'Closed - Not Converted' });

        Integer numBatches = (Integer) Math.ceil((Decimal) totalRecords / batchSize);
        List<Integer> batchIndices = new List<Integer>();
        for (Integer i = 0; i < numBatches; i++) batchIndices.add(i);
        return batchIndices;
    }

    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        List<Lead> leads = new List<Lead>();
        Integer statusCount = statusValues.size();

        for (Integer batchIndex : scope) {
            Integer startRow = batchIndex * batchSize;
            for (Integer i = 0; i < batchSize && (startRow + i) < totalRecords; i++) {
                Integer globalIndex = startRow + i;
                Lead l = new Lead(
                    LastName = 'Lead_' + globalIndex,
                    Company = DEFAULT_COMPANY,
                    Status = statusValues[Math.mod(globalIndex, statusCount)]
                );
                DataGenerator_Shared.setSimulatedCreatedDate(l, DataGenerator_Shared.daysAgoFromIndex(globalIndex));
                leads.add(l);
            }
        }
        if (!leads.isEmpty()) insert leads;
    }

    public void finish(Database.BatchableContext bc) { }
}
