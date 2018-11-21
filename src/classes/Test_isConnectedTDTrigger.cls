@isTest
public class Test_isConnectedTDTrigger {
    
    //Method to insert a Lead into the database
    static Lead createLead(String company, String lastname, String email) {

    	Lead newLead = new Lead() ;
        newLead.Company = company;
        newLead.LastName = lastname;
        newLead.Email = email;
        newLead.Status = 'New';
        insert newLead;
		
		return newLead;

	}
    
    //Method to simulate a Talkdesk Activity being created
    static testMethod void addTdActivity() {

    	Set<id> leadIds = new Set<id>();

    	//Create test Leads
    	Lead lead1 = createLead('Company1','Mcgee', 'mcgee@gmail.com');
    	Lead lead2 = createLead('Company2','Mcgregor', 'mcgregor@gmail.com');

        //Test TDActivities to associate with leads
    	List<talkdesk__Talkdesk_Activity__c> calls = new List<talkdesk__Talkdesk_Activity__c>();

			talkdesk__Talkdesk_Activity__c call = new talkdesk__Talkdesk_Activity__c();
			call.talkdesk__Disposition_Code__c = 'Connected - Call Back Later';
            call.talkdesk__User__c = '00536000004x6RhAAI';
            call.talkdesk__Talkdesk_Id__c = 'CA316d17525d497b781d56dd1892d94f99';
			call.talkdesk__Start_Time__c = Datetime.now();
			call.talkdesk__End_Time__c = Datetime.now();
			call.name = 'OutboundTest';            
			call.talkdesk__Lead__c = lead1.Id;

			calls.add(call);

			talkdesk__Talkdesk_Activity__c call1 = new talkdesk__Talkdesk_Activity__c();
			call1.talkdesk__Disposition_Code__c = 'Connected - Call Back Later';
            call1.talkdesk__User__c = '00536000004x6RhAAI';
            call1.talkdesk__Talkdesk_Id__c = 'CA316d17525d497b781d56dd1892d94f98';
			call1.talkdesk__Start_Time__c = Datetime.now();
			call1.talkdesk__End_Time__c = Datetime.now();
			call1.name = 'OutboundTest';
			call1.talkdesk__Lead__c = lead2.Id;

			calls.add(call1);

    	insert calls;

        
    	//Get the test Leads created
    	leadIds.add(lead1.Id);
    	leadIds.add(lead2.Id);

    	//Query for the calls created
    	Map<id,Lead> callMap = new Map<id,Lead>([select Id, Name, isConnected__c from Lead where Id IN :leadIds]);

        //Asserting that what we inserted matches the No of Textline Texts field on the lead
    	System.assertEquals(TRUE,callMap.get(lead1.Id).isConnected__c);
    	System.assertEquals(TRUE,callMap.get(lead2.Id).isConnected__c);

    }
    
}