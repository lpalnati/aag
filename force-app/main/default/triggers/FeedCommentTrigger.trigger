/**********************************************************************************
* Author        :  Rahul Mittal(Appirio offshore)
* Name          :  FeedCommentTrigger
* Date          :  9th Dec, 2014
* Description   :  Restrict Intranet End Users to reply @mentioning @All Virgin America group in posted chatter(T-338551)
***********************************************************************************/
trigger FeedCommentTrigger on FeedComment (after insert) {
    //Error msg will be shown to end users when they posted on All virgin chatter group
    static final String errorMsg = (Intranet_Config__c.getInstance('All_Virgin_Group_Feed_Error') != null) ?
                                                                  Intranet_Config__c.getInstance('All_Virgin_Group_Feed_Error').Value__c :
                                                                    'You are not allow to post in this group.';
    static map<Id,User> intranetEndUsersMap = new map<Id,User>([select Id From User where Profile.Name = 'Intranet End User']);


    for(FeedComment feedComment : Trigger.new) {
        //Add error if End user reply @mentioning @All Virgin America group in posted chatter
        if(intranetEndUsersMap.containsKey(feedComment.CreatedById)
                && (String.isNotBlank(feedComment.CommentBody) && feedComment.CommentBody.contains('@All Virgin America'))) {

                feedComment.addError(errorMsg);
        }
    }
}