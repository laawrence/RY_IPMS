trigger PreviousOwner on Application__c (before update) { 
 
set<id> uid = new Set<ID>(); 


String sid;
 
for(Application__c newRecord : trigger.new){ 

System.debug('****** trigger.new ******:'+trigger.new);
 
if(newRecord.OwnerId != trigger.oldMap.get(newRecord.Id).Ownerid)

{ 
 
System.debug('****** trigger.oldMap.get(newRecord.Id).Ownerid ******:'+trigger.oldMap.get(newRecord.Id).Ownerid);

uid.add(trigger.oldMap.get(newRecord.Id).Ownerid); 

 sid = trigger.oldMap.get(newRecord.Id).Ownerid;
} 
  if(sid.startsWith('00G'))
  {
  return;
  }
  
} 
 
 System.debug('****** uid*******:'+uid); 
 
 

 
 
map<Id, user> userId= new Map<id,User>([select id, name from User where id=:uid ]); 


 
//System.debug('******userId******:'+userId); 
 
for (Application__c newRecord : trigger.new) 
 
{ 
System.debug('******* new Record *******:'+newRecord);
 
if (newRecord.OwnerId != trigger.oldMap.get(newRecord.Id).Ownerid) { 
 
System.debug('Hello If'); 

System.debug('******newRecord.OwnerId*****:'+newRecord.OwnerId); 

System.debug('******trigger.oldMap.get(newRecord.Id).Ownerid******:'+trigger.oldMap.get(newRecord.Id).Ownerid); 
  
System.debug('*******new Record Previous owner*********: '+newRecord.Previous_Owner__c); 

System.debug('******userId.get(trigger.oldMap.get(newRecord.Id).Ownerid).Name*****:'+userId.get(trigger.oldMap.get(newRecord.Id).Ownerid).Name);

newRecord.Previous_Owner__c =userId.get(trigger.oldMap.get(newRecord.Id).Ownerid).Name ; 
 
} 
 
} 
 
}