/**
  * Apex Class: IntranetHeaderComponentControllerTest
  * Description: test class for IntranetHeaderComponentController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class IntranetHeaderComponentControllerTest {
	
	private static testmethod void HeaderComponentControllerTest(){
		//Creates new user
		User usr = TestUtil.createUser(true);
		Intranet_Config__c config = TestUtil.createIntranetConfig(true, 'VF_PAGE_TITLE', 'Virgin America');
		Intranet_Required_Reading__c RR = new Intranet_Required_Reading__c();
		RR.Name = 'Test content';
		RR.Due_Date__c = Date.today().addDays(2);
		RR.User_ID__c = usr.id;
		insert RR;
		IntranetHeaderComponentController conObj;
		
		//Create controller obj to fetch current logged in user detail
		system.runAs(usr){
			conObj = new IntranetHeaderComponentController();
		}
		
		//Assert currentUser is newly created user
		system.assertEquals(conObj.currentUser.Id,usr.Id);
	}
}