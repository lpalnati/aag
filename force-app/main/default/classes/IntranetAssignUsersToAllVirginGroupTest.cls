/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetAssignUsersToAllVirginGroupTest
* Date          :  April 04,2013
* Description   :  Verify functionality of IntranetAssignUsersToAllVirginGroupCon class
****************************************************************************************/     
@isTest
private class IntranetAssignUsersToAllVirginGroupTest {

    static testMethod void TestPublicGroupMembership() {
       List<User> userList = new List<user>();
       User user;
       for(Integer i=0; i<=4; i++) {
       	user = TestUtil.createUser(false);
       	user.Username += i;
       	user.CommunityNickname += i;
       	userList.add(user);
       }
       
       if(!userList.isEmpty())
       	insert userList;
       	
       Test.startTest();
       	IntranetAssignUsersToAllVirginGroupCon controller = new IntranetAssignUsersToAllVirginGroupCon();
       	controller.getNotChatterUserList();
       	controller.getNotPublicUserList();
       	controller.addToAllVirginChatterGroup();
       	controller.addToAllVirginPublicGroup();
       Test.stopTest();	
       	 
    }
}