@isTest(SeeAllData=true)

public class InterviewListController {
	
    public static testMethod List<Application__c> getApps() {
        
        List<Application__c> results = Database.query(
            'SELECT Id, Application_status__c, Interview_scheduled_date__c, First_name__c, Last_name__c, Email__c, Interviewer__c ' +
            'FROM Application__c ' +
            'WHERE OwnerId = \'00536000004x6RhAAI\' AND Interview_scheduled_date__c = THIS_WEEK ' +
            'ORDER BY Interview_scheduled_date__c ' +
            'LIMIT 20'
            
            );
        
		return results;		
        
    }
    
}