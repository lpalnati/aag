/*******************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetCreateChatterGroupForCMSPageTest
* Date          :  March 02,2013
* Description   :  Verify functionality of IntranetCreateChatterGroupForCMSPage trigger              
*******************************************************************************************/
@isTest
private class IntranetCreateChatterGroupForCMSPageTest {

    static testMethod void testCreateChatterGroupFunctionality() {
    	Test.startTest();
        Intranet_CMS_Page__c cmsPage = TestUtil.createContent(false);
        cmsPage.Create_Chatter_Group__c = true;
        insert cmsPage;
        system.assertEquals(getChatterGroup(cmsPage.Name).Name,cmsPage.Name);
       Test.stopTest(); 
    }
    
    private static CollaborationGroup getChatterGroup(String name){
    	return [Select Id,name from CollaborationGroup where Name =:name];
    }
}