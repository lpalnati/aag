/*****************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetAssignUserToGroups
* Date          :  April 3,2013
* Description   :  Utility functions for intranet triggers
* Modified By   :  Rahul Mittal
* Modified Date :  9th Dec, 2014
* Ref.          :  T-338557 - To add assignToCollaborationGroupsOnInsert() method
******************************************************************************/
public without sharing class IntranetAssignUserToGroups {
	//Assign Users to All virgin America Public group
	@future
	public static void assignToGroupsOnInsert(Set<Id> userIds){
		list<GroupMember> allVirginGroupMembershipList = new list<GroupMember>();
  		final Id allVirginGroupId;

		//get id of all virgin America public group
  		for(Group allVirginGrp : [Select Id,Name From Group where Name = 'All Virgin America']){
			allVirginGroupId = allVirginGrp.Id;
		}


		//add new user to all virgin public group
  		if(allVirginGroupId != null) {
	  		for(Id userId : userIds) {
	  			allVirginGroupMembershipList.add(new GroupMember(UserOrGroupId = userId,GroupId = allVirginGroupId));
	 		}
  		}

		//insert membership
	  	if(!allVirginGroupMembershipList.isEmpty()) {
		  	if (Test.isRunningTest()) {
	  		 	System.runAs(new User(Id = Userinfo.getUserId())) {
		        	insert allVirginGroupMembershipList;
		      	}
	  		}else{
	      		 insert allVirginGroupMembershipList;
	      	}
		}
	}

	//Assign Users to All virgin America Collaboration group
	@future
	public static void assignToCollaborationGroupsOnInsert(Set<Id> userIds, Id allVirginChatterGroupId){
		list<CollaborationGroupMember> newChatterMembershipList = new list<CollaborationGroupMember>();

		//add new user to all virgin public group
  		for(Id userId : userIds) {
  			newChatterMembershipList.add(new CollaborationGroupMember(MemberId = userId, CollaborationGroupId = allVirginChatterGroupId));
 		}

		//insert membership
	  	if(!newChatterMembershipList.isEmpty()) {
	       insert newChatterMembershipList;
	   	}
	}
}