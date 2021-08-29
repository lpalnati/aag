/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetMapCalendarControllerTest
* Date          :  March 21,2013
* Description   :  Verify functionality of IntranetMapCalendarController class
****************************************************************************************/ 
@isTest
private class IntranetMapCalendarControllerTest {

    static testMethod void testLocationSearch() {
    		Intranet_CMS_Page__c cmsPage = TestUtil.createContent(false);
				cmsPage.Name = 'testGoogleAPI';
				cmsPage.Template__c = 'Team';
				cmsPage.Show_Google_Map__c = 'Intranet_Location__c';
				cmsPage.Cal_1__c = 'Test script'; 
				cmsPage.Cal_1_Label__c = 'Test Calendar';
				insert cmsPage;
        Intranet_Config__c config = TestUtil.createIntranetConfig(true, 'Google_Map_Default_Address', '555 bugrlinton road');
        Intranet_Location__c location1 = TestUtil.createLocation(false, 'Hotel', 'Virgin Hotel','Customer service');
        Intranet_Location__c location2 = TestUtil.createLocation(false, 'Training', 'Flight Training center','');
        insert new List<Intranet_Location__c>{location1,location2};
       	
       	//Set IntranetTeam as current page
				PageReference pageRef = Page.IntranetTeam;
        Test.setCurrentPage(pageRef);
        //Pass parameteres to current page
        ApexPages.currentPage().getParameters().put('name', 'testGoogleAPI');
        Test.startTest();
        	IntranetMapCalendarController controller = new IntranetMapCalendarController();
        	system.assert(controller.locationTypeOptions.size() > 1);
        	controller.selectedType = 'Hotel';
        	controller.searchLocationText = 'Hotel';
        	controller.searchLocation();
        	//assert nubmer of result return
        	system.assertEquals(controller.addressWrapperList.size(),1);
        	system.assertEquals(controller.allAddressString,'300 st NYC DC 132123');
        	//assest Address
        	system.assertEquals(controller.allAddressString,'300 st NYC DC 132123');	
        	//assest Notes
        	system.assertEquals(controller.allNotesString,'Customer service');
        Test.stopTest();
    }
}