public class OfferApplicationsController {

    private Application__c application;

    public OfferApplicationsController() {
        application = [SELECT Id, Rails_External_Id__c 
                       FROM Application__c
                       WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        
    }
    
    public void backfillRailsExternalIdIfNeeded() {
        if (application.Rails_External_Id__c == null) {
            application.Rails_External_Id__c = Guid.createGuid();
            update application;
        }
    }
    
    public Application__c getApplication() {
        return application;
    }

}