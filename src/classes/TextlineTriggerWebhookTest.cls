@isTest
private class TextlineTriggerWebhookTest {
    private static List<Contact> contactsList;

    static void init() {
        contactsList = new List<Contact>();
        contactsList.add(new Contact(
            Email = 'salesforce@textline.com',
            LastName = 'Finley'
        ));
    }


    static testMethod void testGenerateRequest() {
        HttpRequest req = TextlineTriggerWebhook.generateRequest('{"data": []}');

        System.assertEquals(req.getEndpoint(), 'https://application.textline.com/salesforce/webhook_callback.json');
        System.assertEquals(req.getMethod(), 'POST');
        System.assertEquals(req.getHeader('Content-Type'), 'application/json');
        System.assertEquals(req.getHeader('X-INTEGRATION'), '5827ccfb-645e-4324-b466-f728ab8990d2');
    }


    static testMethod void testNewContact() {
        init();
        performPayloadTest(null, contactsList, true, false, false, false, 'insert');
    }


    static testMethod void testUpdateContact() {
        init();
        performPayloadTest(contactsList, contactsList, false, true, false, false, 'update');
    }



    static testMethod void testDeleteContact() {
        init();
        performPayloadTest(contactsList, null, false, false, true, false, 'delete');
    }


    static testMethod void testUndeleteContact() {
        init();
        performPayloadTest(null, contactsList, false, false, false, true, 'undelete');
    }


    private static void performPayloadTest(List<sObject> old, List<sObject> current, boolean isInsert, boolean isUpdate, boolean isDelete, boolean isUndelete, String event) {
        Test.startTest();

        String payload = TextlineTriggerWebhook.calloutPayload(old, current,
                                                        isInsert, isUpdate,
                                                        isDelete, isUndelete);
        Map<String, Object> payloadObject = (Map<String, Object>)JSON.deserializeUntyped(payload);
        System.assertEquals(event, payloadObject.get('event'));

        System.assertEquals(JSON.deserializeUntyped(JSON.serialize(contactsList)),
                            payloadObject.get('data'));

        Test.stopTest();
    }

}