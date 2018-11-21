@isTest
global class ApplicationTriggerHandlerTests {

    static testmethod void testNewApplication() {     
        
        List<Account> accts = Setup_Test_Data.createAccounts();
        
        Lead lead = new Lead(Email = 'testymctestface@test.com', LastName = 'Test', Company = 'Test', Current_company__c = 'Test');
        insert lead;
        List<Application__c> apps = [SELECT Id, Email__c, Lead__c FROM Application__c];
        System.debug('yolo apps should be 1 and is');
        System.debug(apps.size());
        //system.assert(apps.size() == 1 );
    }
    
    static testmethod void testLeadDeletion() {     
        
        List<Account> accts = Setup_Test_Data.createAccounts();
        
        Lead lead1 = new Lead(Email = 'testymctestface@test.com', LastName = 'Test', Company = 'Test', Current_company__c = 'Test');
        insert lead1;
              
        Lead lead2 = new Lead(Email = 'testymctestface@test.com', LastName = 'Test1', Company = 'Test1', Current_company__c = 'Test');
        insert lead2;
        
        List<Application__c> apps = [SELECT Id, Email__c, Lead__c FROM Application__c];
        System.debug('yolo apps should be 2 and is');
        System.debug(apps.size());       
        //system.assert(apps.size() == 2);
        
        List<Lead> leads = [SELECT Id FROM Lead];
        
        System.debug('yolo leads should be 1 and is');
        System.debug(leads.size());
        //system.assert(leads.size() == 1 );
    }    
}