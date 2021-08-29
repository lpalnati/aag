/**
  * Apex Class: IntranetFooterController
  * Description: This class is used to get footer information from custom setting.
  * Created By: harshit Jain (Appirio Off)
  * Created Date: 23rd Nov 2012.
*/
public with sharing class IntranetFooterController {
	public String companyName {get;set;}
	public String facebookLink{get;set;}
	public String twitterLink{get;set;}
	public String linkedinLink{get;set;}
	public String pinterestLink{get;set;}
	public String instgramLink{get;set;}
	public String youtubeLink{get;set;}
	
	
	public IntranetFooterController() {
		//default value would be blank
		companyName = '';
		if(Intranet_Config__c.getInstance('Company_Name_Footer') != null) {
					companyName = Intranet_Config__c.getInstance('Company_Name_Footer').Value__c;
		}
		//populate social link form intranet config custom setting
		facebookLink = (Intranet_Config__c.getInstance('Facebook Social Link') != null) ? Intranet_Config__c.getInstance('Facebook Social Link').Value__c : '';
		twitterLink = (Intranet_Config__c.getInstance('Twitter Social Link') != null) ? Intranet_Config__c.getInstance('Twitter Social Link').Value__c : ''; 
		linkedinLink = (Intranet_Config__c.getInstance('LinkedIn Social Link') != null) ? Intranet_Config__c.getInstance('LinkedIn Social Link').Value__c : '';
		pinterestLink = (Intranet_Config__c.getInstance('Pinterest Social Link') != null) ? Intranet_Config__c.getInstance('Pinterest Social Link').Value__c : '';
		instgramLink = (Intranet_Config__c.getInstance('Instgram Social Link') != null) ? Intranet_Config__c.getInstance('Instgram Social Link').Value__c : '';
		youtubeLink  = (Intranet_Config__c.getInstance('YouTube Social Link') != null) ? Intranet_Config__c.getInstance('YouTube Social Link').Value__c : '';
	}
}