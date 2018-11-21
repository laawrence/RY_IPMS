/**
* File Name: Talkdesk_ActivityTriggerTest.apxc
* Description: Scheduled Apex Job that updates Talkdesk activities with Contact and Account based on the Contact's phone number.
* Copyright : Talkdesk, Inc. Copyright (c) 2018
* Author : Phillip Zeelig
* Date: 07/01/018
**/
@isTest
private class Talkdesk_ActivityTriggerTest {
     
    static testmethod void ActivityTriggerTest() {
        List<Contact> contacts = new List<Contact>();
        List<Lead> Leads = new List<Lead>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Account> accounts = new List<Account>();

        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Consumer Profile').getRecordTypeId();
        	
        Account a = new Account();
        a.name = 'Test Account';
        a.Type = 'Sales';
        a.Website = 'www.example.com';
        a.industry = 'other';
        a.NumberOfEmployees = 10;
        a.Talkdesk_Number_of_Attempts__c=Null;
        insert(a);
        System.debug('Account ----'+ a);
        
        Account a2 = new Account();
        a2.name = 'Test Account2';
        a2.Type = 'Sales';
        a2.Website = 'www.example.com';
        a2.industry = 'other';
        a2.NumberOfEmployees = 10;
        a2.Talkdesk_Number_of_Attempts__c=0;
        insert(a2);
        System.debug('Account ----'+ a2);
        
        for(Integer c = 0; c < 10; c++){
            Contact contact = new contact();
            contact.AccountId = a.id;
            contact.FirstName ='Andrei' + c;
            contact.LastName ='Kropotoff';
            contact.Phone = '555-555-555'+c;
            contact.HomePhone ='555-555-555'+c;
            contact.MobilePhone = '555-555-555'+c;
            contact.OtherPhone = '555-555-555'+c;
            contacts.add(contact);
             
            Lead l = new Lead();
            l.LastName ='Talkdesk Tester '+c;
            l.Phone ='555-555-553'+c;
            l.MobilePhone ='555-555-553'+c;
            l.company = 'Test Co.';
            Leads.add(l);
            
            Opportunity o = new Opportunity();
            o.Name='Test'+c;
            o.RecordTypeId=devRecordTypeId;
            o.CloseDate=System.today();
            o.StageName='Consideration';
            opportunities.add(o);
            system.debug('loop');
        }

        insert contacts;
        insert Leads;
        insert opportunities;
        System.debug('Contacts ----'+ contacts);
        System.debug('Leads ----'+ Leads);
        System.debug('Opportunities ----'+ opportunities);
        
        leads[1].Talkdesk_NumberofAttempts__c=NULL;
        update(leads[1]);
        
    	Test.startTest();
            System.debug('Start Test ----');
            List<talkdesk__talkdesk_activity__c> activities = new List<talkdesk__talkdesk_activity__c>();
            for(Integer i = 0; i< 2; i++){
                activities.add(new talkdesk__talkdesk_activity__c(talkdesk__Contact_Phone__c = '555-555-554'+i, name = 'aTest J ' + i, talkdesk__Talkdesk_Id__c ='Test A ' + i, talkdesk__Contact__c=NULL, talkdesk__Account__c=a.ID, talkdesk__End_Time__c=System.now()));
                activities.add(new talkdesk__talkdesk_activity__c(talkdesk__Contact_Phone__c = '555-555-554'+i, name = 'Test J ' + i, talkdesk__Talkdesk_Id__c ='Test B ' + i, talkdesk__Contact__c=NULL, talkdesk__Account__c=a2.ID, talkdesk__End_Time__c=System.now()));

                activities.add(new talkdesk__talkdesk_activity__c(talkdesk__Contact_Phone__c = '555-555-554'+i, name = 'bTest J ' + i, talkdesk__Talkdesk_Id__c ='Test J ' + i, talkdesk__Contact__c=contacts[i].id, talkdesk__Account__c=NULL, talkdesk__End_Time__c=System.now()));
                activities.add(new talkdesk__talkdesk_activity__c(talkdesk__Contact_Phone__c = '555-555-553'+i, name = 'cTest K ' + i, talkdesk__Talkdesk_Id__c ='Test K ' + i, talkdesk__Lead__c=Leads[i].id, talkdesk__Account__c=NULL, talkdesk__End_Time__c=System.now())); 
                activities.add(new talkdesk__talkdesk_activity__c(talkdesk__Contact_Phone__c = '555-555-555'+i, name = 'dTest L ' + i, talkdesk__Talkdesk_Id__c ='Test L ' + i, talkdesk__Opportunity__c=opportunities[i].id, talkdesk__Account__c=NULL, talkdesk__End_Time__c=System.now())); 
            
            }
            insert activities;
            System.debug('ACTIVITIES ----'+ activities);
            Test.stopTest();
	}
}