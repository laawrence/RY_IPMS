trigger ApplicationTrigger on Application__c (before Insert) {

    if (trigger.isbefore && trigger.isInsert) {
        applicationTriggerHandler.reparentApplications(trigger.new); 
    }
}