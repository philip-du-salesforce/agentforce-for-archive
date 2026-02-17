/**
 * Batch job to generate Case records with rich data for archive testing:
 * - Varying Status (New, Working, Closed, etc.) from org picklist
 * - Optional Simulated_Created_Date__c (1–5 years ago) if field exists
 * Use scope size 1 when calling executeBatch.
 */
public with sharing class DataGenerator_CaseBatch implements Database.Batchable<Integer> {
    private final Integer totalRecords;
    private final Integer batchSize;
    private final Integer descriptionPaddingBytes;
    private Id accountId;
    private List<String> statusValues;

    public DataGenerator_CaseBatch(Integer totalRecords, Integer batchSize, Integer descriptionPaddingBytes) {
        this.totalRecords = totalRecords != null && totalRecords > 0 ? totalRecords : 10000;
        this.batchSize = (batchSize != null && batchSize > 0 && batchSize <= 2000) ? batchSize : 2000;
        this.descriptionPaddingBytes = (descriptionPaddingBytes != null && descriptionPaddingBytes >= 0) ? descriptionPaddingBytes : 0;
    }

    public DataGenerator_CaseBatch(Integer totalRecords) {
        this(totalRecords, 2000, 0);
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
        statusValues = DataGenerator_Shared.getPicklistValues(Case.SObjectType, 'Status', new List<String>{ 'New', 'Working', 'Closed' });

        Integer numBatches = (Integer) Math.ceil((Decimal) totalRecords / batchSize);
        List<Integer> batchIndices = new List<Integer>();
        for (Integer i = 0; i < numBatches; i++) batchIndices.add(i);
        return batchIndices;
    }

    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        List<Case> cases = new List<Case>();
        Integer padLen = descriptionPaddingBytes > 0 ? Math.min(descriptionPaddingBytes, 32000) : 0;
        String padding = padLen > 0 ? buildPadding(padLen) : '';
        Integer statusCount = statusValues.size();

        for (Integer batchIndex : scope) {
            Integer startRow = batchIndex * batchSize;
            for (Integer i = 0; i < batchSize && (startRow + i) < totalRecords; i++) {
                Integer globalIndex = startRow + i;
                Case c = new Case(
                    AccountId = accountId,
                    Subject = 'Case_' + globalIndex,
                    Status = statusValues[Math.mod(globalIndex, statusCount)]
                );
                if (padLen > 0) c.Description = padding;
                DataGenerator_Shared.setSimulatedCreatedDate(c, DataGenerator_Shared.daysAgoFromIndex(globalIndex));
                cases.add(c);
            }
        }
        if (!cases.isEmpty()) insert cases;
    }

    public void finish(Database.BatchableContext bc) { }

    private static String buildPadding(Integer len) {
        String chunk = '';
        for (Integer i = 0; i < 100 && chunk.length() < 100; i++) chunk += 'X';
        String result = '';
        while (result.length() < len) result += chunk;
        return result.length() > len ? result.substring(0, len) : result;
    }
}
