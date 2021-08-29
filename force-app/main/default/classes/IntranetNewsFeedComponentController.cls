/**
  * Apex Class: IntranetNewsFeedComponentController
  * Description: This class is used to show intranet news feeds (T-97451)
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: Nov 23rd, 2012.
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : December 12,2012
  * RelatedTo : Maintain IntranetList as per the selected current page.
  */
public with sharing class IntranetNewsFeedComponentController {
    
    // page id, this will decide that for which page we are going to 
    // show news feed and can be used to fetch news feed according to
    // page ids.
    public String pageId {get; set;}
    //Value comes form custom setting, used to define banner rotating speed on intranet pages. 
		public Integer banner_Roating_Speed {get;set;}
		//map of intranetArticles
		public map<Id, Intranet_Article__c> mapOfArticles {get;set;}
		//selected article by user
		public Id selectedArticleId{get;set;} 
		
		public IntranetNewsFeedComponentController() {
			//Initialise default with 6 sec
	  	banner_Roating_Speed = 7000;
	  	//Retrieve Banner rotating speed configured from the Custom setting by Sys Admin
	  	for(Intranet_Config__c qLinks : [Select Name, value__c From Intranet_Config__c where Name = 'Banner_Rotating_Speed']) {
					banner_Roating_Speed = Integer.valueOf(qLinks.Value__c);					      		
	  	}	
		}		
	  /*
  	 * Get news list along with their attached images to show on page. 
  	*/
  	public List<Intranet_Article__c> newsList {
  		get {
  			mapOfArticles = new map<Id,Intranet_Article__c>([SELECT Id, URL__c, Summary__c, Start_Date__c, Pages__c, 
                       Name, End_Date__c, Description__c, CreatedDate, 
                       Article_Type__c,Total_View__c,
                       (SELECT Id 
                        FROM Attachments LIMIT 1)
                  FROM Intranet_Article__c 
                  Where Start_Date__c <= :system.now()
		           	 	and End_Date__c >= :system.now() 
		           		and Pages__c includes (:pageId) 
		         order by Start_Date__c DESC
                limit 5]);
        return mapOfArticles.values();        
  		} 
  		set;
  	}
}