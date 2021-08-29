/**********************************************************************************
  Apex Class: IntranetSecuredResourceController
  CreatedBy : Harshit Jain
  CreatedDate : march 15, 2012
  Description: This class is used to show training resouces on secure pages.
  Modified By : Ashish Sharma 
  Modified Date : 7th November, 2014
  Ref. : T-331969 - Verify that documents shown in the Resources section of a 
                    Secure template page are alphabetized
  Modification Description : Updated the query for Content__r and added order by Title
**********************************************************************************/
public with sharing class IntranetSecuredResourceController {
	//String used to create HTML for menu
  public String ulString {get; set;}
  //map that will hold cms page name and list of all pages 
  public Map<String, Id> nameIdMap {get; set;}
  public Map<String, Intranet_CMS_Page__c> idCMSMap {get; set;}
  private String currentPageName {get;set;}
  
	public IntranetSecuredResourceController() {
		nameIdMap = new Map<String,Id>();
		idCMSMap = new Map<String, Intranet_CMS_Page__c>();
		currentPageName = Apexpages.currentPage().getParameters().get('name');
		ulString = '';
		for(Intranet_CMS_Page__c cmsPage : [Select Parent_page__r.Name, Name, 
									 		 (Select Id,Name From CMS_Pages__r order by Sequence__c), 
											 (Select ContentDocumentId, Title,ContentUrl,FileType From Content__r 
											 	where Start_Date__c <= :system.now() 
											 	and End_Date__c >= :system.now()
											 	order by Title) 
											  From Intranet_CMS_Page__c i 
											  where Name =: currentPageName
											  OR Parent_page__c != null]) {
			nameIdMap.put(cmsPage.Name,cmsPage.Id);
			idCMSMap.put(cmsPage.Id,cmsPage);
    }
    createSideBar(idCMSMap.get(nameIdMap.get(currentPageName)));
    ulString = '<ul id="hc2NavTopUL" class="clearfix" style="background-color: white;">' + ulString + '</ul>';
	}
	
	//Method will create list that will be used on Intranet secure pages to show training resources.
	private void createSideBar(Intranet_CMS_Page__c cmsPage) {
		for(Intranet_CMS_Page__c childPage : cmsPage.CMS_Pages__r) {
			ulString = ulString + '<li class="topPage"> <a href="javascript:void(0);" class="_2wx clearfix">' +	childPage.Name + '<span class="_2wy _2wz"></span></a>';
			if(idCMSMap.get(childPage.Id).Content__r.size() > 0 || idCMSMap.get(childPage.Id).CMS_Pages__r.size() > 0) {
				ulString = ulString + '<ul class="_2bl">';
				createSideBar(idCMSMap.get(childPage.Id));
				ulString = ulString + '<li class="_3pe"><a href="javascript:void(0);" class="_2wx clearfix">Back<span class="_2wy _2w-"></span></a></li></ul>';
			}else{
				ulString = ulString + '<ul class="_2bl"><li class="_3pe"><a href="javascript:void(0);" class="_2wx clearfix">Back<span class="_2wy _2w-"></span></a></li></ul>';
			}
			ulString = ulString + '</li>';
		}
		for(ContentVersion content:cmsPage.Content__r) {
			String url = ((content.FileType == 'Link')? (content.ContentUrl.containsIgnoreCase('youtube')? 'javascript:openPopupInIframe(\\\''+content.ContentUrl.substringAfterLast('=')+'\\\');' :content.ContentUrl) : '/'+content.ContentDocumentId);
			String target = (content.FileType == 'Link' && content.ContentUrl.containsIgnoreCase('youtube')) ? '_self' : '_blank';
			ulString = ulString + '<li class="_bw"><a href="'+url+'" target="'+target+'" class="_2wx clearfix"><img src="/img/icon/mail16.png" style="margin-right:5px;">' +	content.Title + '<span class="_2wy"></span></a></li>';
		}
	}
}