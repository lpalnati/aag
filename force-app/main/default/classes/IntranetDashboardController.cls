/*******************************************************************
* Author        :  Harshit Jain 
* Name          :  IntranetDashboardController
* Date          :  December 03,2012
* Description   :  Used to update current user Information                 
*******************************************************************/
public with sharing class IntranetDashboardController {
		//hold current user information
    public User userInformation {get; set;}
    public Boolean isMenuAndSearchBarShow {get;set;}
        
    public IntranetDashboardController() {
    	isMenuAndSearchBarShow = true;
	    //populate current user information
      userInformation = [Select u.TimeZoneSidKey, u.Phone, u.LastName, 
	                          		u.LanguageLocaleKey, u.FirstName, u.Email,u.Profile.Name 
	                         From User u 
	                        where Id =: Userinfo.getUserId()];
		 //hide menu and serch bar on page for selected profiles mentioned in custom setting		                        
		 if(Intranet_Config__c.getInstance('Profile_Ids_For_Hide_MenuBar') != null)		                        
	   	isMenuAndSearchBarShow = (Intranet_Config__c.getInstance('Profile_Ids_For_Hide_MenuBar').Value__c).containsIgnoreCase(Userinfo.getProfileId()) ? false:true; 
    }
    
    //method updated current user information.
    //Notify current user via pagemessage
    public pageReference updateUserInformation() {
      update userInformation;
	    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Information has been updated. Email will be send to your new email id for confirmation if you updated your email.'));
	    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Information has been updated.'));
	    return new pagereference('/apex/IntranetDashboard');    
    }
}