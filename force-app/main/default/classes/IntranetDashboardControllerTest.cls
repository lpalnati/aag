/*******************************************************************
* Author        :  Harshit Jain 
* Name          :  IntranetDashboardControllerTest
* Date          :  December 03,2012
* Related Task  :  T-101364
* Description   :  Verify functionality of IntranetDashboardController class.                 
*******************************************************************/
@isTest
private class IntranetDashboardControllerTest {

    static testMethod void testUserinformationUpdate() {
    		Intranet_Config__c config = TestUtil.createIntranetConfig(true, 'Profile_Ids_For_Hide_MenuBar', Userinfo.getProfileId());
        IntranetDashboardController intranetDashboardController = new IntranetDashboardController();
        //loginUser information should not be null
        system.assert(intranetDashboardController.userInformation != null);
        
        //Update user information with correct data 
        intranetDashboardController.userInformation.Phone = '123878342';
        intranetDashboardController.userInformation.Email = 'TestSystemUser@virginamerica.com';
        intranetDashboardController.updateUserInformation();
        User updatedUser1 = getUser(userInfo.getUserId());
        system.assert(updatedUser1 != null);
        system.assertEquals(updatedUser1.Phone , '123878342');
        
        //Update user last name information
        intranetDashboardController.userInformation.LastName = 'TestLastname';
        intranetDashboardController.updateUserInformation();
        User updatedUser2 = getUser(userInfo.getUserId());
        system.assert(updatedUser2 != null);
        system.assertEquals(updatedUser2.LastName , 'TestLastname');
    }
    
   //get User Information
   private static User getUser(Id userId) {
    return [Select u.TimeZoneSidKey, u.Phone, u.LastName, 
                                     u.LanguageLocaleKey, u.FirstName, u.Email 
                            From User u 
                         where Id =: userId];
   }
}