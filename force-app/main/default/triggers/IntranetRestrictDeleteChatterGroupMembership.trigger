/*****************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetUserAssignToPublicGroups
* Date          :  March 26,2013
* Description   :  Restrict users to unsubscribe from All Virgin Chatter Group.
******************************************************************************/
trigger IntranetRestrictDeleteChatterGroupMembership on CollaborationGroupMember (before delete) {
	static final Id VirginChatterGroupId;//Id of All Virgin America Chatter group
	//Error msg will be shown to all users when they try to leave All virgin chatter group 
	static final String errorMsg = (Intranet_Config__c.getInstance('All_Virgin_Group_Unsubscription_Error') != null) ? 
																  Intranet_Config__c.getInstance('All_Virgin_Group_Unsubscription_Error').Value__c :
																	'You are not allow to unsubscribe from All Virgin America Chatter Group.'; 
	for(CollaborationGroup chatterGrp : [Select c.Name, c.Id From CollaborationGroup c where name='All Virgin America']){
		VirginChatterGroupId = chatterGrp.Id;
	}
	for(CollaborationGroupMember grpMember : trigger.old) {
		if(grpMember.CollaborationGroupId == VirginChatterGroupId) {
			//add error message
			grpMember.addError(errorMsg);
		}
	}
}