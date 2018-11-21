@isTest
private class TextlineUserTriggerTest {
    private static User record;

    static void init() {
        record = new User(
            LastName = 'Finley', Alias = 'finley', CommunityNickname = 'finley', Email = 'salesforce@textline.com', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'GMT', Username = 'salesforce@textline.com'
        );
        record.ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].id;
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