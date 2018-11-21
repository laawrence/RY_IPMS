/**
* File Name: Talkdesk_ActivityTrigger.apxt
* Description: Trigger on TD Activity to update last activity field.
* Copyright : Talkdesk, Inc. Copyright (c) 2018
* Author : Phillip Zeelig
* Date: 07/01/018
**/
trigger Talkdesk_ActivityTrigger on talkdesk__Talkdesk_Activity__c (after insert) {
 
    List<Lead> leads = new List<Lead>();
    List<Lead> newLeads = new List<Lead>();
    List<Account> accounts = new List<Account>();
    List<Account> newAccounts = new List<Account>();
    List<id> dlist = new List<id>();
    List<id> clist = new List<id>();
    List<id> olist = new List<id>();
    List<id> alist = new List<id>();
    List<Contact> contacts = new List<Contact>();
    List<Opportunity> opportunities = new List<Opportunity>();
    Map<id,Date> activityMap = new Map<id,Date>();
    
    system.debug('Trigger Fired');
    for(talkdesk__Talkdesk_Activity__c td: Trigger.new){
        if(td.talkdesk__Contact__c != NULL){
            clist.add(td.talkdesk__Contact__c);
            activityMap.put(td.talkdesk__Contact__c,td.talkdesk__End_Time__c.date());
        }
        else if(td.Talkdesk__Lead__c != NULL){
            dlist.add(td.Talkdesk__Lead__c);
            activityMap.put(td.Talkdesk__Lead__c,td.talkdesk__End_Time__c.date());
        }
        else if(td.talkdesk__Opportunity__c!= NULL){
            olist.add(td.talkdesk__Opportunity__c);
            activityMap.put(td.talkdesk__Opportunity__c,td.talkdesk__End_Time__c.date());
        }
        else if(td.talkdesk__Account__c!= NULL){
            alist.add(td.talkdesk__Account__c);
            activityMap.put(td.talkdesk__Account__c,td.talkdesk__End_Time__c.date());
        }
    }
    if(clist.size()>0){
        contacts = [SELECT ID, Name, Talkdesk_Last_Activity_Date__c FROM Contact WHERE ID IN:clist];
        for(Contact c: contacts){
            if(activityMap.get(c.id)!=NULL){
                c.Talkdesk_Last_Activity_Date__c = activityMap.get(c.id);
            }
        }
        update(contacts);
    }
    system.debug(dlist.size());
    if(dlist.size()>0){
        leads = [SELECT ID, Name, Talkdesk_Last_Activity_Date__c, FirstConnectedCallDate__c,Talkdesk_NumberofAttempts__c FROM Lead WHERE ID IN:dlist];
        for(lead l: leads){
            if(activityMap.get(l.id)!=NULL){
                l.Talkdesk_Last_Activity_Date__c = activityMap.get(l.id);
                if(l.Talkdesk_NumberofAttempts__c != null){
                	 l.Talkdesk_NumberofAttempts__c++;
                }
                else{
                     newLeads.add(l);
                }
            }
            if(l.FirstConnectedCallDate__c==null){
                l.FirstConnectedCallDate__c=DateTime.now();
            }
        }
        update(leads);
    }
    if(olist.size()>0){
        opportunities = [SELECT ID, Name, Talkdesk_Last_Activity_Date__c FROM Opportunity WHERE ID IN:olist];
        for(opportunity o: opportunities){
            if(activityMap.get(o.id)!=NULL){
                o.Talkdesk_Last_Activity_Date__c = activityMap.get(o.id);
            }
        }
        update(opportunities);
    }
    //there was already a Last_Activity_Date field on Account which I ignored and built another one instead
    if(alist.size()>0){
        accounts = [SELECT ID, Name, Talkdesk_Last_Activity_Date__c, Talkdesk_Number_of_Attempts__c FROM Account WHERE ID IN:alist];
        for(Account a: accounts){
            if(activityMap.get(a.id)!=NULL){
                a.Talkdesk_Last_Activity_Date__c = activityMap.get(a.id);
				if(a.Talkdesk_Number_of_Attempts__c != null){
                	a.Talkdesk_Number_of_Attempts__c++; 
                }
                else{
                    newAccounts.add(a);
                }
              	//  system.debug('# attempts ' + a.Talkdesk_Number_of_Attempts__c);
            }
             if(a.Talkdesk_FirstConnectedCallDate__c==null){
                a.Talkdesk_FirstConnectedCallDate__c=DateTime.now();
            }
            system.debug('Account ---'+ a.Talkdesk_FirstConnectedCallDate__c +'  act date '+  a.Talkdesk_Last_Activity_Date__c + ' # '+  a.Talkdesk_Number_of_Attempts__c);
        }
        update(accounts);
    }
    if(newAccounts.size()>0 || newLeads.size()>0){
        List<Talkdesk__Talkdesk_Activity__c> tdActivities = new List<Talkdesk__Talkdesk_Activity__c>([SELECT ID, Talkdesk__Lead__c, Talkdesk__Account__c
                                                                                                      FROM Talkdesk__Talkdesk_Activity__c
                                                                                       				  WHERE Talkdesk__Lead__c IN:newLeads OR Talkdesk__Account__c IN:newAccounts]);
        
        if(newLeads.size()>0){
            for(Lead nl:newLeads){
                integer i=0;
                if(tdActivities.size()>0){
                    for(Talkdesk__Talkdesk_Activity__c tda: tdActivities){
                        if(tda.Talkdesk__Lead__c==nl.id)  {
                            i++;
                        }  
                    }
                }
                nl.Talkdesk_NumberofAttempts__c=i;
            }
            update(newLeads);
        }
        if(newAccounts.size()>0){
            for(Account na:newAccounts){
                integer j=0;
                if(tdActivities.size()>0){
                    for(Talkdesk__Talkdesk_Activity__c tda: tdActivities){
                        if(tda.Talkdesk__Account__c==na.id)  {
                            j++;
                        }  
                    }
                }
                na.Talkdesk_Number_of_Attempts__c=j;
            }
            update(newAccounts);
        }
    }
}