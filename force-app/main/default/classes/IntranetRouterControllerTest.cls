/**
  * Apex Class: IntranetRouterControllerTest
  * Created By: Harshit Jain (Appirio Off)
  * Created Date: march 2, 2013
  * Description: This class is used to verify IntranetRouterControllerTest.
***/
@isTest
private class IntranetRouterControllerTest {

    static testMethod void verifyRouterFunctinality() {
	    // TO DO: implement unit test
	    Intranet_Article__c article = TestUtil.createArticle(true);
      // Using Page IntranetRouter and setting as CurrentPage
      PageReference thePage = Page.IntranetRouter; 
      Test.setCurrentPage(thePage);  
      ApexPages.currentPage().getParameters().put('Id',article.Id);
			ApexPages.currentPage().getParameters().put('type','Intranet_Article__c');
			ApexPages.currentPage().getParameters().put('path',Encodingutil.urlEncode('http://www.ggogle.com', 'UTF-8'));
			IntranetRouterController intranetRouterController = new IntranetRouterController();
			intranetRouterController.updateTotalView();
			//Verfity total view increment
			system.assertEquals(getArticle(article.Id).Total_View__c, 1);
			ApexPages.currentPage().getParameters().put('type','Intranet_CMS_Page__c');
			ApexPages.currentPage().getParameters().put('path','http://www.SecureTeam.com?name=Policies & Procedures&tabName=Teams');
			IntranetRouterController intranetRouterController1 = new IntranetRouterController();
			system.assertEquals(intranetRouterController1.updateTotalView().getUrl(),'http://www.SecureTeam.com?name=Policies+%26+Procedures&tabName=Teams');
    }
    
    private static Intranet_Article__c getArticle(Id articleId){
    	return [Select Id,Total_View__c from Intranet_Article__c where id =:articleId];
    }
}