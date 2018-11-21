trigger TextlineLeadTrigger on Lead (after insert, after update, after delete, after undelete) {

   if (!System.isBatch() && !System.isFuture()) {
String content = TextlineTriggerWebhook.calloutPayload(Trigger.old, Trigger.new, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
    TextlineTriggerWebhook.makeCallout(content);
}
}