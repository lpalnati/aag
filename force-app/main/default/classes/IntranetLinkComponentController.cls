/**
  * Apex Class: IntranetLinkComponentController
  * Description: This class is used to fetch Intranet links and thier attachments (T-97451)
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 23rd Nov 2012.
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : December 12,2012
  * RelatedTo : Maintain IntranetList as per the selected current page. 
*/
public with sharing class IntranetLinkComponentController {

		public String pageId {get;set;}
		public Integer no_Of_Link {get;set;}

    /*
    * Default Constructor, this will initialize the intranet list and fetch
    * intranet link lists.
    */
    
    public IntranetLinkComponentController() {
      //Retrieve No of Links configured from the Custom setting by Sys Admin
      no_Of_Link = (Intranet_Config__c.getInstance('NO_OF_LINKS') != null) ? Integer.valueOf(Intranet_Config__c.getInstance('NO_OF_LINKS').Value__c) : 6;
    }
	  
	  // intranet links list used to show links on pages.
		public List<Intranet_Links__c> intranetList {
			get {
	   		// query for links and their attachments
	    	return [SELECT URL__c, Name,Target__c, 
	      	             (SELECT Id 
	        	                FROM Attachments LIMIT 1)
	          	          FROM Intranet_Links__c i 
	            	        WHERE  Start_Date__c<= :system.now()
		           					AND  End_Date__c >= :system.now() 
	                  	  AND pages__c includes (:pageId) 
	                    	ORDER BY Sequence__c 
	                    	LIMIT :no_Of_Link];
			}
			set;
		}
}