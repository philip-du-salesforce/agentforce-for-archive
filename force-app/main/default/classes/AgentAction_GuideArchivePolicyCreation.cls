public with sharing class AgentAction_GuideArchivePolicyCreation {
    
    public class Request {
        @InvocableVariable(label='Object to Archive' description='API Name of the object (e.g. Case, Opportunity, Account)' required=true)
        public String targetObject;

        @InvocableVariable(label='Retention Days' description='Archive records older than this many days' required=true)
        public Integer retentionDays;
        
        @InvocableVariable(label='Additional Conditions' description='Optional: Additional WHERE conditions (e.g., Status = \'Closed\')')
        public String additionalConditions;
        
        @InvocableVariable(label='Run Frequency' description='How often to run: None, Daily, Weekly, Monthly. Default: None')
        public String runFrequency;

        @InvocableVariable(label='Policy Name' description='Optional: Custom name for the policy')
        public String policyName;
    }
    
    public class Response {
        @InvocableVariable(label='Success Message' description='Step-by-step guide with direct links')
        public String message;
        
        @InvocableVariable(label='Setup URL' description='Direct link to Archive Policies setup')
        public String setupUrl;
        
        @InvocableVariable(label='SOQL Query' description='Exact query to paste in Setup')
        public String soqlQuery;
        
        @InvocableVariable(label='Policy Name' description='Suggested policy name')
        public String suggestedPolicyName;
        
        @InvocableVariable(label='Is Success' description='Whether guide was generated')
        public Boolean isSuccess;
    }
    
    @InvocableMethod(label='Guide Archive Policy Creation' description='Provides step-by-step instructions to create native archive policy in Setup UI.')
    public static List<Response> guideCreation(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            
            try {
                // Validate inputs
                if (String.isBlank(req.targetObject)) {
                    throw new IllegalArgumentException('Object to Archive is required.');
                }
                if (req.retentionDays == null || req.retentionDays < 1) {
                    throw new IllegalArgumentException('Retention Days must be greater than 0.');
                }
                
                // Verify object exists
                if (!Schema.getGlobalDescribe().containsKey(req.targetObject)) {
                    throw new IllegalArgumentException('Object "' + req.targetObject + '" does not exist.');
                }
                
                // Build SOQL query
                List<String> conditions = new List<String>();
                conditions.add('CreatedDate < LAST_N_DAYS:' + req.retentionDays);
                
                if (String.isNotBlank(req.additionalConditions)) {
                    conditions.add('(' + req.additionalConditions + ')');
                }
                
                String query = 'SELECT Id FROM ' + req.targetObject + 
                              ' WHERE ' + String.join(conditions, ' AND ');
                res.soqlQuery = query;
                
                // Generate policy name
                String policyName = String.isNotBlank(req.policyName) ? 
                                   req.policyName : 
                                   buildPolicyName(req);
                res.suggestedPolicyName = policyName;
                
                // Archive Policies list view (Archive app tab, not Setup)
                res.setupUrl = getArchivePoliciesListUrl();
                
                // Build success message with instructions
                res.isSuccess = true;
                res.message = buildInstructions(req, res);
                
            } catch (Exception e) {
                res.isSuccess = false;
                res.message = '✗ Error generating guide: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Guide Generation Error: ' + e.getMessage());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
    
    // Archive Policies live in the Archive app tab, not Setup
    private static String getArchivePoliciesListUrl() {
        String host = URL.getOrgDomainUrl().getHost();
        if (String.isNotBlank(host) && host.contains('.my.salesforce.com')) {
            String lightningHost = host.replace('.my.salesforce.com', '.lightning.force.com');
            return 'https://' + lightningHost + '/lightning/n/standard-ArchivePoliciesListView';
        }
        return URL.getOrgDomainUrl().toExternalForm() + '/lightning/n/standard-ArchivePoliciesListView';
    }
    
    private static String buildPolicyName(Request req) {
        String retentionPeriod = formatRetentionPeriod(req.retentionDays);
        String name = 'Archive ' + req.targetObject;
        
        if (String.isNotBlank(req.additionalConditions)) {
            // Try to extract a meaningful condition (e.g., Status = 'Closed')
            if (req.additionalConditions.containsIgnoreCase('Closed')) {
                name += ' (Closed)';
            } else if (req.additionalConditions.containsIgnoreCase('Status')) {
                name += ' (By Status)';
            }
        }
        
        name += ' - Older Than ' + retentionPeriod;
        return name;
    }
    
    private static String buildInstructions(Request req, Response res) {
        String retentionPeriod = formatRetentionPeriod(req.retentionDays);
        String frequency = String.isNotBlank(req.runFrequency) ? req.runFrequency : 'None';
        
        String msg = '';
        if (String.isNotBlank(req.additionalConditions)) {
            msg += 'Based on your **' + req.targetObject + '** analysis — here\'s your policy setup.\n\n';
        }
        msg += '✓ Archive Policy Configuration Ready!\n\n';
        
        // Configuration Summary
        msg += '📋 Policy Configuration\n';
        msg += '---\n';
        msg += '📦 Root Object: ' + req.targetObject + '\n';
        msg += '📅 Data Protected for Days: ' + req.retentionDays + ' (' + retentionPeriod + ')\n';
        
        if (String.isNotBlank(req.additionalConditions)) {
            msg += '🔍 Conditions: ' + req.additionalConditions + '\n';
        }
        
        if (frequency != 'None') {
            msg += '⏰ Schedule: ' + frequency + '\n';
        }
        
        msg += '\n';
        
        // Step-by-step instructions matching the actual Archive app wizard
        msg += '🛠️ Setup Instructions (Archive app wizard)\n';
        msg += '---\n';
        msg += 'Reference: https://help.salesforce.com/s/articleView?id=xcloud.archive_create_policies.htm\n\n';
        
        msg += '1️⃣ Open the Archive Policies tab\n';
        msg += '  Click here: ' + res.setupUrl + '\n';
        msg += '  Or: Open the **Archive** app → **Archive Policies** tab → click **New**\n\n';
        
        msg += '2️⃣ Select action type: **Archive Salesforce Data** → **Next**\n\n';
        
        msg += '3️⃣ Policy Details\n';
        msg += '  • Policy Name: ' + res.suggestedPolicyName + '\n';
        msg += '  • Description: (optional, e.g. archives ' + req.targetObject + ' older than ' + retentionPeriod + ')\n';
        msg += '  • Enable Policy: checked → **Next**\n\n';
        
        msg += '4️⃣ Define Policy Scope\n';
        msg += '  • Root Object to Archive: **' + req.targetObject + '**\n';
        msg += '  • Query Mode: **Filter**\n';
        msg += '  • In **SOQL Query**, paste this:\n';
        msg += '---\n';
        msg += res.soqlQuery + '\n';
        msg += '---\n';
        msg += '  • Data Protected for Days: **' + req.retentionDays + '**\n';
        msg += '  • Archive Related Files and Attachments: (check if you want files archived too)\n';
        msg += '  → **Next**\n\n';
        
        msg += '5️⃣ Related Object Selection (optional)\n';
        msg += '  Leave default or select related objects to include → **Next**\n\n';
        
        msg += '6️⃣ Policy Schedule & Retention\n';
        msg += '  • Schedule Policy: set **Every** (e.g. Week), **On**, **At** (UTC)\n';
        msg += '  • Retention Policy: Source = **Archived Date**, Years/Months as needed\n';
        msg += '  → **Save & Close**\n\n';
        
        msg += '✓ Policy will appear in the Policies list and can run on the schedule you set.\n\n';
        
        msg += '📊 After Creation\n';
        msg += '---\n';
        msg += '  Ask me: "List my archive policies" to verify!\n\n';
        
        msg += '💡 Pro Tips\n';
        msg += '---\n';
        msg += '  • Test the SOQL query in Developer Console first\n';
        msg += '  • Data Protected for Days = how long archived data is kept before purge\n';
        msg += '  • Full guide: https://help.salesforce.com/s/articleView?id=xcloud.archive_create_policies.htm\n';
        
        return msg;
    }
    
    private static String formatRetentionPeriod(Integer days) {
        if (days == null || days <= 0) return days + ' days';
        
        if (days >= 365) {
            Decimal years = Decimal.valueOf(days) / 365;
            if (Math.mod(days, 365) == 0) {
                Integer yearCount = years.intValue();
                return yearCount + ' year' + (yearCount > 1 ? 's' : '');
            }
            return years.setScale(1) + ' years';
        } else if (days >= 30) {
            Decimal months = Decimal.valueOf(days) / 30;
            if (Math.mod(days, 30) == 0) {
                Integer monthCount = months.intValue();
                return monthCount + ' month' + (monthCount > 1 ? 's' : '');
            }
            return months.setScale(1) + ' months';
        } else if (days == 7) {
            return '1 week';
        } else if (days == 14) {
            return '2 weeks';
        }
        return days + ' days';
    }
}
