@isTest

public class TestTaskTriggers {

    static testMethod void furthestAppTaskDate(){
    
    Application__c App = new Application__c (Furthest_Task_Date__c = null);
    insert app;
    Task task = new Task (whatId = app.Id, activityDate = system.today());
    
    //perform test
    Test.startTest();
    insert task;
    Test.stopTest();
    

    }
    
    
    static testMethod void furthestLeadTaskDate(){
    
    Lead Lead = new Lead (Furthest_Task_Date__c = null, Company='test company', LastName = 'test Last Name', Current_Company__c='Test Company');
    insert lead;
    Task task = new Task (whoId = lead.Id, activityDate = system.today());
    
    //perform test
    Test.startTest();
    insert task;
    Test.stopTest();
    

    }
    }