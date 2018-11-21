@isTest
global class Application2ControllerTests {

    /**
     * @desc This static @testSetup method will setup the unit test data for this
     * entire class. Remember that Unit Tests see none of the existing data in the org.
     */	
   	@testSetup static void setup() {

        List<Stripe_Config__c> stripeConfigs = new List<Stripe_Config__c>();
		stripeConfigs.add(new Stripe_Config__c(Name='live',
                                               Public_Key__c='pk_1', 
                                               Secret_Key__c='sk_1', 
                                               Charge_URL__c='https://api.stripe.com/v1/charges',
                                               Application_Part_2_Charge_Amount_Cents__c=5000));
            
		stripeConfigs.add(new Stripe_Config__c(Name='test',
                                               Public_Key__c='pk_test_1', 
                                               Secret_Key__c='sk_test_1', 
                                               Charge_URL__c='https://api.stripe.com/v1/charges',
                                               Application_Part_2_Charge_Amount_Cents__c=5000));
        insert stripeConfigs;
        
        List<Promo_Code__c> promoCodes = new List<Promo_Code__c>();
		promoCodes.add(new Promo_Code__c(Name='TEST'));
		promoCodes.add(new Promo_Code__c(Name='FREE'));
        insert promoCodes;
        
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
        
        Application2Controller ctlr;
        System.runAs(u){ //Site Guest
	        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new StripePaidHttpCalloutMock());   
            
	        ctlr = new Application2Controller();
            
            //Enter new email addess (doesn't already exist)
            ctlr.app.Email__c = 'newapp@test.com';
            ctlr.verifyEmail(); //User clicked Lookup My Email button
            System.assertEquals(false, ctlr.appFound);
            System.assertEquals(true, ctlr.emailChecked);
            System.assertEquals(Label.App2_Message_AppNotFound, ctlr.emailMessage);
            
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
            
            //User clicks Pay and gets valid cc token
            ctlr.stripeToken = 'tok_1';
            ctlr.submitPayment();
	        System.assertEquals(true, ctlr.isPaid);
    
            //Page will automatically submit on successful payment
            ctlr.submitApplication();
            
	        Test.stopTest();
        }
        
        System.assertEquals(true, ctlr.isPaid);
        System.assertEquals(true, ctlr.isSaved);
        System.assertEquals(Label.App2_Message_SubmitNewSuccess, ctlr.finalMessage);
    }   

	static testmethod void testNewApplicationPaymentFail() { 
        
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
        
        Application2Controller ctlr;
        System.runAs(u){ //Site Guest
	        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new StripeFailedHttpCalloutMock());   
            
	        ctlr = new Application2Controller();
            
            //Enter new email addess (doesn't already exist)
            ctlr.app.Email__c = 'newapp@test.com';
            ctlr.verifyEmail(); //User clicked Lookup My Email button
            System.assertEquals(false, ctlr.appFound);
            System.assertEquals(true, ctlr.emailChecked);
            System.assertEquals(Label.App2_Message_AppNotFound, ctlr.emailMessage);
            
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
            
            //User clicks Pay and gets valid cc token
            ctlr.stripeToken = 'tok_1';
            ctlr.submitPayment();
	        System.assertEquals(false, ctlr.isPaid);
            
	        Test.stopTest();
        }
        
        System.assertEquals(false, ctlr.isPaid);
        System.assertEquals(false, ctlr.isSaved);
    }   

	static testmethod void testNewApplicationNoToken() { 
        
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
        
        Application2Controller ctlr;
        System.runAs(u){ //Site Guest
	        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new StripeFailedHttpCalloutMock());   
            
	        ctlr = new Application2Controller();
            
            //Enter new email addess (doesn't already exist)
            ctlr.app.Email__c = 'newapp@test.com';
            ctlr.verifyEmail(); //User clicked Lookup My Email button
            System.assertEquals(false, ctlr.appFound);
            System.assertEquals(true, ctlr.emailChecked);
            System.assertEquals(Label.App2_Message_AppNotFound, ctlr.emailMessage);
            
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
            
            //User clicks Pay and gets valid cc token
            ctlr.submitPayment();
	        System.assertEquals(false, ctlr.isPaid);
            
	        Test.stopTest();
        }
        
        System.assertEquals(false, ctlr.isPaid);
        System.assertEquals(false, ctlr.isSaved);
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
        
        Application2Controller ctlr;
        System.runAs(u){ //Site Guest
	        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new StripePaidHttpCalloutMock());   
            
	        ctlr = new Application2Controller();
            
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
            
            //User clicks Pay and gets valid cc token
            ctlr.stripeToken = 'tok_1';
            ctlr.submitPayment();
	        System.assertEquals(true, ctlr.isPaid);
    
            //Page will automatically submit on successful payment
            ctlr.submitApplication();
            
	        Test.stopTest();
        }
        
        System.assertEquals(true, ctlr.isPaid);
        System.assertEquals(true, ctlr.isSaved);
        System.assertEquals(Label.App2_Message_SubmitExistingSuccess, ctlr.finalMessage);
    }

	static testmethod void testExistingPaidApplication() { 
        
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
        
        Application2Controller ctlr;
        System.runAs(u){ //Site Guest
	        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new StripePaidHttpCalloutMock());   
            
	        ctlr = new Application2Controller();
            
            //Enter existing email addess 
            ctlr.app.Email__c = 'paid@test.com';
            ctlr.verifyEmail(); //User clicked Lookup My Email button
            System.assertEquals(false, ctlr.appFound);
            System.assertEquals(true, ctlr.emailChecked);
            System.assertEquals(Label.App2_Message_AppFoundAlreadyPaid, ctlr.emailMessage);
            
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
            
            //User clicks Pay and gets valid cc token
            ctlr.stripeToken = 'tok_1';
            ctlr.submitPayment();
	        System.assertEquals(true, ctlr.isPaid);
    
            //Page will automatically submit on successful payment
            ctlr.submitApplication();
            
	        Test.stopTest();
        }
        
        System.assertEquals(true, ctlr.isPaid);
        System.assertEquals(true, ctlr.isSaved);
        System.assertEquals(Label.App2_Message_SubmitNewSuccess, ctlr.finalMessage);
    }

    static testmethod void testNewApplicationWithPromoCode() { 
        
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
        
        Application2Controller ctlr;
        System.runAs(u){ //Site Guest
	        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new StripePaidHttpCalloutMock());   
            
	        ctlr = new Application2Controller();
            
            //Enter new email addess (doesn't already exist)
            ctlr.app.Email__c = 'newapp@test.com';
            ctlr.verifyEmail(); //User clicked Lookup My Email button
            System.assertEquals(false, ctlr.appFound);
            System.assertEquals(true, ctlr.emailChecked);
            System.assertEquals(Label.App2_Message_AppNotFound, ctlr.emailMessage);
            
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
            
            //User clicks Check Code
            ctlr.promoCode = 'INVALID CODE'; //invalid
            ctlr.validatePromo();
	        System.assertEquals(false, ctlr.promoApplied);

            //User tries again
            ctlr.promoCode = 'TEST'; //valid
            ctlr.validatePromo();
	        System.assertEquals(true, ctlr.promoApplied);

            //Page will automatically submit on successful payment
            ctlr.submitApplication();
            
	        Test.stopTest();
        }
        
        System.assertEquals(false, ctlr.isPaid);
        System.assertEquals(true, ctlr.promoApplied);
        System.assertEquals(true, ctlr.isSaved);
        System.assertEquals(Label.App2_Message_SubmitNewSuccess, ctlr.finalMessage);
    }   

    static testmethod void testExistingApplicationWithPromoCode() { 
        
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
        
        Application2Controller ctlr;
        System.runAs(u){ //Site Guest
	        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new StripePaidHttpCalloutMock());   
            
	        ctlr = new Application2Controller();
            
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
            
            //User clicks Check Code
            ctlr.promoCode = 'INVALID CODE'; //invalid
            ctlr.validatePromo();
	        System.assertEquals(false, ctlr.promoApplied);

            //User tries again
            ctlr.promoCode = 'TEST'; //valid
            ctlr.validatePromo();
	        System.assertEquals(true, ctlr.promoApplied);

            //Page will automatically submit on successful payment
            ctlr.submitApplication();
            
	        Test.stopTest();
        }
        
        System.assertEquals(false, ctlr.isPaid);
        System.assertEquals(true, ctlr.promoApplied);
        System.assertEquals(true, ctlr.isSaved);
        System.assertEquals(Label.App2_Message_SubmitExistingSuccess, ctlr.finalMessage);
    }  
    
    global class StripePaidHttpCalloutMock implements HttpCalloutMock {
	    global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "status":"paid", "amount":5000, "id":"ch_1", "failure_code":null, "failure_message":null }');
            res.setStatusCode(200);
            return res;
        }
    }

    global class StripeFailedHttpCalloutMock implements HttpCalloutMock {
	    global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "status":"failed", "amount":null, "id":null, "failure_code":42, "failure_message":"Well, that happened..." }');
            res.setStatusCode(200);
            return res;
        }
    }    
}