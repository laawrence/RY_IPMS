global without sharing class ApplicationSocialController {
    
    public Application__c app {get; set;}
    public Application__c existingApp {get; set;}

    public Boolean emailChecked {get; private set;}
    public Boolean appFound {get; private set;}
    public String emailMessage {get; set;}
    private String emailMatchTag;

    public Boolean isSaved {get; private set;}
    public String finalMessage {get; set;}
    public Boolean isApplicationSubmitted {get; set;}
    
    private Opportunity opp;
    
    private String existingLeadId;
    
     
    public ApplicationSocialController(){ //Constructor //STEP 0
        //initialize variables
        emailChecked = false;
        appFound = false;
        emailMessage = Label.App2_Message_AppLookup;
        emailMatchTag = 'None'; //default to None, set in verifyEmail method
        isApplicationSubmitted = false;
        
        //instantiate Application object
        app = new Application__c();

    } //End Constructor
   
    public void verifyEmail(){ //STEP 1
        //Lookup email address on existing applications
        List<Application__c> apps = [SELECT Id, Name, Email__c, Payment_Details__c,Lead__c
                                     FROM Application__c 
                                     WHERE Email__c =: app.Email__c 
                                     ORDER BY CreatedDate DESC];
        if (apps.size() > 0 && apps[0].Payment_Details__c == null){
            existingApp = apps[0];
            appFound = true;
            emailMessage = Label.App2_Message_AppFound;
            emailMatchTag = (apps.size()>1)?'Multiple':'Single';
        } else if (apps.size() > 0 && apps[0].Payment_Details__c != null) {
            appFound = false;
            emailMessage = Label.App2_Message_AppFoundAlreadyPaid;
            emailMatchTag = 'Previous Payment';
            existingLeadId = apps[0].Lead__c;
        } else {
            appFound = false;
            emailMessage = Label.App2_Message_AppNotFound;
            emailMatchTag = 'None';            
        } 
        emailChecked = true;
    }

    public void submitApplication() { //STEP 4
      try {
        if (appFound){
          //Update existing Application record
          existingApp.First_Name__c = app.First_Name__c;
          existingApp.Last_Name__c = app.Last_Name__c;
                                  
          existingApp.Recommender_1_Name__c = app.Recommender_1_Name__c;
          existingApp.Recommender_1_Email__c = app.Recommender_1_Email__c;
          existingApp.Recommender_1_Relationship__c = app.Recommender_1_Relationship__c;
                    
          existingApp.Recommender_2_Name__c = app.Recommender_2_Name__c;
          existingApp.Recommender_2_Email__c = app.Recommender_2_Email__c;
          existingApp.Recommender_2_Relationship__c = app.Recommender_2_Relationship__c;
                    
          existingApp.Why_Remote_Year__c = app.Why_Remote_Year__c;
          existingApp.Why_You__c = app.Why_You__c;
          existingApp.Personal_and_Professional_Goals__c = app.Personal_and_Professional_Goals__c;
          existingApp.Current_Job__c = app.Current_Job__c;
          existingApp.Current_Level_of_Remote_Work__c = app.Current_Level_of_Remote_Work__c;
          existingApp.Employment_Status__c = app.Employment_Status__c;
          existingApp.Employer_Approval__c = app.Employer_Approval__c;
          existingApp.Primary_Country_of_Citizenship__c = app.Primary_Country_of_Citizenship__c;
          existingApp.Current_Country__c = app.Current_Country__c;
          existingApp.Annual_Income__c = app.Annual_Income__c;
          existingApp.Joint_Application__c = app.Joint_Application__c;
          existingApp.Additional_Information__c = app.Additional_Information__c;
          existingApp.Earliest_Departure_Date__c = app.Earliest_Departure_Date__c;
          existingApp.Part_Two_Submitted_Date_Time__c = DateTime.now();
          existingApp.Part_Two_Match_Details__c = emailMatchTag;
          existingApp.Application_Status__c = Label.App2_Set_ApplicationStatus;
          existingApp.OwnerId = '00G36000002KKRE';
                    
                    
          update existingApp;
        } else {
           app.Part_Two_Submitted_Date_Time__c = DateTime.now();
           app.Part_Two_Match_Details__c = emailMatchTag;
           app.Application_Status__c = Label.App2_Set_ApplicationStatus;
           app.Sales_Path__c = 'Consumer Applicant';
           app.OwnerId = '00G36000002KKRE';
           
           insert app;
        }
        finalMessage = 'Application Submitted Successfully.';
        isApplicationSubmitted = true;
        
      } catch (Exception e) {
        //system.debug('### exception e = ' + e);
        finalMessage = Label.App2_Message_SubmitFailure;
      }
     
    } 
}