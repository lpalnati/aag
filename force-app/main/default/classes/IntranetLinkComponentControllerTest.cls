/**
  * Apex Class: IntranetLinkComponentControllerTest
  * Description: test class for IntranetLinkComponentController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class IntranetLinkComponentControllerTest {
	
	private static testmethod void LinkComponentControllerTest(){
		
		//Insert 'Intranet_Config__c' custom setting 
		Intranet_Config__c config = new Intranet_Config__c(Name='NO_OF_LINKS' ,value__c='20000');
		insert config;
		
		//creates new Intranet_Links__c records
		Intranet_Links__c link1 = testUtil.createIntranetLink(false);
		Intranet_Links__c link2 = testUtil.createIntranetLink(false);
		list<Intranet_Links__c> listIntanetLink = new list<Intranet_Links__c>{link1,link2};
		insert listIntanetLink;
		
		//Attach attachments to Intranet_Links__c records
		TestUtil.createAttachment(true, link1.ID);
		TestUtil.createAttachment(true, link2.ID);
		
		
		IntranetLinkComponentController conObj = new IntranetLinkComponentController();
		conObj.pageId = 'brand';
		
		//Assert intranetList size is greater than 0. 
		system.assertEquals(conObj.intranetList.size(),2);
		
		//Assert no_Of_Link property value has been changed
		system.assertEquals(conObj.no_Of_Link,20000);
		
	}
}