public class ApplicationTriggerHandler {

    public static void reparentApplications (List<Application__c> newApplications) {
        
        List<Lead> leads = new List<Lead>();
        List<Id> leadIdsToDelete = new List<Id>();       
        List<String> emails = new List<String>();
        Map<String, Lead> leadMap = new Map<String, Lead>();        
        
        //build list of Application emails
        for (Application__c app : newApplications) {
            if (app.Email__c != null) {
                system.debug('### app.Email__c = ' + app.Email__c);
                emails.add(app.Email__c);
            }            
        }
        
        //query for leads whose Email matches that of an Application in the trigger
        if (emails.size() > 0) {
            leads = [SELECT Id, CreatedDate, Email FROM Lead WHERE Email IN: emails ORDER BY CreatedDate ASC];
            system.debug('### leads = ' + leads);
        }       

        //build a map of Email-Lead and a list of Leads to delete
        if (leads.size() > 0) {
            for (Lead lead : leads) {   
                if (lead.Email != null) {                       
                    if (leadMap.containsKey(lead.Email)) {
                        leadIdsToDelete.add(lead.Id);
                    } else {
                        leadMap.put(lead.Email, lead);
                    }
                }
            }            
        }
        
        system.debug('### leadMap = ' + leadMap);
        
        //if the Application Lead lookup is not equal to the desired Parent lead, reparent
        for (Application__c app : newApplications) {
            
            system.debug('### app.Email__c app.Lead__c ' + app.Email__c + ' '+ app.Lead__c);
            if (app.Email__c != null && app.Lead__c != null && leadMap.get(app.Email__c) != null && app.Lead__c != leadMap.get(app.Email__c).Id) {
                app.Lead__c = leadMap.get(app.Email__c).Id;
            }        
        }

        if (leadIdsToDelete.size() > 0) {
            system.debug('### leadIdsToDelete = ' + leadIdsToDelete);
            Database.delete(leadIdsToDelete);
        
        }

    }  
}