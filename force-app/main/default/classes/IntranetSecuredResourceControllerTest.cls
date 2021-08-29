/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetSecuredResourceControllerTest
* Date          :  March 04,2013
* Description   :  Verify functionality of IntranetSecuredResourceController trigger
****************************************************************************************/  
@isTest(seeAllData = true)
private class IntranetSecuredResourceControllerTest {

    static testMethod void testsideBar() {
        createDummyData();
        Test.startTest();
        // Using Page IntranetMySubmittedFormDetail and setting as CurrentPage
      	PageReference thePage = Page.IntranetSecuredTeam; 
      	Test.setCurrentPage(thePage);
      	ApexPages.currentPage().getParameters().put('name','Secure');
      	IntranetSecuredResourceController controller = new IntranetSecuredResourceController();
      	//assert list for sidebar component
      	system.assertNotEquals(controller.ulString,'');
      	Test.stopTest();	
    }
    
    static void createDummyData() {
    	Intranet_CMS_Page__c TopCMSPage = TestUtil.createContent(true);
    	Intranet_CMS_Page__c CMSPage1 = TestUtil.createContent('Secure',true,TopCMSPage.Id,'Interior Home');
			Intranet_CMS_Page__c CMSPage2 = TestUtil.createContent('testContent2',true,CMSPage1.Id ,'Team');
			Intranet_CMS_Page__c CMSPage3 = TestUtil.createContent('testContent3',true,CMSPage2.Id ,'Content');
    }
}