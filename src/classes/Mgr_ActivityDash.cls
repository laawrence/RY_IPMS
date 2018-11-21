public class Mgr_ActivityDash
{
	// Declaring variables
    //public String id = '00536000005KupH';
    public String id = '' + UserInfo.getUserId() + '';
    public String startDay = '01';
    public String endDay = '31';
    public String month = '08';
    public String year = '2018';
    public Double scheduled;
    public Double teamScheduled;
    public Integer completes;
    public Integer teamCompletes;
    public Integer teamCount = 38;
    public Double opps;
    public Double teamOpps;
    public Integer wins;
    public Integer teamWins;
    public String passedId{get;set;}
    public String passedName{get;set;}

// BACKGROUND
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
            'AND Consultation_Date_Time__c >= 2018-'+month+'-'+startDay+'T00:00:00Z ' +
            'AND Consultation_Date_Time__c <= 2018-'+month+'-'+endDay+'T00:00:00Z'
            );

            scheduled = results;
            return results;

    }

    // Method used to get information on the scheduled consultations of the team for the given time period
    public Integer getTeamScheduled() {

        Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Lead ' +
            'WHERE Consultation_scheduled__c = TRUE ' +
            'AND Consultation_Date_Time__c >= 2018-'+month+'-'+startDay+'T00:00:00Z ' +
            'AND Consultation_Date_Time__c <= 2018-'+month+'-'+endDay+'T00:00:00Z'

            );

            teamScheduled = results/teamCount;
            return results/teamCount;

    }

  // Method used to calculate the hold rate of the current user (
	public Integer getHoldRate() {
     	getScheduled();
        getCompletes();

        //Catching an error if dividing by 0
        If (scheduled == 0) {
         	return 0;
        } Else {
        	Double holdRate = (completes/scheduled)*100;
        	Integer results = holdRate.intValue();
        	return results;
        }

    }

	// Method used to calculate the hold rate of the team (
	public Integer getTeamHoldRate() {
     	getTeamScheduled();
        getTeamCompletes();

        // Catching error if dividing by zero
       	If (teamScheduled == 0) {
        	return 0;
        } Else {
            Double teamHoldRate = (teamCompletes/teamScheduled)*100;
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
            'AND Consultation_completed_date__c >= 2018-'+month+'-'+startDay+' ' +
            'AND Consultation_completed_date__c <= 2018-'+month+'-'+endDay+''

            );

         	completes = results;
			return results;

    }

	  // Method used to get the completed consultations of the team for the given time period
    public Integer getTeamCompletes() {

        Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Lead ' +
            'WHERE Consultation_Completed__c = TRUE ' +
            'AND Consultation_completed_date__c >= 2018-'+month+'-'+startDay+' ' +
            'AND Consultation_completed_date__c <= 2018-'+month+'-'+endDay+''

            );

            teamCompletes = results/teamCount;
			return results/teamCount;

    }

  // Method used to get the opportunities this user created in the given time period
  public Integer getOpps() {

       Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Opportunity ' +
            'WHERE OwnerId = \'' + id + '\' ' +
            'AND CreatedDate >= 2018-'+month+'-'+startDay+'T00:00:00Z ' +
            'AND CreatedDate <= 2018-'+month+'-'+endDay+'T00:00:00Z '
            //'AND CreatedDate >= 2018-06-01T00:00:00Z ' +
            //'AND CreatedDate <= 2018-06-30T00:00:00Z '

            );

         	opps = results;
			return results;

    }

  // Method used to get the opportunities the team created in the given time period
 	public Integer getTeamOpps() {

       Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Opportunity ' +
            'WHERE CreatedDate >= 2018-'+month+'-'+startDay+'T00:00:00Z ' +
            'AND CreatedDate <= 2018-'+month+'-'+endDay+'T00:00:00Z '

            );

         	teamOpps = results/teamCount;
			return results/teamCount;
    }

    // Method used to calculate a PC's C-O Rate
    public Integer getCORate() {
        getCompletes();
        getOpps();

        // Catching error if dividing by zero
        If (completes == 0) {
         	return 0;
        } Else {
           	Double CORate = (opps/completes)*100;
        	Integer results = CORate.intValue();
        	return results;
        }

    }

	// Method used to calculate the team's C-O Rate
	public Integer getTeamCORate() {
        getTeamCompletes();
        getTeamOpps();

        // Catching error if dividing by zero
        If (teamCompletes == 0) {
         	return 0;
        } Else {
            Double teamCORate = (teamOpps/teamCompletes)*100;
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
           	'AND CloseDate >= 2018-'+month+'-'+startDay+ '' +
            'AND CloseDate <= 2018-'+month+'-'+endDay+''
            );

         	wins = results;
			return results;
    }

  // Method used to get the number of wins by the team
  public Integer getTeamWins() {

       Integer results = Database.countQuery(
            'SELECT COUNT() ' +
            'FROM Opportunity ' +
            'WHERE isWon = true ' +
           	'AND CloseDate >= 2018-'+month+'-'+startDay+ '' +
            'AND CloseDate <= 2018-'+month+'-'+endDay+''
            );

         	teamWins = results/teamCount;
			return results/teamCount;

    }

  // Method used to calculate a PC's O-W Rate
  public Integer getOWRate() {
        getOpps();
        getWins();

        // Catching error if dividing by zero
        If (opps == 0) {
          return 0;
        } Else {
            Double OWRate = (wins/opps)*100;
        	Integer results = OWRate.intValue();
        	return results;
        }

    }

	// Method used to calculate the team's O-W Rate
	public Integer getTeamOWRate() {
        getTeamOpps();
        getTeamWins();

        // Catching error if dividing by zero
        If (teamOpps == 0) {
         	return 0;
        } Else {
            Double teamOWRate = (teamWins/teamOpps)*100;
        	Integer results = teamOWRate.intValue();
        	return results;
        }
    }

    // Method when 'save' button is pressed on page
    public PageReference save() {

		// id = passedId;
        User pcFocus = Database.query('SELECT Id FROM User WHERE Name = \''+passedName+'\'');
        id = pcFocus.Id;
        return null;
    }


    public List<User> UserTemp = new List<User>();

    public List<SelectOption> UserList
    {
        get
        {
            UserTemp = [Select u.Id, u.Name From User u
                        Where IsActive = true AND ProfileId = '00e36000001bNzGAAU' ORDER BY Name ASC];

            UserList = new List<SelectOption>();

            for(User temp : UserTemp)
            {
                UserList.add(new SelectOption(temp.Name, temp.Name));
            }
            return UserList;
        }
        set;
    }




    public Date fromDate{ get; set; }

    public Date toDate{ get; set; }

    public String theDate;

    public PageReference UserInput() {
     return null;
    }

}
