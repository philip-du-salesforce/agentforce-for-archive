public with sharing class AgentAction_TopStorageConsumers {

    private static final String REST_API_VERSION = 'v59.0';

    public class Request {
        @InvocableVariable(label='Number to Show' description='How many top objects to list? Default is 5.')
        public Integer numberToShow;
    }

    public class Response {
        @InvocableVariable(label='Analysis Result' description='Ranked list of objects, counts, and estimated storage size')
        public String analysisResult;
    }

    public class StorageItem implements Comparable {
        public String name;
        public Integer recordCount;
        public Decimal sizeMB;
        /** When true, record count is at least 50,000 (SOQL COUNT() caps at 50,000). */
        public Boolean countIsAtLeast;

        public StorageItem(String n, Integer c) {
            this(n, c, false);
        }

        public StorageItem(String n, Integer c, Boolean atLeast) {
            this.name = n;
            this.recordCount = c;
            this.countIsAtLeast = (atLeast != null && atLeast);
            // (Count * 2KB) / 1024 = MB
            this.sizeMB = (Decimal.valueOf(c) * 2) / 1024;
        }

        public Integer compareTo(Object compareTo) {
            StorageItem other = (StorageItem)compareTo;
            if (this.sizeMB > other.sizeMB) return -1;
            if (this.sizeMB < other.sizeMB) return 1;
            return 0;
        }
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

    /**
     * Call REST Record Count API to get true (cached) record counts per object.
     * Returns null if callout fails (e.g. no session, timeout). Counts can exceed 50,000.
     * See RECORD_COUNT_AND_STORAGE_OPTIONS.md.
     */
    private static Map<String, Integer> getRecordCountsFromRestApi(List<String> objectNames) {
        String sessionId = UserInfo.getSessionId();
        if (String.isBlank(sessionId)) {
            return null;
        }
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String endpoint = baseUrl + '/services/data/' + REST_API_VERSION + '/limits/recordCount';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new Map<String, Object>{ 'sObjects' => objectNames }));
        req.setTimeout(120000);
        try {
            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() != 200) {
                return null;
            }
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Object sobjectsObj = body.get('sObjects');
            if (sobjectsObj == null) {
                return null;
            }
            List<Object> sobjects = (List<Object>) sobjectsObj;
            Map<String, Integer> counts = new Map<String, Integer>();
            for (Object o : sobjects) {
                Map<String, Object> item = (Map<String, Object>) o;
                String name = (String) item.get('name');
                Object countObj = item.get('count');
                if (name != null && countObj != null) {
                    Integer count = countObj instanceof Integer ? (Integer) countObj : Integer.valueOf(String.valueOf(countObj));
                    counts.put(name, count);
                }
            }
            return counts;
        } catch (Exception e) {
            System.debug('Record Count REST API failed: ' + e.getMessage());
            return null;
        }
    }

    @InvocableMethod(label='Identify Top Storage Consumers' description='Analyzes standard objects to rank them by record count and storage consumption.')
    public static List<Response> identifyTopConsumers(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        List<String> objectsToCheck = new List<String>{'Account', 'Contact', 'Lead', 'Opportunity', 'Case', 'Task'};

        for (Request req : requests) {
            Integer limitCount = (req.numberToShow == null || req.numberToShow < 1) ? 5 : req.numberToShow;
            List<StorageItem> items = new List<StorageItem>();

            // Prefer REST Record Count API for true counts (no 50k cap); fall back to SOQL
            Map<String, Integer> restCounts = getRecordCountsFromRestApi(objectsToCheck);
            if (restCounts != null && !restCounts.isEmpty()) {
                for (String objName : objectsToCheck) {
                    Integer count = restCounts.get(objName);
                    if (count != null && count > 0) {
                        items.add(new StorageItem(objName, count, false));
                    }
                }
            } else {
                for (String objName : objectsToCheck) {
                    try {
                        String countQuery = 'SELECT COUNT() FROM ' + objName;
                        Integer count = Database.countQuery(countQuery);
                        if (count > 0) {
                            Boolean atLeast = false;
                            if (count == 50000) {
                                try {
                                    List<SObject> extra = Database.query('SELECT Id FROM ' + objName + ' OFFSET 50000 LIMIT 1');
                                    if (!extra.isEmpty()) {
                                        atLeast = true;
                                    }
                                } catch (Exception ex) {
                                    System.debug('Could not check beyond 50k for ' + objName);
                                }
                            }
                            items.add(new StorageItem(objName, count, atLeast));
                        }
                    } catch(Exception e) {
                        System.debug('Could not query ' + objName);
                    }
                }
            }

            items.sort();

            Response res = new Response();
            if(items.isEmpty()) {
                res.analysisResult = '📊 Top Storage Consumers\n---\n\nNo records found in standard objects.';
            } else {
                List<String> lines = new List<String>();
                lines.add('📊 Top Storage Consumers');
                lines.add('---');
                lines.add('');
                Integer rank = 1;
                for(StorageItem item : items) {
                    if(rank > limitCount) break;
                    String countStr = (item.countIsAtLeast == true)
                        ? formatNumber(item.recordCount) + '+'
                        : formatNumber(item.recordCount);
                    String sizeStr = (item.countIsAtLeast == true)
                        ? item.sizeMB.setScale(2) + '+ MB'
                        : item.sizeMB.setScale(2) + ' MB';
                    String line = rank + '. ' + item.name + ': ' + countStr + ' records (' + sizeStr + ')';
                    lines.add(line);
                    rank++;
                }
                lines.add('');
                lines.add('💡 What You Can Do Next');
                lines.add('---');
                lines.add('  • "Analyse cases" or "Analyse [Object]" (archival breakdown)');
                lines.add('  • "Guide me through creating it" (step-by-step in Archive app)');
                lines.add('  • "Find large files"');
                
                res.analysisResult = String.join(lines, '\n');
            }
            responses.add(res);
        }
        return responses;
    }
}