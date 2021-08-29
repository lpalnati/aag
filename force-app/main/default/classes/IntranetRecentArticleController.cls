/**
  * Apex Class: IntranetRecentArticleController
  * Description: This class is used to display Recent Articles 
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 30rd Nov 2012.
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : December 13,2012
  * RelatedTo : Maintain newsList as per the selected current page.
  */

public with sharing class IntranetRecentArticleController {  
  
  // page id, this will decide that for which page we are going to 
  // show news feed and can be used to fetch news feed according to
  // page ids.
  public String currentPage{get;set;}
 
  /*
   * Get news list along with their attached images to show on page. 
  */
  public List<Intranet_Article__c> newsList {
  	get {
  		return [SELECT Id, URL__c, Summary__c, Start_Date__c, Pages__c, 
                      Name, End_Date__c, Description__c, CreatedDate, Article_Type__c
                 FROM Intranet_Article__c 
                Where Start_Date__c <= Today
		           	 	and End_Date__c >= Today 
		           		and Pages__c includes (:currentPage) 
		         order by Start_Date__c DESC
                limit 5];
                
  	} 
 	}
}