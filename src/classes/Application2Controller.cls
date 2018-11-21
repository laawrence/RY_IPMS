global without sharing class Application2Controller {
    
    public Application__c app {get; set;}
    public Application__c existingApp {get; set;}

    public Boolean emailChecked {get; private set;}
    public Boolean appFound {get; private set;}
    public String emailMessage {get; set;}
    private String emailMatchTag;
    
    public String promoCode {get; set;}
    public Set<String> availableCodes {private get; private set;}
    public Boolean promoApplied {get; private set;}
    public String promoMessage {get; private set;}
    public Boolean lockCode {get; private set;}

    public String stripeToken {get; set;}
    public Boolean isPaid {get; private set;}
    public String paymentMessage {get; private set;}
    private String stripeChargeId;

    public Boolean isSaved {get; private set;}
    public String finalMessage {get; set;}
    
    private Opportunity opp;
    
    private String existingLeadId;
    
    private final String stripeSecretKey;
    private final String stripeChargeUrl;
    private final Integer stripeChargeAmount;
    private Boolean isPromoFromOppty;
    
     
    public Application2Controller(){ //Constructor //STEP 0
        //initialize variables
        emailChecked = false;
        appFound = false;
        promoApplied = false;
        isPaid = false;
        isSaved = false;
        isPromoFromOppty = false;
        emailMessage = Label.App2_Message_AppLookup;
        emailMatchTag = 'None'; //default to None, set in verifyEmail method
        
        //instantiate Application object
        app = new Application__c();
        
        //get possible promo codes
        List<Promo_Code__c> promoCodes = Promo_Code__c.getAll().values();
        availableCodes = new Set<String>();
        for (Promo_Code__c code : promoCodes){
            availableCodes.add(code.Name.toUpperCase());
        }
        
        //get Stripe Config
        Stripe_Config__c stripeConfig;
        if([SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId() LIMIT 1].IsSandbox){
            stripeConfig = Stripe_Config__c.getValues('test'); //development, sandbox, test environments
        } else {
            stripeConfig = Stripe_Config__c.getValues('live'); //production, live environment           
        }
        stripeSecretKey = stripeConfig.Secret_Key__c; //this should never be in javascript, visualforce or public repo
        stripeChargeUrl = stripeConfig.Charge_URL__c;
        stripeChargeAmount = (Integer)stripeConfig.Application_Part_2_Charge_Amount_Cents__c ; //$50.00 in cents is 5000

        //check page parameters
        promoCode = ApexPages.currentPage().getParameters().get('code');
        if(promoCode!=null && promoCode!=''){
            validatePromo();
            lockCode = promoApplied; //if successfully applied promo code from URL, lock promo fields
            isPromoFromOppty = true;
        }

    } //End Constructor
   
    public void verifyEmail(){ //STEP 1
        //Lookup email address on existing applications
        List<Application__c> apps = [SELECT Id, Name, Email__c, Stripe_Charge_Id__c, Payment_Details__c,Lead__c
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
    
    public void validatePromo(){ //STEP 2
        //check promo code
        system.debug('checking promo code: ' + promoCode);
        if (availableCodes.contains(promoCode.toUpperCase())){
            promoApplied = true;
            promoMessage = '"' + promoCode + '" ' + Label.App2_Message_PromoSuccess;
        } else if ([SELECT COUNT() FROM Opportunity WHERE Promo_Code__c =: promocode] > 0) {
            promoApplied = true;
            isPromoFromOppty = true;
            promoMessage = '"' + promoCode + '" ' + Label.App2_Message_PromoSuccess;           
        } else {
            promoApplied = false;
            promoMessage = '"' + promoCode + '" ' + Label.App2_Message_PromoFailure;
        }
    }
    
    public void submitPayment() { //STEP 3
        StripeChargeResponse stripeCharge; //Inner Class
        if(stripeToken!=null){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(stripeChargeUrl);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + stripeSecretKey);
            req.setBody('amount=' + stripeChargeAmount + '&currency=usd&source=' + stripeToken + '&description=Application%20Fee%20(Part%202)');    
            HttpResponse res = h.send(req);
            try{    
                Type resultType = Type.forName('Application2Controller.StripeChargeResponse');
                stripeCharge = (StripeChargeResponse)JSON.deserialize(res.getBody(), resultType);
                
                isPaid = (stripeCharge.status=='paid'); //this is Stripe's expected status for "paid"
                if(isPaid){
                    stripeChargeId = stripeCharge.id;
                    paymentMessage = Label.App2_Message_PaymentSuccess;                
                } else {
                    paymentMessage = Label.App2_Message_PaymentFailure + ' ' + stripeCharge.failure_message;                
                }
            } catch (Exception e) {
                stripeCharge = new StripeChargeResponse();
                stripeCharge.status = 'unknown'; stripeCharge.failure_code = '0'; stripeCharge.failure_message = Label.App2_Messages_PaymentUnknownError;
                
                isPaid = false; paymentMessage = Label.App2_Message_PaymentFailure + ' ' + stripeCharge.failure_message;                
            }
        } else { //no token sent, what's up with that?!      
            stripeCharge = new StripeChargeResponse();
            stripeCharge.status = 'unknown'; stripeCharge.failure_code = '0';
            stripeCharge.failure_message = Label.App2_Messages_PaymentUnknownError;
            
            isPaid = false; paymentMessage = Label.App2_Message_PaymentFailure + ' ' + stripeCharge.failure_message;                
        }
    } 

    public void submitApplication() { //STEP 4
    system.debug('### isPaid and promoapplied = ' + isPaid + ' ' + promoapplied);
        if(isPaid || promoApplied){ //revalidate that the server-side context says the app has been paid or a promo code has been applied. (prevent input hidden form field injection)
            try{
                if (appFound){
                    //Update existing Application record
                    existingApp.First_Name__c = app.First_Name__c;
                    existingApp.Last_Name__c = app.Last_Name__c;
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
                    existingApp.Stripe_Charge_Id__c = stripeChargeId;
                    if(isPaid){
                        existingApp.Payment_Details__c = 'Paid by Stripe ' + stripeChargeId;
                    } else if(promoApplied){
                        existingApp.Payment_Details__c = 'Used Invitation Code ' + promoCode.toUpperCase();
                        if (isPromoFromOppty) {
                            Opportunity o = [SELECT Id, AccountId FROM Opportunity WHERE Promo_Code__c =: promocode LIMIT 1];
                            system.debug('### promocode and 0 = ' + promocode + ' '+o);                           
                            existingApp.Opportunity__c = o.Id;
                            existingApp.Account__c = o.AccountId;
                            existingApp.Sales_Path__c = 'Business Development';  
                            existingApp.Employer_Approval__c = 'My company has pre-approved Remote Year'; 
                        }
                        system.debug('### existingApp.Sales_Path__c = ' + existingApp.Sales_Path__c);                                        
                    }
                    
                    update existingApp;
                    finalMessage = Label.App2_Message_SubmitExistingSuccess;
                } else {
                    //Insert new Application record
                    app.Part_Two_Submitted_Date_Time__c = DateTime.now();
                    app.Part_Two_Match_Details__c = emailMatchTag;
                    app.Application_Status__c = Label.App2_Set_ApplicationStatus;
                    app.Sales_Path__c = 'Consumer Applicant';
                    if(existingLeadId != null && existingLeadId.length() > 14) {
                        app.Lead__c = existingLeadId;                     
                    }
                    
                    app.Stripe_Charge_Id__c = stripeChargeId;
                    if(isPaid){
                        app.Payment_Details__c = 'Paid by Stripe ' + stripeChargeId;
                    } else if(promoApplied){
                        app.Payment_Details__c = 'Used Invitation Code ' + promoCode.toUpperCase();
                        system.debug('### promocode = ' + promocode);
                        if (isPromoFromOppty) {
                            Opportunity o = [SELECT Id, AccountId FROM Opportunity WHERE Promo_Code__c =: promocode LIMIT 1];
                            system.debug('### promocode and 0 = ' + promocode + ' '+o);
                            app.Opportunity__c = o.Id;
                            app.Account__c = o.AccountId;
                            app.Sales_Path__c = 'Business Development'; 
                            app.Employer_Approval__c = 'My company has pre-approved Remote Year';  
                        }
                        system.debug('### app.Sales_Path__c = ' + app.Sales_Path__c);               
                    }

                    insert app;
                    system.debug('### app.id = ' + app.id);
                    finalMessage = Label.App2_Message_SubmitNewSuccess;
                    

                }
                isSaved = true;
            } catch (Exception e) {
                system.debug('### exception e = ' + e);
               
                isSaved = false; finalMessage = Label.App2_Message_SubmitFailure;
            }
        } else {
            isSaved = false; finalMessage = Label.App2_Message_SubmitFailure;
        }
    }
    
    public class StripeChargeResponse {
        String status; //'paid', 'failed', 'pending' or 'unknown'
        String id; //charge id
        Integer amount; //in cents
        String failure_code;
        String failure_message;
    }    
    
}