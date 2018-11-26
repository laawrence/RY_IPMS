@isTest
public class Mgr_ActivityDashTest
{
    static testMethod void Mgr_ActivityDashTest()
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

        Mgr_ActivityDash ctlr = new Mgr_ActivityDash();
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