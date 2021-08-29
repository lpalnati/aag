/**
  * Apex Class: IntranetRecentArticleControllerTest
  * Description: test class for IntranetRecentArticleController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class IntranetRecentArticleControllerTest {
	
	private static testmethod void testMethod1(){
		//Insert new Intranet_Article__c records
		Intranet_Article__c article1 = TestUtil.createArticle(false);
		Intranet_Article__c article2 = TestUtil.createArticle(false);
		Intranet_Article__c article3 = TestUtil.createArticle(false);
		list<Intranet_Article__c> listArticle = new list<Intranet_Article__c>{article1,article2,article3};
		insert listArticle;
		
		IntranetRecentArticleController conObj = new IntranetRecentArticleController();
		//set currentPage
		conObj.currentPage = 'Brand';
		
		//Assert newsFeed list has some data
		system.assertEquals(conObj.newsList.size(),3);
	}
}