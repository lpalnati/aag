/**
  * Apex Class: IntranetBannerController
  * Description: This class is used to fetch the Banner records and used to build the Banner section dynamically
  *              (T-97451).
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 26th Nov 2012.
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : December 12,2012
  * RelatedTo : Maintain banners list as per the selected current page. 
*/
public with sharing class IntranetBannerController {
	
	public String currentPageName {get; set;}
	//Value comes form custom setting, used to define banner rotating speed on intranet pages. 
	public Integer banner_Roating_Speed {get;set;}
	/*
	 * here we all the valid banner records will be retrieved and to be used on Intranet Banner
	   to show the dynamic banner 
	*/
	
	public IntranetBannerController() {
	  //Retrieve Banner rotating speed configured from the Custom setting by Sys Admin
	  banner_Roating_Speed = (Intranet_Config__c.getInstance('Banner_Rotating_Speed') != null) ? Integer.valueOf(Intranet_Config__c.getInstance('Banner_Rotating_Speed').Value__c) : 7000;
	}
	
	public list<Intranet_Banner__c> banners {	
		get {
				return [Select Summary__c,Header__c,Button_Label__c,URL__c,Target__c,Header_Color__c,Summary_Color__c,Position__c,Button_Location__c, (SELECT Id, Name 
        		     FROM Attachments limit 1) From Intranet_Banner__c where Start_Date__c<= :system.now()
		           		and  End_Date__c >=:system.now() and Pages__c includes (:currentPageName) order by Sequence__c];
		}
		set;
	}
	
}