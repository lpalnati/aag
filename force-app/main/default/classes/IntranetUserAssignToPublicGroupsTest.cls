/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetUserAssignToPublicGroupsTest
* Date          :  March 04,2013
* Description   :  Verify functionality of IntranetUserAssignToPublicGroups trigger
****************************************************************************************/
@isTest(seeAllData = true)
private class IntranetUserAssignToPublicGroupsTest {

    static testMethod void testUserMapping() {
			Test.startTest();
				User usr = TestUtil.createUser(false);
				usr.Username += '.test';
				usr.Email = 'test1234'+ Integer.valueOf(Math.random()) +'@virginamerica.com';
				usr.CommunityNickname = 'test1234';
				insert usr;
				//assert user is now part of All Virgin America chatter group
				System.assertEquals([Select count() From CollaborationGroupMember g where CollaborationGroup.Name = 'All Virgin America' AND MemberId =:usr.Id], 0);
			Test.stopTest();
			//assert user is now part of All Virgin America chatter group
			System.assertEquals([Select count() From GroupMember g where Group.Name = 'All Virgin America' AND UserOrGroupId =:usr.Id], 1);
    }
}