/**
  * Apex Class: IntranetHomeControllerTest
  * Description: test class for IntranetHomeController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class IntranetHomeControllerTest {
	
	private static testmethod void homeControllerTest(){
		//Create test Data
		Intranet_CMS_Page__c cmsPage = TestUtil.createContent(true);
		//Set IntranetHome as current page
		PageReference pageRef = Page.IntranetHome;
    Test.setCurrentPage(pageRef);
    
    //Pass parameteres to current page
    ApexPages.currentPage().getParameters().put('tabName', 'testContent');
    IntranetHomeController conObj = new IntranetHomeController();
    //assert controller's property 'pageName' value has been changed
    system.assertEquals(conObj.pageName,'testContent');
	}
}