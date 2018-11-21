trigger furthestAppTaskDate on Task (after insert, after update) {
 
Task task = Trigger.new[0];
Application__c App = new Application__c();
 
for(Application__c a:[Select Id, Last_Activity_Date__c, Furthest_Task_Date__c from Application__c where
Id = :task.whatId limit 1]){
app = a;
 
if(task.ActivityDate > app.Furthest_Task_Date__c || app.Furthest_Task_Date__c == null)
app.Furthest_Task_Date__c = task.ActivityDate;
 
update app;
}
}