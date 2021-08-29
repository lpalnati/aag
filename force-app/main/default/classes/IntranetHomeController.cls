/*******************************************************************
* Author        :  Harshit Jain 
* Name          :  IntranetHomeController
* Date          :  December 13,2012
* Description   :  Controller for IntranetHome                  
*******************************************************************/
public with sharing class IntranetHomeController {
	//String hold page name selected by current user on Intranet. 
	public String pageName {get;set;}
	
	
	public IntranetHomeController() {
		//Default selected page would be home page
		pageName = 'Home';
		//Populate selected page name.
		//Based on selected page name other information will be populated on intranet page like Banners,Articles,Links etc.
		if(ApexPages.currentPage().getParameters().get('tabName') != null) {
			pageName = ApexPages.currentPage().getParameters().get('tabName');
		}
	}
}