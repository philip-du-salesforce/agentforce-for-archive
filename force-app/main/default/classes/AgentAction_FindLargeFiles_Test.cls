@isTest
public class AgentAction_FindLargeFiles_Test {
    
    @isTest
    static void testFindTopFiles() {
        // 1. Setup
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Massive Report';
        cv.PathOnClient = 'Report.pdf';
        cv.VersionData = Blob.valueOf('Test Content Data'); 
        cv.IsMajorVersion = true;
        insert cv;
        
        // 2. Execute
        AgentAction_FindLargeFiles.Request req = new AgentAction_FindLargeFiles.Request();
        req.numberOfFiles = 5; 
        List<AgentAction_FindLargeFiles.Request> reqList = new List<AgentAction_FindLargeFiles.Request>{req};

        Test.startTest();
        List<AgentAction_FindLargeFiles.Response> results = AgentAction_FindLargeFiles.findLargeFiles(reqList);
        Test.stopTest();

        // 3. Verify
        System.assertEquals(1, results.size());
        
        // Verify output exists and is correct
        String output = results[0].fileDetails;
        System.assertNotEquals(null, output, 'Should return a file list string');
        System.assert(output.contains('Massive Report'), 'Output should contain the filename');
        
        // Ensure NO links are present
        System.assert(!output.contains('http'), 'Output should NOT contain links');
    }
}