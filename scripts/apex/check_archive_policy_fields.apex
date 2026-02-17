// Check ArchivePolicyDefinition fields and picklist values

System.debug('========================================');
System.debug('ARCHIVE POLICY DEFINITION FIELD INFO');
System.debug('========================================\n');

Schema.DescribeSObjectResult describeResult = Schema.SObjectType.ArchivePolicyDefinition;
Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();

// Check Type field
if (fieldMap.containsKey('Type')) {
    Schema.DescribeFieldResult typeField = fieldMap.get('Type').getDescribe();
    System.debug('TYPE Field Picklist Values:');
    for (Schema.PicklistEntry ple : typeField.getPicklistValues()) {
        System.debug('  • ' + ple.getLabel() + ' (Value: ' + ple.getValue() + ')');
    }
} else {
    System.debug('⚠️ Type field not found');
}

System.debug('\n========================================');
System.debug('KEY FIELDS MAPPING');
System.debug('========================================\n');
System.debug('Salesforce Native Archive Fields:');
System.debug('  • DeveloperName (API Name - alphanumeric + underscores only)');
System.debug('  • MasterLabel (Display Label)');
System.debug('  • Query (SOQL query to identify records)');
System.debug('  • IsActive (Boolean - activate the policy)');
System.debug('  • Description (Text description)');
System.debug('  • RootEntityName (Object being archived, e.g., "Case")');
System.debug('  • Type (Picklist - see values above)');
System.debug('  • RunFrequency (None, Daily, Weekly, Monthly)');
System.debug('  • QueryLimit (Max records per run)');
System.debug('  • DataProtectionThreshold (Integer)');
System.debug('  • Language (Defaults to org language)');

System.debug('\n========================================');
