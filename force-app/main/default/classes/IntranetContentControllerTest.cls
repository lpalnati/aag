/**
  * Apex Class: IntranetContentControllerTest
  * Description: test class for IntranetContentController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class IntranetContentControllerTest {
	
	//method to test when category is content
	private static testmethod void createContentDataTest(){
		Intranet_CMS_Page__c content = TestUtil.createContent(true);
		TestUtil.createAttachment(true, content.Id);
		
		//Set IntranetContent as current page
		PageReference pageRef = Page.IntranetContent;
        Test.setCurrentPage(pageRef);
        
        //Pass parameteres to current page
        ApexPages.currentPage().getParameters().put('tabName', 'test');
        ApexPages.currentPage().getParameters().put('category', 'Content');
        ApexPages.currentPage().getParameters().put('Id', content.Id);
        
        IntranetContentController conObj = new IntranetContentController();
        system.assertEquals(conObj.galleryAttachmentList.size(),1);
	}
	
	//method to test when category is News
	private static testmethod void createArticleDataTest(){
		Intranet_Article__c article = TestUtil.createArticle(true);
		TestUtil.createAttachment(true, article.Id);
		
		//Set IntranetContent as current page
		PageReference pageRef = Page.IntranetContent;
        Test.setCurrentPage(pageRef);
        
        //Pass parameteres to current page
        ApexPages.currentPage().getParameters().put('tabName', 'test');
        ApexPages.currentPage().getParameters().put('category', 'News');
        ApexPages.currentPage().getParameters().put('Id', article.Id);
        
        IntranetContentController conObj = new IntranetContentController();
        
        //Assert attachment list has some data
        system.assertEquals(conObj.galleryAttachmentList.size(),1);
	}
}