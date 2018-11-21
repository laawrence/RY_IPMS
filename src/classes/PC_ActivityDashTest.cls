@isTest
public class PC_ActivityDashTest
{
    
    @isTest static void PC_ActivityDashTest()
    {
        Lead newLead = new Lead() ;
        newLead.Company = 'Test Company';
        newLead.LastName = 'McGee';
        newLead.Email = 'test@test.com';
        newLead.Status = 'New';
        insert newLead;
        
        Opportunity newOpp = new Opportunity();
       	newOpp.Name = 'Test Opp';
        newOpp.StageName = 'Consideration';
        newOpp.CloseDate = date.ValueOf('2018-09-30');
        insert newOpp;
        
        PC_ActivityDash ctlr = new PC_ActivityDash();
        ctlr.getScheduled();
        ctlr.getTeamScheduled();
        ctlr.getCompletes();
        ctlr.getTeamCompletes();
        ctlr.getOpps();
        ctlr.getTeamOpps();
        ctlr.getHoldRate();
        ctlr.getTeamHoldRate();
        ctlr.getCORate();
        ctlr.getTeamCORate();
        ctlr.getWins();
        ctlr.getTeamWins();
        ctlr.getOWRate();
        ctlr.getTeamOWRate();
    }
}