/*
Trigger on Talkdesk Activity to update the isConnectedTD field on a Lead
Author: Lawrence Humblet
Date: 2018-11-09
*/

trigger isConnectedTDTrigger on talkdesk__Talkdesk_Activity__c (after insert, after update) {
    //Initiate array of inserted tasks that started the trigger
    talkdesk__Talkdesk_Activity__c [] tlist = trigger.new;

    //Set to hold lead ID information
    set< id > lid = new set< id > ();

    //Only selecting tasks that are talkdesk activities with voicemail
    for(talkdesk__Talkdesk_Activity__c ts : tlist)
    {
  		if(ts.talkdesk__Disposition_Code__c != null && ts.talkdesk__Disposition_Code__c.contains('Connected')){
  			lid.add(ts.talkdesk__Lead__c);
  		}
    }

    //Mapping tasks to leads
    Map <id, talkdesk__Talkdesk_Activity__c> tmap = new Map <id, talkdesk__Talkdesk_Activity__c>([select id, talkdesk__Lead__c from talkdesk__Talkdesk_Activity__c where talkdesk__Lead__c in:lid and talkdesk__Disposition_Code__c like '%Connected%']);
    Map <id, Lead> lmap = new Map <id, Lead>([select id,isConnectedTD__c from lead where id in:lid ]);

    //Updating no of textline texts field
    for(lead l : lmap.values())
    {
        for(talkdesk__Talkdesk_Activity__c tt : tmap.values())
        {
           if(tt.talkdesk__Lead__c == l.Id)
            l.isConnectedTD__c = TRUE;
        }
    }

	update lmap.values();


}