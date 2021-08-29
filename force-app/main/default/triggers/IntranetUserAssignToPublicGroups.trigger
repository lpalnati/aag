/*****************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetUserAssignToPublicGroups
* Date          :  March 22,2013
* Description   :  Assign users to All Virgin America public and chatter groups.
* Modified By   :  Ashish Sharma
* Modified Date :  31st October, 2014
* Ref.          :  T-330480 - Create trigger to create required reading assignments on insert of new user
* Modified By   :  Ashish Sharma
* Modified Date :  3rd November, 2014
* Ref.          :  T-330704 - Create trigger on user creation that adds user to appropriate public group
* Modified By   :  Rahul Mittal
* Modified Date :  9th Dec, 2014
* Ref.          :  T-338557 - To resolve MIXED_DML_OPERARION error while inserting user manually
******************************************************************************/
trigger IntranetUserAssignToPublicGroups on User (after insert, after update) {
    static final list<String> userLicense = new list<String>{'Salesforce','Salesforce Platform'};

	if(Trigger.isAfter && trigger.isInsert){
		list<CollaborationGroupMember> newChatterMembershipList = new list<CollaborationGroupMember>();
		set<Id> userIdsOfSalesforceLicense = new set<Id>();//Users from salesorce and salesforce platform
	  	set<Id> userLicenseIds = new Set<Id>();
	  	final Id allVirginChatterGroupId;

	  	//get id of all virgin America Chatter group
	  	for(CollaborationGroup chatterGrp : [Select c.Name, c.Id From CollaborationGroup c where name='All Virgin America']){
			allVirginChatterGroupId = chatterGrp.Id;
		}

	  	for(UserLicense license : [Select u.Id From UserLicense u where Name in:userLicense]) {
	  		userLicenseIds.add(license.Id);
	  	}

			//add new user to all virgin Chatter group
	  	if(allVirginChatterGroupId != null) {
		  	for(User usr : [Select Id from User Where Id in:Trigger.newMap.keySet() AND Profile.UserLicenseId in:userLicenseIds]) {
		  		userIdsOfSalesforceLicense.add(usr.Id);
		 			//newChatterMembershipList.add(new CollaborationGroupMember(MemberId = usr.id,CollaborationGroupId = allVirginChatterGroupId));
	 		}

			//Added by Rahul Mittal to resolve MIXED_DML_OPERARION error (T-338557)
	 		//insert membership
	 		IntranetAssignUserToGroups.assignToCollaborationGroupsOnInsert(userIdsOfSalesforceLicense, allVirginChatterGroupId);
	  	}

	  	/*//insert membership
	  	if(!newChatterMembershipList.isEmpty()) {
	       insert newChatterMembershipList;
	   	}*/

	   	//Add new users to All Virgin America Public group via future method
	   	if(!userIdsOfSalesforceLicense.isEmpty()) {
	   		IntranetAssignUserToGroups.assignToGroupsOnInsert(userIdsOfSalesforceLicense);
	   	}

	   	//Modified By Ashish Sharma for Creating RR assignments for new users
   		IntranetRRAssignmentTriggerHandler.createRRAssignment(trigger.new);

   		//Add new users to public group based on "User Division Group Configuration" custom setting
   		IntranetRRAssignmentTriggerHandler.createGroupMember(trigger.new, null);
   	}

   	if(Trigger.isAfter && trigger.isUpdate){
   		IntranetRRAssignmentTriggerHandler.createGroupMember(trigger.new, trigger.oldMap);
   	}
}