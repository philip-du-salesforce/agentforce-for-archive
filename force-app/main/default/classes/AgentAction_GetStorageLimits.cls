public with sharing class AgentAction_GetStorageLimits {

    public class Request {
        @InvocableVariable(label='Limit Type' description='Optional: Specify "Data" or "File". If empty or generic, returns both.' required=false)
        public String limitType;
        
        @InvocableVariable(label='Include Recommendations' description='Include smart suggestions for next actions. Default: true')
        public Boolean includeRecommendations;
    }

    public class Response {
        @InvocableVariable(label='Usage Message' description='Natural language summary with visualizations')
        public String usageMessage;
        
        @InvocableVariable(label='Data Usage Percent' description='Data storage usage percentage')
        public Decimal dataUsagePercent;
        
        @InvocableVariable(label='File Usage Percent' description='File storage usage percentage')
        public Decimal fileUsagePercent;
        
        @InvocableVariable(label='Storage Status' description='Overall storage health status')
        public String storageStatus;
        
        @InvocableVariable(label='Next Steps' description='Suggested next actions')
        public String nextSteps;
    }

    @InvocableMethod(label='Get Storage Limits' description='Retrieves storage usage with beautiful visualizations and smart recommendations.')
    public static List<Response> getStorageLimits(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        Map<String, System.OrgLimit> limitsMap = System.OrgLimits.getMap();
        System.OrgLimit dataLimit = limitsMap.get('DataStorageMB');
        System.OrgLimit fileLimit = limitsMap.get('FileStorageMB');

        for (Request req : requests) {
            Response res = new Response();
            
            // Default to including recommendations
            Boolean showRecommendations = (req.includeRecommendations != null) ? 
                req.includeRecommendations : true;

            // Determine what the user specifically asked for
            Boolean wantsData = (req.limitType != null && req.limitType.containsIgnoreCase('Data'));
            Boolean wantsFile = (req.limitType != null && req.limitType.containsIgnoreCase('File'));
            Boolean showAll = (!wantsData && !wantsFile);

            // Build the beautiful output
            String output = buildBeautifulOutput(dataLimit, fileLimit, showAll, wantsData, wantsFile);
            res.usageMessage = output;
            
            // Calculate percentages
            res.dataUsagePercent = calculatePercentage(dataLimit);
            res.fileUsagePercent = calculatePercentage(fileLimit);
            
            // Determine overall status
            Decimal maxUsage = Math.max(res.dataUsagePercent, res.fileUsagePercent);
            res.storageStatus = getStorageStatus(maxUsage);
            
            // Add smart recommendations
            if (showRecommendations) {
                res.nextSteps = generateRecommendations(res.dataUsagePercent, res.fileUsagePercent);
                res.usageMessage += '\n\n' + res.nextSteps;
            }
            
            responses.add(res);
        }
        return responses;
    }

    // Build beautiful formatted output with visualizations
    private static String buildBeautifulOutput(System.OrgLimit dataLimit, System.OrgLimit fileLimit, 
                                              Boolean showAll, Boolean wantsData, Boolean wantsFile) {
        List<String> sections = new List<String>();
        
        // Data Storage Section
        if (wantsData || showAll) {
            sections.add(formatStorageSection('💾 Data Storage', dataLimit));
        }
        
        // File Storage Section
        if (wantsFile || showAll) {
            if (sections.size() > 0) {
                sections.add(''); // Add spacing between sections
            }
            sections.add(formatStorageSection('📁 File Storage', fileLimit));
        }
        
        return String.join(sections, '\n');
    }
    
    // Format individual storage section with progress bar
    private static String formatStorageSection(String label, System.OrgLimit limitObj) {
        if (limitObj == null) {
            return label + '\n---\n⚠️ Information unavailable';
        }

        Decimal maxMB = Decimal.valueOf(limitObj.getLimit());
        Decimal usedMB = Decimal.valueOf(limitObj.getValue());
        Decimal availableMB = maxMB - usedMB;

        // Convert to GB
        Decimal maxGB = maxMB / 1024;
        Decimal usedGB = usedMB / 1024;
        Decimal availableGB = availableMB / 1024;

        // Calculate Percentage
        Decimal pct = calculatePercentage(limitObj);
        
        // Get status icon and color
        String statusIcon = getStatusIcon(pct);
        String statusText = getStatusText(pct);
        
        // Build progress bar
        String progressBar = buildProgressBar(pct);
        
        // Format the section
        List<String> lines = new List<String>();
        lines.add(label + ' ' + statusIcon);
        lines.add('---');
        lines.add(progressBar);
        lines.add('Used: ' + usedGB.setScale(2) + ' GB / ' + maxGB.setScale(2) + ' GB (' + pct.setScale(1) + '%)');
        lines.add('Available: ' + availableGB.setScale(2) + ' GB');
        lines.add('Status: ' + statusText);
        
        return String.join(lines, '\n');
    }
    
    // Build ASCII progress bar
    private static String buildProgressBar(Decimal percentage) {
        Integer barLength = 40; // Total characters for the bar
        Integer filled = (Integer)Math.floor(barLength * percentage / 100);
        Integer empty = barLength - filled;
        
        String filledBar = '';
        String emptyBar = '';
        
        // Build filled portion
        for (Integer i = 0; i < filled; i++) {
            filledBar += '█';
        }
        
        // Build empty portion
        for (Integer i = 0; i < empty; i++) {
            emptyBar += '░';
        }
        
        return '[' + filledBar + emptyBar + ']';
    }
    
    // Get status icon based on percentage
    private static String getStatusIcon(Decimal percentage) {
        if (percentage >= 90) return '🔴';
        if (percentage >= 75) return '🟠';
        if (percentage >= 50) return '🟡';
        return '🟢';
    }
    
    // Get status text based on percentage
    private static String getStatusText(Decimal percentage) {
        if (percentage >= 95) return '🔴 CRITICAL - Immediate action required!';
        if (percentage >= 90) return '🔴 Very High - Action needed soon';
        if (percentage >= 75) return '🟠 High - Monitor closely';
        if (percentage >= 50) return '🟡 Moderate - Keep an eye on it';
        if (percentage >= 25) return '🟢 Good - Healthy usage';
        return '🟢 Excellent - Plenty of space';
    }
    
    // Calculate percentage safely
    private static Decimal calculatePercentage(System.OrgLimit limitObj) {
        if (limitObj == null) return 0;
        
        Decimal maxValue = Decimal.valueOf(limitObj.getLimit());
        Decimal usedValue = Decimal.valueOf(limitObj.getValue());
        
        if (maxValue == 0) return 0;
        
        return (usedValue / maxValue) * 100;
    }
    
    // Get overall storage status
    private static String getStorageStatus(Decimal maxUsage) {
        if (maxUsage >= 90) return 'Critical';
        if (maxUsage >= 75) return 'High';
        if (maxUsage >= 50) return 'Moderate';
        if (maxUsage >= 25) return 'Good';
        return 'Excellent';
    }
    
    // Generate smart recommendations
    private static String generateRecommendations(Decimal dataUsage, Decimal fileUsage) {
        List<String> recommendations = new List<String>();
        
        recommendations.add('');
        recommendations.add('💡 What You Can Do Next');
        recommendations.add('---');
        
        if (dataUsage >= 90 || fileUsage >= 90) {
            recommendations.add('  • "What\'s using the most storage?"');
            if (dataUsage >= 90) recommendations.add('  • "Guide me through creating it"');
            if (fileUsage >= 90) recommendations.add('  • "Show me large files"');
        } else if (dataUsage >= 75 || fileUsage >= 75) {
            recommendations.add('  • "What\'s using the most storage?"');
            recommendations.add('  • "List my archive policies"');
        } else if (dataUsage >= 50 || fileUsage >= 50) {
            recommendations.add('  • "What\'s using the most storage?"');
            recommendations.add('  • "Guide me through creating it"');
        } else {
            recommendations.add('  • "What\'s using the most storage?"');
            recommendations.add('  • "Guide me through creating it"');
        }
        recommendations.add('  • "Find large files"');
        recommendations.add('  • "List archive policies"');
        
        return String.join(recommendations, '\n');
    }
}