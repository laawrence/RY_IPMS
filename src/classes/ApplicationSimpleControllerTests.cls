@isTest
global class ApplicationSimpleControllerTests {

    /**
     * @desc This static @testSetup method will setup the unit test data for this
     * entire class. Remember that Unit Tests see none of the existing data in the org.
     */  
     @testSetup static void setup() {

        
        List<Application__c> existingApps = new List<Application__c>();
        existingApps.add(new Application__c(Email__c='existing@test.com',
                                            Sales_Path__c='Consumer Applicant',
                                            First_Name__c='FirstName',
                                            Last_Name__c='LastName',
                                            Why_Remote_Year__c='WhyRemoteYear',
                                            Why_You__c = 'WhyYou',
                                            Personal_and_Professional_Goals__c = 'Goals',
                                            Remote_Work_Details__c = 'Details',
                                            Flexible__c = 'Yes',
                                            Current_Job__c = 'Job',
                                            Primary_Country_of_Citizenship__c = 'United States',
                                            Current_Country__c = 'United States',
                                            Annual_Income__c = 50000,
                                             Application_Status__c = Label.App2_Set_ApplicationStatus));
        existingApps.add(new Application__c(Email__c='paid@test.com',
                                            Sales_Path__c='Consumer Applicant',
                                            First_Name__c='FirstName',
                                            Last_Name__c='LastName',
                                            Why_Remote_Year__c='WhyRemoteYear',
                                            Why_You__c = 'WhyYou',
                                            Personal_and_Professional_Goals__c = 'Goals',
                                            Remote_Work_Details__c = 'Details',
                                            Flexible__c = 'Yes',
                                            Current_Job__c = 'Job',
                                            Primary_Country_of_Citizenship__c = 'United States',
                                            Current_Country__c = 'United States',
                                            Annual_Income__c = 50000,
                                             Application_Status__c = Label.App2_Set_ApplicationStatus,
                                            Payment_Details__c = 'Paid by Test'));        
        insert existingApps;
    }

  static testmethod void testNewApplication() { 
        
    Profile p = [SELECT Id FROM Profile WHERE Name='Remote Year Site Profile'];
    user u = new User(Alias = 'rysite',
                          Email='RemoteYearSiteGuest@test.com',
                          EmailEncodingKey='UTF-8',
                          LastName='RYGuest',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='RemoteYearSiteGuest@test.com');
        
        ApplicationSimpleController ctlr;
        System.runAs(u){ //Site Guest
          Test.startTest();  
            
          ctlr = new ApplicationSimpleController();
            
            //Enter new email addess (doesn't already exist)
            ctlr.app.Email__c = 'newapp@test.com';
            ctlr.verifyEmail(); //User clicked Lookup My Email button
            System.assertEquals(false, ctlr.appFound);
            System.assertEquals(true, ctlr.emailChecked);
            System.assertEquals(Label.App2_Message_AppNotFound, ctlr.emailMessage);
            
          Test.stopTest();
        }
    }   

    
  static testmethod void testExistingApplication() { 
        
    Profile p = [SELECT Id FROM Profile WHERE Name='Remote Year Site Profile'];
    user u = new User(Alias = 'rysite',
                          Email='RemoteYearSiteGuest@test.com',
                          EmailEncodingKey='UTF-8',
                          LastName='RYGuest',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='RemoteYearSiteGuest@test.com');
        
        ApplicationSimpleController ctlr;
        System.runAs(u){ //Site Guest
          Test.startTest();  
            
          ctlr = new ApplicationSimpleController();
            
            //Enter existing email addess 
            ctlr.app.Email__c = 'existing@test.com';
            ctlr.verifyEmail(); //User clicked Lookup My Email button
            System.assertEquals(true, ctlr.appFound);
            System.assertEquals(true, ctlr.emailChecked);
            System.assertEquals(Label.App2_Message_AppFound, ctlr.emailMessage);
            
            //User fills in form fields
            ctlr.app.First_Name__c='FirstName';
            ctlr.app.Last_Name__c='LastName';
            ctlr.app.Why_Remote_Year__c='WhyRemoteYear';
            ctlr.app.Why_You__c = 'WhyYou';
            ctlr.app.Personal_and_Professional_Goals__c = 'Goals';
            ctlr.app.Remote_Work_Details__c = 'Details';
            ctlr.app.Flexible__c = 'Yes';
            ctlr.app.Current_Job__c = 'Job';
            ctlr.app.Primary_Country_of_Citizenship__c = 'United States';
            ctlr.app.Current_Country__c = 'United States';
            ctlr.app.Annual_Income__c = 50000;
    
            //Page will automatically submit on successful payment
            ctlr.submitApplication();
            
          Test.stopTest();
        }
    }    
}