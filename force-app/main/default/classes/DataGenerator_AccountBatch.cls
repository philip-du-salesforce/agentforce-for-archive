/**
 * Batch job to generate Account records. No dependencies.
 * Use scope size 1 when calling executeBatch so each execute() inserts 2000 rows (under 10k DML limit).
 */
public with sharing class DataGenerator_AccountBatch implements Database.Batchable<Integer> {
    private final Integer totalRecords;
    private final Integer batchSize;

    public DataGenerator_AccountBatch(Integer totalRecords, Integer batchSize) {
        this.totalRecords = totalRecords != null && totalRecords > 0 ? totalRecords : 10000;
        this.batchSize = (batchSize != null && batchSize > 0 && batchSize <= 2000) ? batchSize : 2000;
    }

    public DataGenerator_AccountBatch(Integer totalRecords) {
        this(totalRecords, 2000);
    }

    public Iterable<Integer> start(Database.BatchableContext bc) {
        Integer numBatches = (Integer) Math.ceil((Decimal) totalRecords / batchSize);
        List<Integer> batchIndices = new List<Integer>();
        for (Integer i = 0; i < numBatches; i++) {
            batchIndices.add(i);
        }
        return batchIndices;
    }

    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        List<Account> accounts = new List<Account>();
        for (Integer batchIndex : scope) {
            Integer startRow = batchIndex * batchSize;
            for (Integer i = 0; i < batchSize && (startRow + i) < totalRecords; i++) {
                Integer globalIndex = startRow + i;
                Account a = new Account(Name = 'Account_' + globalIndex);
                DataGenerator_Shared.setSimulatedCreatedDate(a, DataGenerator_Shared.daysAgoFromIndex(globalIndex));
                accounts.add(a);
            }
        }
        if (!accounts.isEmpty()) {
            insert accounts;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
