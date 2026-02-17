public with sharing class AgentAction_AnalyzeObjectForArchiving {
    
    public class Request {
        @InvocableVariable(label='Object Name' description='API name of the object to analyse (e.g., Case, Opportunity, Account)' required=true)
        public String objectName;
        
        @InvocableVariable(label='Include Recommendations' description='Include archive policy recommendations. Default: true')
        public Boolean includeRecommendations;
    }
    
    public class Response {
        @InvocableVariable(label='Analysis Message' description='Complete analysis with breakdowns and recommendations')
        public String analysisMessage;
        
        @InvocableVariable(label='Total Records' description='Total number of records in the object')
        public Integer totalRecords;
        
        @InvocableVariable(label='Archivable Records' description='Number of records that could be archived')
        public Integer archivableRecords;
        
        @InvocableVariable(label='Recommended Conditions' description='Suggested archive policy conditions')
        public String recommendedConditions;
        
        @InvocableVariable(label='Object Label' description='Display label of the object')
        public String objectLabel;
        
        @InvocableVariable(label='Has Opportunities' description='Whether there are significant archival opportunities')
        public Boolean hasOpportunities;
        
        @InvocableVariable(label='Suggested Retention Days' description='Recommended retention in days for policy creation (e.g. 365). Use with Guide Archive Policy Creation.')
        public Integer suggestedRetentionDays;
        
        @InvocableVariable(label='Object API Name' description='API name of the analysed object. Use as targetObject when calling Guide Archive Policy Creation.')
        public String objectApiName;
    }
    
    @InvocableMethod(label='Analyse Object for Archiving' description='Analyses an object to identify archival opportunities with intelligent recommendations.')
    public static List<Response> analyzeObject(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            
            try {
                // Validate object exists
                if (!Schema.getGlobalDescribe().containsKey(req.objectName)) {
                    res.analysisMessage = '❌ Error: Object "' + req.objectName + '" not found.\n\n' +
                                         'Please check the object API name and try again.';
                    res.hasOpportunities = false;
                    responses.add(res);
                    continue;
                }
                
                // Get object metadata
                Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(req.objectName);
                Schema.DescribeSObjectResult objDescribe = sObjType.getDescribe();
                res.objectLabel = objDescribe.getLabel();
                
                // Check if object has CreatedDate (required for age-based archiving)
                Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
                if (!fieldMap.containsKey('CreatedDate')) {
                    res.analysisMessage = '⚠️ This object doesn\'t support age-based archiving.\n\n' +
                                         'The object must have a CreatedDate field for archiving.';
                    res.hasOpportunities = false;
                    responses.add(res);
                    continue;
                }
                
                // Get total count
                String countQuery = 'SELECT COUNT() FROM ' + req.objectName;
                res.totalRecords = Database.countQuery(countQuery);
                
                if (res.totalRecords == 0) {
                    res.analysisMessage = '📭 No records found in ' + res.objectLabel + '.\n\n' +
                                         'This object is empty, so there\'s nothing to archive.';
                    res.hasOpportunities = false;
                    responses.add(res);
                    continue;
                }
                
                // Analyze the object
                ObjectAnalysis analysis = analyzeRecords(req.objectName, objDescribe, fieldMap);
                
                // Build response
                res.archivableRecords = analysis.archivableCount;
                res.hasOpportunities = (analysis.archivableCount > 0);
                res.recommendedConditions = analysis.topRecommendation;
                res.objectApiName = req.objectName;
                res.suggestedRetentionDays = 365; // Default 1 year; agent can override
                res.analysisMessage = buildAnalysisMessage(res.objectLabel, req.objectName, analysis, 
                                                          res.totalRecords, 
                                                          req.includeRecommendations != false);
                
            } catch (Exception e) {
                res.analysisMessage = '❌ Error analysing ' + req.objectName + ': ' + e.getMessage();
                res.hasOpportunities = false;
                System.debug(LoggingLevel.ERROR, 'Analysis Error: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
    
    // Analyze records for archival opportunities
    private static ObjectAnalysis analyzeRecords(String objectName, Schema.DescribeSObjectResult objDescribe, 
                                                 Map<String, Schema.SObjectField> fieldMap) {
        ObjectAnalysis analysis = new ObjectAnalysis();
        analysis.ageBreakdowns = new List<AgeBreakdown>();
        analysis.statusBreakdowns = new List<StatusBreakdown>();
        
        // Analyze by age brackets
        analyzeByAge(objectName, analysis);
        
        // Analyze by status/state fields if they exist
        analyzeByStatus(objectName, objDescribe, fieldMap, analysis);
        
        // Determine top recommendation
        analysis.topRecommendation = determineTopRecommendation(objectName, analysis, fieldMap);
        
        return analysis;
    }
    
    // Analyze records by age
    private static void analyzeByAge(String objectName, ObjectAnalysis analysis) {
        List<Integer> ageThresholds = new List<Integer>{90, 180, 365, 730, 1095}; // 3mo, 6mo, 1yr, 2yr, 3yr
        
        for (Integer days : ageThresholds) {
            try {
                String query = 'SELECT COUNT() FROM ' + objectName + 
                              ' WHERE CreatedDate < LAST_N_DAYS:' + days;
                Integer count = Database.countQuery(query);
                
                AgeBreakdown breakdown = new AgeBreakdown();
                breakdown.days = days;
                breakdown.label = formatAgePeriod(days);
                breakdown.count = count;
                analysis.ageBreakdowns.add(breakdown);
                
                // Track total archivable (using 1 year as baseline)
                if (days == 365) {
                    analysis.archivableCount = count;
                }
            } catch (Exception e) {
                // Skip if query fails
            }
        }
    }
    
    // Discover status/state-like fields on the object (no hardcoding)
    private static List<String> discoverStatusFields(Map<String, Schema.SObjectField> fieldMap) {
        List<String> picklistCandidates = new List<String>();
        List<String> booleanCandidates = new List<String>();
        
        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
            if (!dfr.isAccessible() || !dfr.isFilterable()) continue;
            
            Schema.DisplayType dt = dfr.getType();
            if (dt == Schema.DisplayType.Picklist || dt == Schema.DisplayType.MultiPicklist) {
                // Picklist fields that often indicate state (discovered by name, not hardcoded list)
                String lower = fieldName.toLowerCase();
                if (lower == 'status' || lower == 'stagename' || lower == 'state') {
                    picklistCandidates.add(fieldName);
                }
            } else if (dt == Schema.DisplayType.Boolean) {
                // Boolean completion flags; exclude system fields like IsDeleted
                String lower = fieldName.toLowerCase();
                if (lower == 'isclosed' || lower == 'iswon' || lower == 'isconverted') {
                    booleanCandidates.add(fieldName);
                }
            }
        }
        
        // Avoid redundancy: if object has Status picklist, don't also report IsClosed (same concept for Case)
        Boolean hasStatusPicklist = false;
        for (String s : picklistCandidates) {
            if (s == 'Status' || s == 'StageName') {
                hasStatusPicklist = true;
                break;
            }
        }
        if (hasStatusPicklist) {
            List<String> filtered = new List<String>();
            for (String b : booleanCandidates) {
                if (b != 'IsClosed') filtered.add(b); // Skip IsClosed when we have Status/StageName
                // IsWon/IsConverted are kept (e.g. Opportunity: StageName + IsWon both useful)
            }
            booleanCandidates = filtered;
        }
        
        List<String> result = new List<String>();
        result.addAll(picklistCandidates);
        result.addAll(booleanCandidates);
        return result;
    }
    
    // Analyze by status/state fields discovered from the object
    private static void analyzeByStatus(String objectName, Schema.DescribeSObjectResult objDescribe,
                                       Map<String, Schema.SObjectField> fieldMap, ObjectAnalysis analysis) {
        List<String> statusFields = discoverStatusFields(fieldMap);
        
        for (String fieldName : statusFields) {
            if (!fieldMap.containsKey(fieldName)) continue;
            
            Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
            Schema.DisplayType dt = dfr.getType();
            
            try {
                if (dt == Schema.DisplayType.Boolean) {
                    String query = 'SELECT COUNT() FROM ' + objectName + ' WHERE ' + fieldName + ' = true';
                    Integer count = Database.countQuery(query);
                    if (count > 0) {
                        StatusBreakdown breakdown = new StatusBreakdown();
                        breakdown.fieldName = fieldName;
                        breakdown.fieldValue = 'true';
                        breakdown.count = count;
                        analysis.statusBreakdowns.add(breakdown);
                    }
                } else if (dt == Schema.DisplayType.Picklist || dt == Schema.DisplayType.MultiPicklist) {
                    String soql = 'SELECT ' + fieldName + ', COUNT(Id) cnt FROM ' + objectName + ' GROUP BY ' + fieldName;
                    AggregateResult[] results = Database.query(soql);
                    for (AggregateResult ar : results) {
                        Object val = ar.get(fieldName);
                        if (val == null) continue;
                        StatusBreakdown breakdown = new StatusBreakdown();
                        breakdown.fieldName = fieldName;
                        breakdown.fieldValue = String.valueOf(val);
                        breakdown.count = (Integer)ar.get('cnt');
                        analysis.statusBreakdowns.add(breakdown);
                    }
                }
            } catch (Exception e) {
                // Skip if query fails (e.g. field not groupable)
            }
        }
    }
    
    // Detect if a status value represents "closed" or "completed" (for recommendations)
    private static Boolean isClosedLikeValue(String fieldName, String fieldValue) {
        if (String.isBlank(fieldValue)) return false;
        String v = fieldValue.toLowerCase();
        if (fieldName == 'IsClosed' && v == 'true') return true;
        if (fieldName == 'Status' || fieldName == 'StageName' || fieldName == 'State') {
            return v.contains('closed') || v.contains('complete') || v.contains('won') || 
                   v.contains('converted') || v.contains('cancelled') || v.contains('canceled');
        }
        if (fieldName == 'IsWon' || fieldName == 'IsConverted') return v == 'true';
        return false;
    }
    
    // Determine the top recommendation from actual breakdowns (no hardcoded field names)
    private static String determineTopRecommendation(String objectName, ObjectAnalysis analysis, 
                                                    Map<String, Schema.SObjectField> fieldMap) {
        for (StatusBreakdown sb : analysis.statusBreakdowns) {
            if (sb.count == 0) continue;
            if (isClosedLikeValue(sb.fieldName, sb.fieldValue)) {
                if (sb.fieldName.startsWith('Is') && sb.fieldValue == 'true') {
                    return sb.fieldName + ' = true';
                }
                return sb.fieldName + ' = \'' + sb.fieldValue + '\'';
            }
        }
        return null;
    }
    
    // Build the analysis message
    private static String buildAnalysisMessage(String objectLabel, String objectName, ObjectAnalysis analysis, 
                                              Integer totalRecords, Boolean includeRecommendations) {
        List<String> sections = new List<String>();
        
        // Header
        sections.add('📊 Archival Analysis: ' + objectLabel);
        sections.add('---');
        sections.add('Total Records: ' + formatNumber(totalRecords));
        sections.add('');
        
        // Age breakdowns
        if (!analysis.ageBreakdowns.isEmpty()) {
            sections.add('📅 Records by Age:');
            for (AgeBreakdown ab : analysis.ageBreakdowns) {
                Decimal percentage = totalRecords > 0 ? (ab.count * 100.0 / totalRecords) : 0;
                sections.add('  • Older than ' + ab.label + ': ' + formatNumber(ab.count) + 
                           ' (' + percentage.setScale(1) + '%)');
            }
            sections.add('');
        }
        
        // Status breakdowns
        if (!analysis.statusBreakdowns.isEmpty()) {
            sections.add('📋 Records by Status/State:');
            for (StatusBreakdown sb : analysis.statusBreakdowns) {
                Decimal percentage = totalRecords > 0 ? (sb.count * 100.0 / totalRecords) : 0;
                String label = sb.fieldName + ' = ' + sb.fieldValue;
                sections.add('  • ' + label + ': ' + formatNumber(sb.count) + 
                           ' (' + percentage.setScale(1) + '%)');
            }
            sections.add('');
        }
        
        // Archival opportunities
        if (analysis.archivableCount > 0) {
            Decimal archivePercentage = (analysis.archivableCount * 100.0 / totalRecords);
            sections.add('🎯 Archival Opportunity:');
            sections.add('  • ' + formatNumber(analysis.archivableCount) + ' records (' + 
                        archivePercentage.setScale(1) + '%) are older than 1 year');
            sections.add('');
        }
        
        // Recommendations
        if (includeRecommendations) {
            sections.add('💡 What You Can Do Next');
            sections.add('---');
            List<String> recommendations = buildRecommendations(objectName, analysis);
            for (String rec : recommendations) {
                sections.add(rec);
            }
            sections.add('  • Say **"Guide me through creating it"** for step-by-step instructions with the exact query (about 2 minutes).');
        }
        
        return String.join(sections, '\n');
    }
    
    // Build recommendations from actual analysis (closed-like status + age, or age-only)
    private static List<String> buildRecommendations(String objectName, ObjectAnalysis analysis) {
        List<String> recommendations = new List<String>();
        Boolean usedClosedLike = false;
        
        // Recommend: closed/completed-like status + older than 1 year (for each such breakdown)
        for (StatusBreakdown sb : analysis.statusBreakdowns) {
            if (!isClosedLikeValue(sb.fieldName, sb.fieldValue) || sb.count == 0) continue;
            usedClosedLike = true;
            String condition = (sb.fieldName.startsWith('Is') && sb.fieldValue == 'true') 
                ? (sb.fieldName + ' = true') 
                : (sb.fieldName + ' = \'' + sb.fieldValue + '\'');
            String stateLabel = sb.fieldName == 'IsWon' ? 'won' : (sb.fieldName == 'IsConverted' ? 'converted' : 'closed/completed');
            recommendations.add('  • Archive ' + stateLabel + ' records older than 1 year');
            recommendations.add('    Conditions: CreatedDate < LAST_N_DAYS:365 AND ' + condition);
            recommendations.add('    Potential: ~' + formatNumber(sb.count) + ' records (' + formatStorageEstimate(sb.count) + ') if they meet age criteria');
            recommendations.add('');
        }
        
        // If no status-based recommendation, suggest age-only if there are old records
        if (!usedClosedLike && analysis.archivableCount > 0) {
            recommendations.add('  • Archive old records (age-based only)');
            recommendations.add('    Conditions: CreatedDate < LAST_N_DAYS:365');
            recommendations.add('    Potential: ' + formatNumber(analysis.archivableCount) + ' records (' + formatStorageEstimate(analysis.archivableCount) + ')');
            recommendations.add('');
        }
        
        if (recommendations.isEmpty()) {
            recommendations.add('  • No specific recommendations — object has no clear closed/completed state, or no old records.');
        }
        
        return recommendations;
    }
    
    // Helper: Format age period
    private static String formatAgePeriod(Integer days) {
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
        }
        return days + ' days';
    }
    
    // Estimate storage: ~2 KB per record; display as MB or GB
    private static String formatStorageEstimate(Integer recordCount) {
        if (recordCount == null || recordCount <= 0) return '~0 MB';
        Decimal sizeMB = Decimal.valueOf(recordCount * 2) / 1024; // 2 KB per record
        if (sizeMB >= 1024) {
            Decimal sizeGB = sizeMB / 1024;
            return '~' + sizeGB.setScale(2) + ' GB';
        }
        return '~' + sizeMB.setScale(2) + ' MB';
    }
    
    // Helper: Format numbers with commas
    private static String formatNumber(Integer num) {
        if (num == null) return '0';
        String numStr = String.valueOf(num);
        String result = '';
        Integer count = 0;
        for (Integer i = numStr.length() - 1; i >= 0; i--) {
            if (count == 3) {
                result = ',' + result;
                count = 0;
            }
            result = numStr.substring(i, i + 1) + result;
            count++;
        }
        return result;
    }
    
    // Inner classes for data structures
    private class ObjectAnalysis {
        public List<AgeBreakdown> ageBreakdowns;
        public List<StatusBreakdown> statusBreakdowns;
        public Integer archivableCount = 0;
        public String topRecommendation;
    }
    
    private class AgeBreakdown {
        public Integer days;
        public String label;
        public Integer count;
    }
    
    private class StatusBreakdown {
        public String fieldName;
        public String fieldValue;
        public Integer count;
    }
}
