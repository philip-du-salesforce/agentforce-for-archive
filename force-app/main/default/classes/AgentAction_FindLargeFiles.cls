public with sharing class AgentAction_FindLargeFiles {

    public class Request {
        @InvocableVariable(label='Number of Files' description='How many top files to show? Default is 10 if not specified.')
        public Integer numberOfFiles;
    }

    public class Response {
        @InvocableVariable(label='File Details' description='Formatted list of the largest files found')
        public String fileDetails;
    }

    @InvocableMethod(label='Find Top Large Files' description='Finds the top X largest files in the org to identify storage consumers.')
    public static List<Response> findLargeFiles(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            // Default to 10 if the user doesn't specify a number
            Integer limitCount = (req.numberOfFiles == null || req.numberOfFiles < 1) ? 10 : req.numberOfFiles;
            
            // Cap at 50 to prevent overflow
            if(limitCount > 50) { limitCount = 50; }

            // Query specifically for the TOP largest files
            List<ContentDocument> largeDocs = [SELECT Title, ContentSize, FileExtension 
                                               FROM ContentDocument 
                                               ORDER BY ContentSize DESC 
                                               LIMIT :limitCount];
            
            Response res = new Response();
            
            if (largeDocs.isEmpty()) {
                res.fileDetails = '📁 Large Files\n---\n\nNo files found in the system.';
            } else {
                List<String> fileInfo = new List<String>();
                fileInfo.add('📁 Large Files');
                fileInfo.add('---');
                fileInfo.add('');
                Integer rank = 1;
                Decimal totalSizeMB = 0;
                for(ContentDocument doc : largeDocs) {
                    Decimal sizeMB = Decimal.valueOf(doc.ContentSize) / 1024 / 1024;
                    totalSizeMB += sizeMB;
                    String fileExt = String.isNotBlank(doc.FileExtension) ? '.' + doc.FileExtension : '';
                    fileInfo.add(rank + '. ' + doc.Title + fileExt + ' (' + sizeMB.setScale(2) + ' MB)');
                    rank++;
                }
                fileInfo.add('');
                fileInfo.add('  Total size: ' + totalSizeMB.setScale(2) + ' MB');
                fileInfo.add('');
                fileInfo.add('💡 What You Can Do Next');
                fileInfo.add('---');
                fileInfo.add('  • "What\'s using the most storage?"');
                fileInfo.add('  • "Guide me through creating it"');
                
                res.fileDetails = String.join(fileInfo, '\n');
            }
            responses.add(res);
        }
        return responses;
    }
}