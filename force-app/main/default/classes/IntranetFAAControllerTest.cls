/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetContractorControllerTest
* Date          :  March 29,2013
* Description   :  Verify functionality of IntranetContractorController class
****************************************************************************************/ 
@isTest
private class IntranetFAAControllerTest {

    static testMethod void testContractorController() {
        //Contrator template pages will not show menu and serch bar for following profile    
        Id profileId = [Select id from Profile Where Name != 'System Administrator' limit 1].Id;
        //Create custom setting record to insert profile id so user of same profile can not see menu and search bar.
        Intranet_Config__c config = TestUtil.createIntranetConfig(true, 'Profile_Ids_For_Hide_MenuBar', profileId);
        // Using Page IntranetContractor and setting as CurrentPage
      PageReference thePage = Page.IntranetFAA; 
      Test.setCurrentPage(thePage);
      ApexPages.currentPage().getParameters().put('name','Pilot Training');
            IntranetFAAController controller = new IntranetFAAController();
            controller.initialize();
            //Assert isMenuAndSearchBarShow should be true because current user profile id not present in custom setting record.
            System.assertEquals(controller.isMenuAndSearchBarShow, true);
            //update custom setting record with current user profile Id
            config.Value__c += ','+Userinfo.getProfileId();
            update config;
            IntranetFAAController con = new IntranetFAAController();
            con.initialize();
            //Assert isMenuAndSearchBarShow should be false because current user profile id present in custom setting record.
            System.assertEquals(con.isMenuAndSearchBarShow, false);                   
    }
}