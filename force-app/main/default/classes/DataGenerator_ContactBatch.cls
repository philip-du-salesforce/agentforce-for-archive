/**
 * Batch job to generate Contact records for storage testing.
 * Run multiple times or increase totalRecords to build toward ~5 GB.
 * ~5 GB ≈ 250,000–500,000 contacts (with optional description padding).
 */
public with sharing class DataGenerator_ContactBatch implements Database.Batchable<Integer> {
    private final Integer totalRecords;
    private final Integer batchSize;
    private final Integer descriptionPaddingBytes;
    private Id accountId;

    /**
     * @param totalRecords  Total Contacts to create in this run (e.g. 10000).
     * @param batchSize     Records per batch (max 2000; default 2000).
     * @param descriptionPaddingBytes  Optional. Add this many bytes to Description per record to increase storage (e.g. 10240 = ~10 KB).
     */
    public DataGenerator_ContactBatch(Integer totalRecords, Integer batchSize, Integer descriptionPaddingBytes) {
        this.totalRecords = totalRecords != null && totalRecords > 0 ? totalRecords : 10000;
        this.batchSize = (batchSize != null && batchSize > 0 && batchSize <= 2000) ? batchSize : 2000;
        this.descriptionPaddingBytes = (descriptionPaddingBytes != null && descriptionPaddingBytes >= 0) ? descriptionPaddingBytes : 0;
    }

    public DataGenerator_ContactBatch(Integer totalRecords) {
        this(totalRecords, 2000, 0);
    }

    public Iterable<Integer> start(Database.BatchableContext bc) {
        // Use or create a single Account for all Contacts
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        if (accounts.isEmpty()) {
            Account a = new Account(Name = 'Data Generator Account');
            insert a;
            accountId = a.Id;
        } else {
            accountId = accounts[0].Id;
        }

        Integer numBatches = (Integer) Math.ceil((Decimal) totalRecords / batchSize);
        List<Integer> batchIndices = new List<Integer>();
        for (Integer i = 0; i < numBatches; i++) {
            batchIndices.add(i);
        }
        return batchIndices;
    }

    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        List<Contact> contacts = new List<Contact>();
        Integer padLen = descriptionPaddingBytes > 0 ? Math.min(descriptionPaddingBytes, 32000) : 0;
        String padding = padLen > 0 ? buildPadding(padLen) : '';

        for (Integer batchIndex : scope) {
            Integer startRow = batchIndex * batchSize;
            for (Integer i = 0; i < batchSize && (startRow + i) < totalRecords; i++) {
                Integer globalIndex = startRow + i;
                Contact c = new Contact(AccountId = accountId, LastName = 'Contact_' + globalIndex);
                if (padLen > 0) c.Description = padding;
                DataGenerator_Shared.setSimulatedCreatedDate(c, DataGenerator_Shared.daysAgoFromIndex(globalIndex));
                contacts.add(c);
            }
        }

        if (!contacts.isEmpty()) {
            insert contacts;
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Optional: notify or log
    }

    private static String buildPadding(Integer len) {
        String chunk = '';
        for (Integer i = 0; i < 100 && chunk.length() < 100; i++) chunk += 'X';
        String result = '';
        while (result.length() < len) {
            result += chunk;
        }
        return result.length() > len ? result.substring(0, len) : result;
    }
}
