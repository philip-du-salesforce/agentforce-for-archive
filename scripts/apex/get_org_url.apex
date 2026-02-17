// Get your org's instance URL for Remote Site Settings

System.debug('========================================');
System.debug('YOUR ORG INSTANCE URL');
System.debug('========================================\n');

String instanceUrl = URL.getOrgDomainUrl().toExternalForm();
System.debug('Instance URL: ' + instanceUrl);

System.debug('\n========================================');
System.debug('REMOTE SITE SETTING CONFIGURATION');
System.debug('========================================');
System.debug('Copy this URL for your Remote Site Setting:');
System.debug('\n  ' + instanceUrl);
System.debug('\nSetup Steps:');
System.debug('1. Setup → Security → Remote Site Settings');
System.debug('2. Click "New Remote Site"');
System.debug('3. Remote Site Name: SalesforceToolingAPI');
System.debug('4. Remote Site URL: ' + instanceUrl);
System.debug('5. Active: ✓ Checked');
System.debug('6. Save');
