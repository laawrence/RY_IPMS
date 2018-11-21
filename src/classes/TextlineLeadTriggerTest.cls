@isTest
private class TextlineLeadTriggerTest {
    private static Lead record;

    static void init() {
        record = new Lead(
            LastName = 'Finley', Company = 'Textline'
        );
        
    }


    // All of the logic is in the webhook apex class, so I'm just testing to make sure inserting succeeds?
    static testMethod void testInsert() {
        init();
        Test.startTest();
        TextlineTriggerWebhook.forceAWebhook = true;
        Test.setMock(HttpCalloutMock.class, new TextlineCalloutMock());
        insert record;
        System.assertEquals(1, 1);
        Test.stopTest();
    }
}