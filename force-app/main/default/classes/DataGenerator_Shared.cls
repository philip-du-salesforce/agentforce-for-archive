/**
 * Shared logic for data generators: picklist values, simulated created date.
 * Optional custom field Simulated_Created_Date__c (DateTime) gives a spread of "ages" for archive testing.
 * CreatedDate cannot be set in Apex; use this field for reporting/archive policies that support custom date fields.
 */
public with sharing class DataGenerator_Shared {
    public static final String SIMULATED_DATE_FIELD = 'Simulated_Created_Date__c';
    /** Spread: 1–5 years ago (365 to 1825 days) */
    public static final Integer DAYS_AGO_MIN = 365;
    public static final Integer DAYS_AGO_SPAN = 1460;

    /** Return active picklist values for object.field, or fallback list if none. */
    public static List<String> getPicklistValues(Schema.SObjectType soType, String fieldName, List<String> fallback) {
        if (soType == null || String.isBlank(fieldName)) return fallback;
        Map<String, Schema.SObjectField> fmap = soType.getDescribe().fields.getMap();
        if (!fmap.containsKey(fieldName)) return fallback;
        Schema.DescribeFieldResult df = fmap.get(fieldName).getDescribe();
        if (!df.getType().name().equalsIgnoreCase('picklist')) return fallback;
        List<String> values = new List<String>();
        for (Schema.PicklistEntry pe : df.getPicklistValues()) {
            if (pe.isActive()) values.add(pe.getValue());
        }
        return values.isEmpty() ? fallback : values;
    }

    /** Set Simulated_Created_Date__c on so if the field exists. daysAgo = days in the past (e.g. 365–1825). */
    public static void setSimulatedCreatedDate(SObject so, Integer daysAgo) {
        if (so == null || daysAgo == null || daysAgo < 0) return;
        if (!so.getSObjectType().getDescribe().fields.getMap().containsKey(SIMULATED_DATE_FIELD)) return;
        so.put(SIMULATED_DATE_FIELD, DateTime.now().addDays(-daysAgo));
    }

    /** Days ago in range [DAYS_AGO_MIN, DAYS_AGO_MIN + DAYS_AGO_SPAN) using recordIndex for spread. */
    public static Integer daysAgoFromIndex(Integer recordIndex) {
        return DAYS_AGO_MIN + (Math.mod(Math.abs(recordIndex), DAYS_AGO_SPAN));
    }
}
