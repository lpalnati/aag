/**
  * Apex Class: IntranetContentController
  * Description: This class is used to display Content 
  * Created By: Virendra (Appirio Off)
  * Created Date: 23rd Nov 2012.
  * Updated Date : December 6, 2012
  * Related To : T-102188 - Add standard chatter component to IntranetArticle 
  * LastUpdatedBy : Harshit Jain
  * LastUpdatedDate : December 11, 2012
  * Related To : Used this class to show IntranetArticle data on IntranetContent Page.
  */
public with sharing class IntranetContentController {
  
  public list<Attachment> galleryAttachmentList{get;set;}
  public String categoryType {get;set;}
  public String tabName {get;set;}  
  //public String cmsPageId {get;set;}
  // It will use to render the attachments on content page
  public boolean renderAttachment {get;set;}
  // It will use to get the attachment
  public Intranet_CMS_Page__c cmsPage{get;set;}
  // It will use to show article description on page 
  public Intranet_Article__c articleDetail{get;set;}
	//Value comes form custom setting, used to define banner rotating speed on intranet pages. 
	public Integer banner_Roating_Speed {get;set;}
   
  /*
  * Default constructor create data based on category parameter of url
  * weather it is Intranet content or Intranet Articles.
  */
  public IntranetContentController() {
  	renderAttachment = false; 
  	galleryAttachmentList = new list<Attachment>();
  	tabName = 'Home';
  	categoryType = ApexPages.currentPage().getParameters().get('category');
  	banner_Roating_Speed = (Intranet_Config__c.getInstance('Banner_Rotating_Speed') != null) ? Integer.valueOf(Intranet_Config__c.getInstance('Banner_Rotating_Speed').Value__c) : 7000;
	  if(ApexPages.currentPage().getParameters().get('tabName') != null) {
    	tabName = ApexPages.currentPage().getParameters().get('tabName');
    }
    // It will prevent rendering attachments on IntranetContent page.
    if(ApexPages.currentPage().getParameters().get('Id') != null && categoryType == 'Content') {
      renderAttachment = true;
    }
		if(categoryType == 'News') {
			createArticleData(ApexPages.currentPage().getParameters().get('Id'));
		}else if(categoryType == 'Content') {
			createContentData(ApexPages.currentPage().getParameters().get('Id'));
		}						
  }
    
     
  public void createContentData(String contentId) {
  	// Fetch Intranet CMS content details  
    for(Intranet_CMS_Page__c cmsPageObj : [Select Template__c, SystemModstamp, Status__c,
    		                                         (SELECT Id, Name 
        		                                        FROM Attachments order by createdDate  ) 
            			                                Id, Parent_page__r.name,Name, Description__c,
                  			                          Video__c, Video_Type__c, Video_Caption__c,Total_View__c
                                            From Intranet_CMS_Page__c Where Id =:contentId ]) {
			//Prepare attachement images list                                             	
    	for(Attachment attachedImage : cmsPageObj.Attachments) {
           galleryAttachmentList.add(attachedImage);                      
      }
      cmsPage = cmsPageObj;
    }	
  }  
  
  public void createArticleData(String articleId) {
  	for(Intranet_Article__c intranetArticle : [Select i.URL__c, i.Summary__c, i.Name,
  																									 i.Id, i.Description__c, i.Article_Type__c,
  	 																							 (Select Id, Name From Attachments),Total_View__c
  	 																					From Intranet_Article__c i where Id=: articleId]) {
			//Prepare attachement images list   	 																						
    	for(Attachment attachment : intranetArticle.Attachments) {
       	galleryAttachmentList.add(attachment);
      }
      articleDetail = intranetArticle;
    }		
  }
}