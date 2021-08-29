/**
  * Apex Class: IntranetTeamControllerTest
  * Description: test class for IntranetTeamController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest
private class IntranetTeamControllerTest {
	
	private static testmethod void TeamControllerTest(){
		//Insert new Collaboration Group
		CollaborationGroup collaborationGroup = TestUtil.createGroup(true);
		//Create test Data
		Intranet_CMS_Page__c cmsPage = TestUtil.createContent(false);
		cmsPage.Name = 'testGroup';
		cmsPage.Template__c = 'Team';
		cmsPage.Show_Google_Map__c = 'Intranet_Location__c';
		cmsPage.Cal_1__c = 'Test script'; 
		insert cmsPage;
		
		//Set IntranetTeam as current page
		PageReference pageRef = Page.IntranetTeam;
        Test.setCurrentPage(pageRef);
        
        //Pass parameteres to current page
        ApexPages.currentPage().getParameters().put('name', 'testGroup');
        
        IntranetTeamController conObj = new IntranetTeamController();
        //assert controller's property 'groupId' value has been changed to collaborationGroup
        system.assertEquals(conObj.groupId,collaborationGroup.Id);
				//assert isMapCalendarComponentDisplay should be true beacuse CmsPage contain map and calendar 
        system.assertEquals(conObj.isMapCalendarComponentDisplay, true);
	}
}