/**
  * Apex Class: IntranetHeaderComponentController
  * Description: This class is used to get current logged in user information.
  *               (T-97451)  
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 23rd Nov 2012.
*/
public with sharing class IntranetHeaderComponentController {
    public User currentUser {get; set;}
    public String pageId {get;set;}
    public Integer unreadCounts {get;set;}
    public String pageTitle {get;set;}
    
    /*
     * Default Constructor, it will fetch the details of logged in user.
    */
    public IntranetHeaderComponentController () {
    		//Retrieve intranet page title from the Custom setting configured by Sys Admin
    		pageTitle = (Intranet_Config__c.getInstance('VF_PAGE_TITLE') != null) ? Intranet_Config__c.getInstance('VF_PAGE_TITLE').Value__c : '';
        currentUser = [SELECT Id, SmallPhotoUrl, Name FROM User WHERE Id = :UserInfo.getUserId()];
        unreadCounts = 0;
        for(Intranet_Required_Reading__c  ee:[Select Id From Intranet_Required_Reading__c where  User_ID__c =:Userinfo.getUserId() and Complete_Date__c = null]){
           unreadCounts	++;
        }
    }

}