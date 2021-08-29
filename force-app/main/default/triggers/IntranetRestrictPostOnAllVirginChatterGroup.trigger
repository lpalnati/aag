/**********************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetRestrictPostOnAllVirginChatterGroup
* Date          :  March 28,2013
* Description   :  Restrict Intranet End Users to Post on All Virgin Chatter Group.
* Modified Date :  8th Dec, 2014
* Modified By   :  Rahul Mittal
* Purpose       :  Prevent users with profile Intranet End User from @mentioning public group @All Virgin America(T-338354)
***********************************************************************************/
trigger IntranetRestrictPostOnAllVirginChatterGroup on FeedItem (after insert) {
    static final Id allVirginChatterGroupId;//Id of All Virgin America Chatter group
    //Error msg will be shown to end users when they posted on All virgin chatter group
    static final String errorMsg = (Intranet_Config__c.getInstance('All_Virgin_Group_Feed_Error') != null) ?
                                                                  Intranet_Config__c.getInstance('All_Virgin_Group_Feed_Error').Value__c :
                                                                    'You are not allow to post in this group.';
    static map<Id,User> intranetEndUsersMap = new map<Id,User>([select Id From User where Profile.Name = 'Intranet End User']);

    for(CollaborationGroup chatterGrp : [Select c.Name, c.Id From CollaborationGroup c where name='All Virgin America']){
        allVirginChatterGroupId = chatterGrp.Id;
    }

    for(FeedItem feedItem : Trigger.new) {
        // add error if End user posted on All virgin america chatter group or posted on their chatter @mentioning @All Virgin America group
        if(intranetEndUsersMap.containsKey(feedItem.CreatedById)
                && (feedItem.ParentId == allVirginChatterGroupId
                        || (String.isNotBlank(feedItem.Body) && feedItem.Body.contains('@All Virgin America'))) ) {

                feedItem.addError(errorMsg);
        }
    }
}