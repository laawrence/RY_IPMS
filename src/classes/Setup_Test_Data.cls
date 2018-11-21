/**  
* @desc This class is a helper class to setup data for Unit Tests.
* @author OneLight Labs - support@onelightlabs.com 
*/ 

@isTest
public class Setup_Test_Data {
    
    private static final Integer NUMBER_OF_ACCOUNTS = 1;
    private static final Integer NUMBER_OF_CONTACTS_PER_ACCOUNT = 1;
    private static final Integer NUMBER_OF_OPPORTUNITIES_PER_ACCOUNT = 1;

    
    /**
     * @desc This static method will create and return a User with a specific profile name.
     */
    public static User createUser(String profileName) { 
        
        String uniqueSuffix = String.valueOf(DateTime.now().getTime()); //unique suffix for alias, email, username
        uniqueSuffix = uniqueSuffix.substring(uniqueSuffix.length()-8, uniqueSuffix.length()-1);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName]; 
        if (p == null) p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        User u = new User(Alias = 'a' + uniqueSuffix,
                            Email='email' + uniqueSuffix + '@remoteyear.com.test', 
                            EmailEncodingKey='UTF-8',
                            LastName='UNIT TEST ' + uniqueSuffix, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName='email' + uniqueSuffix + '@remoteyear.com.test');

        insert u;

        return u;
    }
    
    /**
     * @desc This static method will create and return a user with Profile System Administrator.
     */
    public static User createUser() {
        
        return createUser('System Administrator');
    }
    
    /**
     * @desc This static method will create and return Accounts .
     */
    public static List<Account> createAccounts() {
       
        List<Account> accts = new List<Account>();
        for (Integer i = 0; i <= NUMBER_OF_ACCOUNTS; i++) {
            accts.add(new Account(Name='TEST ACCOUNT ' + (i+1)));
        }
        
        insert accts;
        
        return accts;
    }
    
    /**
     * @desc This static method will create and return a contact related to each account
     * in the parameter list.
     */
    public static List<Contact> createContacts (List<Account> accts) {
    
        List<Contact> conts = new List<Contact>();
        for (Account a : accts) {
            for (Integer i = 0; i <= NUMBER_OF_CONTACTS_PER_ACCOUNT; i++) {
                conts.add(new Contact(LastName='TEST CONTACT ' + (i+1) + ' FOR ' + a.name,
                                      AccountId=a.id));
            }    
        }
        
        insert conts;
        
        return conts;
    }  
    
    /**
     * @desc This static method will create and return an Opportunity related to each account
     * in the parameter list.
     */
    public static List<Opportunity> createOpportunities (List<Account> accts) {
    
        List<Opportunity> opps = new List<Opportunity>();
        for (Account a : accts) {
            for (Integer i = 0; i <= NUMBER_OF_OPPORTUNITIES_PER_ACCOUNT; i++) {
                opps.add(new Opportunity(Name='TEST OPPTY ' + (i+1) + ' FOR ' + a.name,
                                      Promo_Code__c = 'Test',
                                      StageName = 'New',
                                      CloseDate = date.today(),
                                      AccountId=a.id));
            }    
        }
        
        insert opps;
        
        return opps;
    }   
    
 
    

  
}