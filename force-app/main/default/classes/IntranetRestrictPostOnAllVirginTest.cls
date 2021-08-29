/**********************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetRestrictPostOnAllVirginTest
* Date          :  March 28,2013
* Description   :  Verify functionality of IntranetRestrictPostOnAllVirginChatterGroup trigger.
* Modified 		:  Dec 8th, 2014 Rahul Mittal - Increase test coverage according to T-338354 task
************************************************************************************************/
@isTest(seeAllData = true)
private class IntranetRestrictPostOnAllVirginTest {

    static testMethod void testErrorOnPost() {
    	Id endUserProfileId;
    	Id allVirginChatterGroupId;//Id of All Virgin America Chatter group
    	User endUser;
    	for(Profile profile : [select Id from Profile where Name = 'Intranet End User' limit 1]) {
    		endUserProfileId = profile.Id;
    	}
    	//Create Intranet End user
    	if(endUserProfileId != null) {
    		endUser = TestUtil.createUser(false);
    		endUser.ProfileId = endUserProfileId;
    		insert endUser;
    	}
    	//Fetch Id of All Virgin America Group
		for(CollaborationGroup chatterGrp : [Select c.Name, c.Id From CollaborationGroup c where name='All Virgin America']){
			allVirginChatterGroupId = chatterGrp.Id;
		}
		//If All virgin group present then start test
		if(endUser != null && allVirginChatterGroupId != null) {
			System.runAs(endUser) {
				Test.startTest();
				//Post on All virgin America group
				FeedItem feedItem = new FeedItem();
				feedItem.Body = 'Test trigger';
				feedItem.ParentId = allVirginChatterGroupId;
				try {
					insert feedItem;
				}catch(DmlException e){
					// Trigger not allow end user to post on All Virgin America chatter group
					system.assertNotEquals(e.getMessage(),'');
				}
				Test.stopTest();
			}
		}
    }

     static testMethod void testErrorWhileMentioningGroup() {
    	Id endUserProfileId;
    	Id allVirginChatterGroupId;//Id of All Virgin America Chatter group
    	User endUser;
    	for(Profile profile : [select Id from Profile where Name = 'Intranet End User' limit 1]) {
    		endUserProfileId = profile.Id;
    	}
    	//Create Intranet End user
    	if(endUserProfileId != null) {
    		endUser = TestUtil.createUser(false);
    		endUser.ProfileId = endUserProfileId;
    		insert endUser;
    	}

		//If All virgin group present then start test
		if(endUser != null && allVirginChatterGroupId != null) {
			System.runAs(endUser) {
				Test.startTest();
				//Post on All virgin America group
				FeedItem feedItem = new FeedItem();
				feedItem.Body = '@All Virgin America posting here with the group.';
				feedItem.ParentId = endUser.Id;
				try {
					insert feedItem;
				}catch(DmlException e){
					// Trigger not allow end user to post on All Virgin America chatter group
					system.assertNotEquals(e.getMessage(),'');
				}
				Test.stopTest();
			}
		}
    }
}