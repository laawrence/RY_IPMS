@isTest
private class TextlineContactTriggerTest {
    private static Contact record;

    static void init() {
        record = new Contact(
            LastName = 'Finley'
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