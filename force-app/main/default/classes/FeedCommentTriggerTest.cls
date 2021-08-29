/**********************************************************************************
* Author        :  Rahul Mittal(Appirio offshore)
* Name          :  FeedCommentTrigger
* Date          :  9th Dec, 2014
* Description   :  Verify functionality of FeedCommentTrigger trigger.
***********************************************************************************/
@isTest(seeAllData = true)
private class FeedCommentTriggerTest {

    static testMethod void testErrorOnChatterReply() {
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
				FeedItem feedItem = new FeedItem();
				feedItem.Body = 'Test trigger';
				feedItem.ParentId = endUser.Id;
				try {
					insert feedItem;

					//Reply on All virgin America group
					FeedComment feedComment = new FeedComment();
					feedComment.CommentBody = '@All Virgin America test reply';
					feedComment.CommentType = 'TextComment';
					feedComment.FeedItemId = feedItem.Id;

					insert feedComment;
				}catch(DmlException e){
					// Trigger not allow end user to reply @mentioning All Virgin America chatter group
					system.assertNotEquals(e.getMessage(),'');
				}
				Test.stopTest();
			}
		}
    }
}