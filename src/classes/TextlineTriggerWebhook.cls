global class TextlineTriggerWebhook {
        public static boolean forceAWebhook = false;

        @future(callout=true)
        public static void makeCallout(String data) {
            if (forceAWebhook || !Test.isRunningTest()) {
                try {
                    HttpRequest req = generateRequest(data);
                    new Http().send(req);
                    forceAWebhook = false;
                } catch(System.CalloutException e) {
                    // TODO handle exception
                }
            }
        }


        public static HTTPRequest generateRequest(String data) {
            HttpRequest req = new HttpRequest();

            req.setEndpoint('https://application.textline.com/salesforce/webhook_callback.json');
            req.setMethod('POST');
            req.setBody(data);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('X-INTEGRATION', '5827ccfb-645e-4324-b466-f728ab8990d2');

            return req;
         }


         public static String calloutPayload(List<sObject> old, List<sObject> current, boolean isInsert, boolean isUpdate, boolean isDelete, boolean isUndelete) {
            String content;

            if (isDelete) {
                content  = '{"data": ' + JSON.serialize(old);
            } else {
                content  = '{"data": ' + JSON.serialize(current);
            }

            String event;
            if (isInsert) {
                event = 'insert';
            } else if (isUpdate) {
                event = 'update';
            } else if (isDelete) {
                event = 'delete';
            } else if (isUndelete) {
                event = 'undelete';
            }

            content += ', "event": "' + event;
            content += '"}';

            return content;
         }
      }