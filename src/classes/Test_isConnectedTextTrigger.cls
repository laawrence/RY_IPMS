@isTest
public class Test_isConnectedTextTrigger {
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

    //Method to simulate a Textline text being created
    static testMethod void addText() {

    	Set<id> leadIds = new Set<id>();

    	//Create test Leads
    	Lead lead1 = createLead('Company1','Mcgee', 'mcgee@gmail.com');
    	Lead lead2 = createLead('Company2','Mcgregor', 'mcgregor@gmail.com');

        //Test Tasks to associate with text leads
    	List<Task> texts = new List<Task>();

			Task text = new Task();
			text.Subject = 'Inbound Textline Text';
			text.whoId = lead1.Id;

			texts.add(text);

			Task text1 = new Task();
			text1.Subject = 'Inbound Textline Text';
			text1.whoId = lead2.Id;

			texts.add(text1);

    	insert texts;

        
    	//Get the test Leads created
    	leadIds.add(lead1.Id);
    	leadIds.add(lead2.Id);

    	//Query for the texts created
    	Map<id,Lead> textMap = new Map<id,Lead>([select Id, Name, isConnected__c from Lead where Id IN :leadIds]);

        //Asserting that what we inserted matches the No of Textline Texts field on the lead
    	System.assertEquals(TRUE,textMap.get(lead1.Id).isConnected__c);
    	System.assertEquals(TRUE,textMap.get(lead2.Id).isConnected__c);

    }
    
}