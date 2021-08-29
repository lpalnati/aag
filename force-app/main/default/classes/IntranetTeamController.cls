/*
Created By : Harshit Jain
Created Date : December 12,2012
Description  : Controller for IntranetTeam page.
*/
public with sharing class IntranetTeamController {
	//String to hold team name selected by current user
	public String groupName {get;set;}
	//Respective group id of selected team 
	public Id groupId {get;set;}
	public Boolean isMapCalendarComponentDisplay{get;set;}
	
	public IntranetTeamController() {
		groupName = ApexPages.currentPage().getParameters().get('name');
		isMapCalendarComponentDisplay = false;
		//fetch groupId of selected team show chatter feed on IntranetTeam page.
		for(CollaborationGroup groupObj : [Select c.Name, c.Id From CollaborationGroup c where c.Name =: groupName limit 1] ) {
			groupId = groupObj.Id;
		}
		//if Show_Google_Map__c or Calendar related fields is not null then mapCalender component will display on team pages. 
		for(Intranet_CMS_Page__c page : [Select Id From Intranet_CMS_Page__c i 
    																 where Name =:ApexPages.currentPage().getParameters().get('name') 
    																 AND (Show_Google_Map__c != null
    																 OR Cal_1__c != null
    																 OR Cal_2__c != null
    																 OR Cal_3__c != null)]) {
    	isMapCalendarComponentDisplay = true;
   }
	}
}