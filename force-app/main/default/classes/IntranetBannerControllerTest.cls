/**
  * Apex Class: IntranetBannerControllertest
  * Description: test class for IntranetBannerController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class IntranetBannerControllerTest {
	
	private static testmethod void bannerSectionTest(){
		
		//Insert 'Intranet_Config__c' custom setting 
		Intranet_Config__c config = new Intranet_Config__c(Name='Banner_Rotating_Speed' ,value__c='20000');
		insert config;
		
		TestUtil.createIntranetBanner(true);
		IntranetBannerController conObj = new IntranetBannerController();
		conObj.currentPageName = 'Brand';
		
		//assert valid banner list size
		system.assert(conObj.banners.size()>0);
		system.assertEquals(conObj.banner_Roating_Speed,20000);
	}

}