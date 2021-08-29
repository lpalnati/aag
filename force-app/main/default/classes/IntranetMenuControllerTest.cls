/**
  * Apex Class: IntranetMenuControllerTest
  * Description: test class for IntranetMenuControllerTest
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class IntranetMenuControllerTest {
	
	private static testmethod void MenuControllerTest(){
		//Insert Intranet_CMS_Page__c records
		Intranet_CMS_Page__c TopCMSPage = TestUtil.createContent(true);
		
		Intranet_CMS_Page__c CMSPage1 = TestUtil.createContent('Home',false,TopCMSPage.Id,'Interior Home');
		Intranet_CMS_Page__c CMSPage2 =TestUtil.createContent('testContent2',false,TopCMSPage.Id ,'Team');
		Intranet_CMS_Page__c CMSPage3 =TestUtil.createContent('testContent3',false,TopCMSPage.Id ,'Content');
		Intranet_CMS_Page__c CMSPage4 = TestUtil.createContent('testContent1',false,TopCMSPage.Id,'Home');
		list<Intranet_CMS_Page__c> listCMSPageLevel2 = new list<Intranet_CMS_Page__c>{CMSPage1,CMSPage2,CMSPage3,CMSPage4};
		insert listCMSPageLevel2;
		
		Intranet_Config__c config1 = new Intranet_Config__c(Name='Android_Marketplace_URL' ,value__c='www.verginamerica.com');
		Intranet_Config__c config2 = new Intranet_Config__c(Name='IOS_Marketplace_URL' ,value__c='www.verginamerica.com');
		list<Intranet_Config__c> listConfig = new list<Intranet_Config__c>{config1,config2};
		insert listConfig;
		
		Test.startTest();
		IntranetMenuController conObj = new IntranetMenuController();
		//Assert controller's ulString propety is not null
		system.assert(conObj.ulString != null);
		Test.stopTest();
	}
}