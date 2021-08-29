/**********************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetRestrictDelGroupMembershipTest
* Date          :  March 26,2013
* Description   :  Verify functionality of IntranetRestrictDeleleteChatterGroupMembership trigger.
************************************************************************************************/     
@isTest(seeAllData = true)
private class IntranetRestrictDelGroupMembershipTest {

    static testMethod void testUnsubcribeChatterGroupMembership() {
    	Id allVirginChatterGroupId;//Id of All Virgin America Chatter group
    	for(CollaborationGroup chatterGrp : [Select c.Name, c.Id From CollaborationGroup c where name='All Virgin America']){
				allVirginChatterGroupId = chatterGrp.Id;
			}
			if(allVirginChatterGroupId != null) {
				CollaborationGroupMember virginMember = [Select Id from CollaborationGroupMember where CollaborationGroupId =: allVirginChatterGroupId limit 1];
				Test.startTest();
					try {
						// Unsubcribe user form All virgin America group
						if(virginMember != null)
							delete virginMember;
					}catch (DmlException e) {
						//assert Error 
						//Trigger does not allow user to unsubscribe form all virgin america group
						system.assertNotEquals(e.getMessage(),'');
					}
				Test.stopTest();
			}
    }
}