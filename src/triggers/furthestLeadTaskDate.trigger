trigger furthestLeadTaskDate on Task (after insert, after update) {
 
Task task = Trigger.new[0];
Lead lead = new Lead();
 
for(Lead l:[Select Id, Last_Activity_Date__c, Furthest_Task_Date__c from Lead where
Id = :task.whoId limit 1]){
lead = l;
 
if(task.ActivityDate > lead.Furthest_Task_Date__c|| lead.Furthest_Task_Date__c == null)
lead.Furthest_Task_Date__c= task.ActivityDate;
 
update lead;
}
}