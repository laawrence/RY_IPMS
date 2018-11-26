public class Mgr_ActivityDash
{
	  // Declaring variables
    public String id = '' + UserInfo.getUserId() + '';
    public Integer teamCount = 36;
    public String passedId{get;set;}
    public String passedName{get;set;}
    public Date passedFromDate{get;set;}
    public Date passedToDate{get;set;}
    public String fromDay = Date.today().day().format();
    public String toDay = Date.today().day().format();
    public String fromMonth = Date.today().month().format();
    public String toMonth = Date.today().month().format();
    public String fromYear = '2018';
    public String toYear = '2018';

    // Method to convert month number to text
    public String getMonthName() {

      String monthName;
      if (passedFromDate == null) {
          monthName = Date.today().month().format();
      } else {
          monthName = passedFromDate.month().format();
      }
      switch on monthName {
        when '01' {return 'January';}
        when '02' {return 'February';}
        when '03' {return 'March';}
        when '04' {return 'April';}
        when '05' {return 'May';}
        when '06' {return 'June';}
        when '07' {return 'July';}
        when '08' {return 'August';}
        when '09' {return 'September';}
        when '10' {return 'October';}
        when '11' {return 'November';}
        when '12' {return 'December';}
        when else {return 'Month not found';}
      }
    }

    // Populating the list of PCs for the dropdown menu
    public List<SelectOption> UserSelection {
        get
        {
            List <User> UserQueryList = new List<User>();
            UserQueryList = [Select u.Id, u.Name From User u Where IsActive = true AND ProfileId = '00e36000001bNzGAAU' ORDER BY Name ASC];
            List <SelectOption> UserList = new List<SelectOption>();
            for(User user : UserQueryList)
            {
                UserList.add(new SelectOption(user.Name, user.Name));
            }
            return UserList;
        }
        set;
    }


// Below methods are used by various elements on the visualforce page PC_ActivityDash to get relevant data

    // Method used to get information relating to the current user
    public User getPCInfo() {
        return [SELECT Id, FirstName, LastName, Name, FullPhotoUrl FROM User
                   WHERE Id = :id];
    }

    // Method used to get the scheduled consultations of this user for the given time period
    public Integer getScheduled() {

        Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Lead ' +
            'WHERE OwnerId = \'' + id + '\' AND Consultation_scheduled__c = TRUE ' +
            'AND Consultation_Date_Time__c >= '+fromYear+'-'+fromMonth+'-'+fromDay+'T00:00:00Z' +
            'AND Consultation_Date_Time__c <= '+toYear+'-'+toMonth+'-'+toDay+'T00:00:00Z'
            );

            return results;
    }

    // Method used to get information on the scheduled consultations of the team for the given time period
    public Integer getTeamScheduled() {

        Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Lead ' +
            'WHERE Consultation_scheduled__c = TRUE ' +
            'AND Consultation_Date_Time__c >= '+fromYear+'-'+fromMonth+'-'+fromDay+'T00:00:00Z ' +
            'AND Consultation_Date_Time__c <= '+toYear+'-'+toMonth+'-'+toDay+'T00:00:00Z'

            );

            return results/teamCount;
    }

  // Method used to calculate the hold rate of the current user (
	public Integer getHoldRate() {

        //Catching an error if dividing by 0
        If (getScheduled() == 0) {
         	return 0;
        } Else {
        	Double holdRate = (getCompletes()/getScheduled())*100;
        	Integer results = holdRate.intValue();
        	return results;
        }
    }

	// Method used to calculate the hold rate of the team (
	public Integer getTeamHoldRate() {

        // Catching error if dividing by zero
       	If (getTeamScheduled() == 0) {
        	return 0;
        } Else {
            Double teamHoldRate = (getTeamCompletes()/getTeamScheduled())*100;
        	Integer results = teamHoldRate.intValue();
        	return results;
        }

    }

    // Method used to get the completed consultations of this user for the given time period
    public Integer getCompletes() {

        Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Lead ' +
            'WHERE OwnerId = \'' + id + '\' AND Consultation_Completed__c = TRUE ' +
            'AND Consultation_completed_date__c >= '+fromYear+'-'+fromMonth+'-'+fromDay+' ' +
            'AND Consultation_completed_date__c <= '+toYear+'-'+toMonth+'-'+toDay+''

            );

			return results;

    }

	  // Method used to get the completed consultations of the team for the given time period
    public Integer getTeamCompletes() {

        Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Lead ' +
            'WHERE Consultation_Completed__c = TRUE ' +
            'AND Consultation_completed_date__c >= '+fromYear+'-'+fromMonth+'-'+fromDay+' ' +
            'AND Consultation_completed_date__c <= '+toYear+'-'+toMonth+'-'+toDay+''

            );

			return results/teamCount;

    }

  // Method used to get the opportunities this user created in the given time period
  public Integer getOpps() {

       Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Opportunity ' +
            'WHERE OwnerId = \'' + id + '\' ' +
            'AND CreatedDate >= '+fromYear+'-'+fromMonth+'-'+fromDay+'T00:00:00Z ' +
            'AND CreatedDate <= '+toYear+'-'+toMonth+'-'+toDay+'T00:00:00Z'
            );

			return results;

    }

  // Method used to get the opportunities the team created in the given time period
 	public Integer getTeamOpps() {

       Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Opportunity ' +
            'WHERE CreatedDate >= '+fromYear+'-'+fromMonth+'-'+fromDay+'T00:00:00Z ' +
            'AND CreatedDate <= '+toYear+'-'+toMonth+'-'+toDay+'T00:00:00Z '

            );

			return results/teamCount;
    }

    // Method used to calculate a PC's C-O Rate
    public Integer getCORate() {

        // Catching error if dividing by zero
        If (getCompletes() == 0) {
         	return 0;
        } Else {
           	Double CORate = (getOpps()/getCompletes())*100;
        	Integer results = CORate.intValue();
        	return results;
        }

    }

	// Method used to calculate the team's C-O Rate
	public Integer getTeamCORate() {

        // Catching error if dividing by zero
        If (getTeamCompletes() == 0) {
         	  return 0;
        } Else {
            Double teamCORate = (getTeamOpps()/getTeamCompletes())*100;
          	Integer results = teamCORate.intValue();
          	return results;
        }


    }

  // Method used to get the number of wins by this PC
 	public Integer getWins() {

       Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Opportunity ' +
            'WHERE OwnerId = \'' + id + '\' ' +
            'AND isWon = true ' +
           	'AND CloseDate >= '+fromYear+'-'+fromMonth+'-'+fromDay+ '' +
            'AND CloseDate <= '+toYear+'-'+toMonth+'-'+toDay+''
            );

			return results;
    }

  // Method used to get the number of wins by the team
  public Integer getTeamWins() {

       Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Opportunity ' +
            'WHERE isWon = true ' +
           	'AND CloseDate >= '+fromYear+'-'+fromMonth+'-'+fromDay+ '' +
            'AND CloseDate <= '+toYear+'-'+toMonth+'-'+toDay+''
            );

			return results/teamCount;

    }

  // Method used to calculate a PC's O-W Rate
  public Integer getOWRate() {

        // Catching error if dividing by zero
        If (getOpps() == 0) {
          return 0;
        } Else {
            Double OWRate = (getWins()/getOpps())*100;
        	Integer results = OWRate.intValue();
        	return results;
        }

    }

	// Method used to calculate the team's O-W Rate
	public Integer getTeamOWRate() {

        // Catching error if dividing by zero
        If (getTeamOpps() == 0) {
         	return 0;
        } Else {
            Double teamOWRate = (getTeamWins()/getTeamOpps())*100;
        	Integer results = teamOWRate.intValue();
        	return results;
        }
    }

    // Method when 'save' button is pressed on page
    public PageReference save() {
        User pcFocus = Database.query('SELECT Id FROM User WHERE Name = \''+passedName+'\'');
        id = pcFocus.Id;

        if (passedFromDate != null) {
            fromDay = passedFromDate.day().format();
            fromMonth = passedFromDate.month().format();
            fromYear = passedFromDate.year().format();
        }

        if (passedToDate != null) {
            toDay = passedToDate.day().format();
            toMonth = passedToDate.month().format();
            toYear = passedToDate.year().format();
        }

        return null;
    }

}
