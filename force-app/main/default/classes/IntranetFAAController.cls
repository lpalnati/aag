/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetFAAController 
* Date          :  March 08,2013
* Description   :  Controller of IntranetFAA page.
****************************************************************************************/ 
public with sharing class IntranetFAAController {
    //String to hold team name selected by current user
    public String groupName {get;set;}
    //Variable decide to display menu and search bar on contractor template. 
    public Boolean isMenuAndSearchBarShow {get;set;}
    public Boolean isMapCalendarComponentDisplay{get;set;}
    
    
    public PageReference initialize() {
        groupName = 'Pilot Training';
        if(ApexPages.currentPage().getParameters().get('name') == null) {
            pageReference page = new pageReference('/apex/IntranetFAA?name='+groupName+'&tabName=Teams');
            page.setRedirect(true);
            return page;
        }else {
            groupName = ApexPages.currentPage().getParameters().get('name');
            isMenuAndSearchBarShow = true;
            //hide menu and serch bar on page for selected profiles mentioned in custom setting                             
            if(Intranet_Config__c.getInstance('Profile_Ids_For_Hide_MenuBar') != null)                              
            isMenuAndSearchBarShow = (Intranet_Config__c.getInstance('Profile_Ids_For_Hide_MenuBar').Value__c).containsIgnoreCase(Userinfo.getProfileId()) ? false:true;
      
        //if Show_Google_Map__c or Calendar related fields is not null then mapCalender component will display on team pages. 
            for(Intranet_CMS_Page__c page : [Select Id From Intranet_CMS_Page__c i 
                                                                        where Name =:groupName 
                                                                        AND (Show_Google_Map__c != null
                                                                        OR Cal_1__c != null
                                                                        OR Cal_2__c != null
                                                                        OR Cal_3__c != null)]) {
            isMapCalendarComponentDisplay = true;
        }   
        }
        return null;
    }
}