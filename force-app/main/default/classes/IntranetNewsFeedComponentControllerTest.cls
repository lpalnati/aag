/**
  * Apex Class: IntranetNewsFeedComponentControllerTest
  * Description: test class for IntranetNewsFeedComponentController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class IntranetNewsFeedComponentControllerTest {
	
	private static testmethod void NewsFeedComponentControllerTest(){
		//Insert 'Intranet_Config__c' custom setting 
		Intranet_Config__c config = new Intranet_Config__c(Name='Banner_Rotating_Speed' ,value__c='20000');
		insert config;
		
		//Insert new Intranet_Article__c records
		Intranet_Article__c article1 = TestUtil.createArticle(false);
		Intranet_Article__c article2 = TestUtil.createArticle(false);
		Intranet_Article__c article3 = TestUtil.createArticle(false);
		list<Intranet_Article__c> listArticle = new list<Intranet_Article__c>{article1,article2,article3};
		insert listArticle;
		
		IntranetNewsFeedComponentController conObj = new IntranetNewsFeedComponentController();
		//set PageIds according to which Intranet_Article__c records have to be retrieved
		conObj.pageId = 'Brand';
		//Assert newsFeed list has some data
		system.assertEquals(conObj.newsList.size(),3);
		conObj.selectedArticleId = listArticle.get(0).Id;
		system.assertEquals(conObj.banner_Roating_Speed,20000);
	}
}