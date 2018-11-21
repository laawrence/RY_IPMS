trigger TextlineContactTrigger on Contact (after insert, after update, after delete, after undelete) {
    String content = TextlineTriggerWebhook.calloutPayload(Trigger.old, Trigger.new, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
    TextlineTriggerWebhook.makeCallout(content);
}