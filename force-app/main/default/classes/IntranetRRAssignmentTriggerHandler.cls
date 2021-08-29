/*****************************************************************************
* Author        :  Ashish Sharma
* Name          :  IntranetRRAssignmentTriggerHandler
* Date          :  31st October, 2014
* Description   :  T-330480 - This trigger handler will create required reading 
                   assignments on insert of new user
* Modified By   :  Ashish Sharma
* Modified Date :  3rd November, 2014
* Ref.          :  T-330704 - Create trigger on user creation that adds user to appropriate public group
* Last Modified 25th Nov, 2014   Ashish Sharma, Alter trigger to allow users with profile of Intranet System Admin to run trigger(Ref - T-336376)
******************************************************************************/
public with sharing class IntranetRRAssignmentTriggerHandler {
	public static final String SYS_ADMIN_PROFILE = 'System Administrator';
	public static final String INTRANET_SYS_ADMIN_PROFILE = 'Intranet System Administrator';
	public static final String REGULAR_GROUP_TYPE = 'Regular';
	
	//This method will create RR Assignment Records for new Users
	public static void createRRAssignment(List<User> newUsers){
		try{
			List<Intranet_Required_Reading__c> rrAssignments;
	    	rrAssignments = new List<Intranet_Required_Reading__c>();
			
			for(ContentVersion contVer : [SELECT Id, Title, RR_Team__c, Due_Date__c
										  FROM ContentVersion WHERE Due_Date__c >=: DateTime.now()
										  AND Assign_Retroactively__c = true]){
										  	
				for(User u : newUsers){
					if(u.Division != null && contVer.RR_Team__c != null 
					   && contVer.RR_Team__c.contains(u.Division.trim()) && u.IsActive){
						rrAssignments.add(new Intranet_Required_Reading__c(ContentVersionID__c = contVer.Id, 
	  	 	  													   Due_Date__c = Date.valueOf(contVer.Due_Date__c),
	  	 	    												   Name = contVer.Title,
	  	     													   User_ID__c = u.Id,
	  	 														   RR_Teams__c = contVer.RR_Team__c));
					}
				}
			}
			
			if(rrAssignments.size() > 0){
				insert rrAssignments;
			}
		}catch(Exception e){
			System.debug(e.getMessage());
		}
	}
	
	//This method will add new users to public group based on 
	// "User Division Group Configuration" custom setting
	public static void createGroupMember(List<User> newUsers, Map<ID, User> oldMap){
		try{
			Set<ID> allowedProfileIds = new Set<ID>();
			
			for(Profile pro : [SELECT ID FROM Profile WHERE Name =: SYS_ADMIN_PROFILE 
							   OR Name =: INTRANET_SYS_ADMIN_PROFILE]){
				
				allowedProfileIds.add(pro.ID);
			}
			
			//This will run only when sys admin profile makes the insert or update
			if(allowedProfileIds.contains(Userinfo.getProfileId())){
				Map<String, String> divisionGroupNameMap = new Map<String, String>();
				
				for(User_Division_Group_Configuration__c userDivConfig : 
								User_Division_Group_Configuration__c.getall().values()){
					
					divisionGroupNameMap.put(userDivConfig.Name, userDivConfig.Group_Name__c);
				}
				
				
				if(divisionGroupNameMap.size() > 0){
					Map<String, ID> groupNameIdMap = new Map<String, ID>();
					for(Group grp : [SELECT ID, Name FROM Group WHERE 
									 Name IN : divisionGroupNameMap.values()
									 AND Type =: REGULAR_GROUP_TYPE]){
						groupNameIdMap.put(grp.Name, grp.ID);
					} 
					
					if(groupNameIdMap.size() > 0){
						Map<ID, ID> groupMemberIdMap = new Map<ID, ID>();
						List<GroupMember> userGroupMembers = new List<GroupMember>();
						Map<ID, ID> oldGrpMemberIdMap = new Map<ID, ID>();
						
						for(User user : newUsers){
							if((user.Division != null && user.Division != '') &&
							    ((oldMap == null) || (oldMap != null && user.Division != oldMap.get(User.Id).Division))){
								
								if(groupNameIdMap.get(divisionGroupNameMap.get(user.Division)) != null){
									
									if(oldMap == null){
										groupMemberIdMap.put(user.ID, groupNameIdMap.get(divisionGroupNameMap.get(user.Division)));
									}else{
										userGroupMembers.add(new GroupMember(GroupId = groupNameIdMap.get(divisionGroupNameMap.get(user.Division)), 
																		 	 UserOrGroupId = user.ID));
																		 	 
										oldGrpMemberIdMap.put(user.ID, groupNameIdMap.get(divisionGroupNameMap.get(oldMap.get(User.Id).Division)));
									}
								}
							}
						}
						
						if(groupMemberIdMap.size() > 0){
							insertUserGroupMember(groupMemberIdMap);
						}
						
						if(userGroupMembers.size() > 0){
							insert userGroupMembers;
						}
						
						
						// Remove the user from old group
						List<GroupMember> removeGroupMembers = new List<GroupMember>();
						
						for(GroupMember grpMem : [SELECT GroupId, UserOrGroupId FROM GroupMember
												  WHERE UserOrGroupId =: oldGrpMemberIdMap.keySet()]){
							if(oldGrpMemberIdMap.containsKey(grpMem.UserOrGroupId) &&
								oldGrpMemberIdMap.get(grpMem.UserOrGroupId) == grpMem.GroupId){
									
								removeGroupMembers.add(grpMem);	
							}
						}	
						
						if(removeGroupMembers.size() > 0){
							delete removeGroupMembers;
						}
					}
				}
			}	
		}catch(Exception e){
			System.debug(e.getMessage());
		}	
	} 
	
	@future
	public static void insertUserGroupMember(Map<ID, ID> groupMemberIdMap){
		if(groupMemberIdMap.size() > 0){
			List<GroupMember> userGroupMembers = new List<GroupMember>();
			
			for(ID memberId : groupMemberIdMap.keySet()){
				userGroupMembers.add(new GroupMember(GroupId =  groupMemberIdMap.get(memberId), 
													 UserOrGroupId =memberId));
			}
			
			if(userGroupMembers.size() > 0 && !test.isRunningTest()){
				insert userGroupMembers;
			}
		}
	}
}