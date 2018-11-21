/*
Trigger on Task to update the isConnected field on a Lead
Author: Lawrence Humblet
Date: 2018-11-09
*/

trigger isConnectedTextTrigger on Task (after insert) {

    //Initiate array of inserted tasks that started the trigger
    Task [] tlist = trigger.new;

    //Set hold lead IDs information
    set< id > lid = new set< id > ();

    //Only selecting tasks that are textline texts
    for(Task ts : tlist)
    {
        if(ts.subject == 'Inbound Textline Text') {
            lid.add(ts.Whoid);
        }
    }

    //Mapping tasks to leads
    Map <id, Task> tmap = new Map <id, Task>([select id, Whoid from Task where subject = 'Inbound Textline Text' and Whoid in:lid]);
    Map <id, Lead> lmap = new Map <id, Lead>([select id, isConnectedText__c from lead where id in:lid ]);

    //Updating no of textline texts field
    for(lead l : lmap.values())
    {
        for(Task tt : tmap.values())
        {
           if(tt.WhoId == l.Id)
            l.isConnectedText__c = TRUE;
        }
    }

    update lmap.values();

}