/*******************************************************************
* Author        :  Virendra
* Name          :  Content_Sharing_Required_Readings
* Date          :  January  09,2013
* Description   :  Support Class for IntranetContents_ShareWithOtherLibrary trigger to Share the records for Required reading on Contents
* LastModifiedBy : Harshit Jain
* RelateTo       : RR validations & Clean Up(T-112257)         
* Modified By  : Ashish Sharma
* Modified Date : 29th October, 2014
* Ref.          : T-329194             
*******************************************************************/
public with sharing class Content_Sharing_Required_Readings {

  public static void createRequiredReadingSharRecords(Map<Id, ContentVersion> oldMap, Map<Id,ContentVersion> newMap){
  	 	list<ContentVersion> createNewRequiredReading = new list<ContentVersion>();
  	 	map<Id,Set<Id>> mapRRContentIdUser = new map<Id,set<Id>>();
  	 	map<Id,Intranet_Required_Reading__c> requiredReadingMap = new map<Id,Intranet_Required_Reading__c>();
  	 	list<Intranet_Required_Reading__c> createNewIntranetReqReadings = new list<Intranet_Required_Reading__c>();
  	 	Set<Intranet_Required_Reading__c> deleteIntranetReqReadings = new Set<Intranet_Required_Reading__c>();
  	 	 
  	 	for(Intranet_Required_Reading__c rr : [Select i.User_ID__c, i.Name, i.Id, i.ContentVersionID__c From Intranet_Required_Reading__c i where ContentVersionID__c in: newMap.KeySet()]){
  	 		/*
  	 			If RR is false then delete all RR custom records.
  	 		*/
  	 		if(newMap.get(rr.ContentVersionID__c).Required_Readings__c == false && oldMap.get(rr.ContentVersionID__c).Required_Readings__c){
					deleteIntranetReqReadings.add(rr);													
				}else {
					/*
						populate map of content and setof related RR users.
					*/
	  	 		if(mapRRContentIdUser.containsKey(rr.ContentVersionID__c)){
	            mapRRContentIdUser.get(rr.ContentVersionID__c).add(rr.User_Id__c);
	        }else{
	            Set<Id> userIds = new Set<Id>();
	            userIds.add(rr.User_Id__c);
	            mapRRContentIdUser.put(rr.ContentVersionID__c,userIds);
	        }
	        requiredReadingMap.put(rr.User_ID__c,rr);
  	 		} 	
  	 	}
			
			
			/*
			Populated all selected RR team names
			*/
			set<String> teams = new set<String>();  	 	 
  	  for(ContentVersion ver : newMap.Values()) {
  	  	if(ver.RR_Team__c != null) {
  	  		for(String team : (ver.RR_Team__c).split(';',0)){
  	  			teams.add(team);
  	  		}
  	  	}		
  	  }
  	  /*
  	   Retrive the content Versions to determine to be share with RR team users or 
  	   all Virgin america group users  
  	 	*/
	  	 Map<String,Id> groupByName = new Map<String,Id>();
	     Map<Id,Set<Id>> groupMembers = new Map<Id,Set<Id>>();
	 	 	 for(Group gp:[Select Id,Name From Group where name ='All Virgin America' or name in:teams]){
		     	groupByName.put(gp.Name,gp.Id);
	     }
	  	 
	  	 
	  	 /*
	  	   All users from the Group All Virgin Amercia and selected Teams 
	  	 */
	  	 groupMembers = getUsersFromGroups(groupByName.values());
	  	 
	  	Set<Id> subcribedUserIds;    
	  	for(ContentVersion ver : newMap.Values()){
	  		subcribedUserIds = new Set<Id>();
	  	 	/*
	  	 	 Check if due date is not Null in case no need to create RR
	  	 	*/
	  	 	if(ver.Due_Date__c != null){
	  	 		/*
	  	 			Check if content already has RR records, then update RR records 
	  	 		*/
	  	 		if(mapRRContentIdUser.size() > 0) {
		  	 	/*
		       	 Check if records to be create for All Virgin america group RR and assign Required Reading record for 
		       	 each user of Virgin america group 
		     	 */
		     	  Date dueDate = Date.newInstance(ver.Due_Date__c.year(), ver.Due_Date__c.month(),  ver.Due_Date__c.day());	
		        if(ver.Required_Readings_for_all_users__c && (ver.Required_Readings_for_all_users__c != oldMap.get(ver.Id).Required_Readings_for_all_users__c)){
		         	Id gId = groupByName.get('All Virgin America');
		         	if(groupMembers.containsKey(gId)){
		         	   for(id vUserId:groupMembers.get(gId)){
		         	   	if(!(mapRRContentIdUser.containsKey(ver.Id) && mapRRContentIdUser.get(ver.Id).contains(vUserId))) {
									 	Intranet_Required_Reading__c rrReading = new Intranet_Required_Reading__c();
		  	 	 		  	 	rrReading.ContentVersionID__c = ver.Id;
  		  	 	  			rrReading.Due_Date__c = dueDate;
	    	  	 	 			rrReading.Name = ver.Title;
		      	 				rrReading.User_ID__c = vUserId;
		      	 				rrReading.RR_Teams__c = ver.RR_Team__c;
		  	 	    			createNewIntranetReqReadings.add(rrReading);						         	   	
		         	    }
		  	 		   }
		         	}
		         }/*
		       	   Check if records to be created and assign Required Reading record for 
		       	   each user of team groups 
		       	  */
		       	 else if(ver.Required_Readings__c && ver.RR_Team__c != null && ver.Required_Readings_for_all_users__c != true){
		       	 /*
		       	  Check if records is new and assign Required Reading record for 
		       	  each user of team groups
		       	 */
		     	 	if(oldMap.get(ver.Id).RR_Team__c == null && oldMap.get(ver.Id).Required_Readings_for_all_users__c == false) {
		     	 	 for(String groupName : (ver.RR_Team__c).split(';',0)) {
		     	 	  Id gId = groupByName.get(groupName);
							if(groupMembers.containsKey(gId)){
							 for(id vUserId:groupMembers.get(gId)){  
					         if(!subcribedUserIds.contains(vUserId)) {
						  			 Intranet_Required_Reading__c rrReading = new Intranet_Required_Reading__c();
					   	  		 rrReading.ContentVersionID__c = ver.Id;
					  	 	  	 rrReading.Due_Date__c = dueDate;
					  	 	 		 rrReading.Name = ver.Title;
					  	 			 rrReading.User_ID__c = vUserId;
					  	 			 rrReading.RR_Teams__c = ver.RR_Team__c;
					  	 			 subcribedUserIds.add(vUserId);
					  	 			 createNewIntranetReqReadings.add(rrReading);					         	
					         	}
					  	 		 }
									}
		     	 			}		
		     	 		}
		     	 		/*
		     	 			check if RR is already created for all user then delete all those records 
		     	 			for which groups are not selected  
		     	 		*/
		     	 		else if(oldMap.get(ver.Id).Required_Readings_for_all_users__c == true) {
		     	 			for(String groupName : (ver.RR_Team__c).split(';',0)) {
			     	 			Id gId = groupByName.get(groupName);
									if(groupMembers.containsKey(gId)){
										 subcribedUserIds.addAll(groupMembers.get(gId));
									}
		     	 			}	
								for(Id assignedUserId : mapRRContentIdUser.get(ver.Id)) {
										if(!subcribedUserIds.contains(assignedUserId)) {
											deleteIntranetReqReadings.add(requiredReadingMap.get(assignedUserId));
										}										
								}
		     	 		 }
		     	 		 /*
		     	 			check if RRTeam value has been changed then update RR Record based on selected groups
		     	 		 */
		     	 		 else if(oldMap.get(ver.Id).RR_Team__c != null && (oldMap.get(ver.Id).RR_Team__c != ver.RR_Team__c)) {
		     	 		   for(Id assignedUserId : mapRRContentIdUser.get(ver.Id)) {
										deleteIntranetReqReadings.add(requiredReadingMap.get(assignedUserId));									
								 }
			     	 		 for(String groupName : (ver.RR_Team__c).split(';',0)) {
			     	 			 Id gId = groupByName.get(groupName);
									 if(groupMembers.containsKey(gId)){
					         for(id vUserId:groupMembers.get(gId)){  
					         	if(!subcribedUserIds.contains(vUserId)) {
										 Intranet_Required_Reading__c rrReading = new Intranet_Required_Reading__c();
					  	 	 		 rrReading.ContentVersionID__c = ver.Id;
					  	 	  	 rrReading.Due_Date__c = dueDate;
					  	 	 		 rrReading.Name = ver.Title;
					  	 			 rrReading.User_ID__c = vUserId;
					  	 			 rrReading.RR_Teams__c = ver.RR_Team__c;
					  	 			 subcribedUserIds.add(vUserId);
					  	 			 createNewIntranetReqReadings.add(rrReading);					         	
					         	}
					  	 		 }
									}
			     	 		}	
							}
		     	 	}
	  	 			}else {
	  	 					/*
	       	   		Check if records to be create for All Virgin america group RR and assign Required Reading record for 
	       	   		each user of Virgin america group 
				     	 */
				     	  Date dueDate = Date.newInstance(ver.Due_Date__c.year(), ver.Due_Date__c.month(),  ver.Due_Date__c.day());	
				         if(ver.Required_Readings_for_all_users__c){
				         	Id gId = groupByName.get('All Virgin America');
				         	if(groupMembers.containsKey(gId)){
				         	   for(id vUserId:groupMembers.get(gId)){
				         	   	   if(vUserId == '005V00000010HWs'){
				         	   	   }
				  	 			   	Intranet_Required_Reading__c rrReading = new Intranet_Required_Reading__c();
				  	 	 		   	rrReading.ContentVersionID__c = ver.Id;
				  	 	  			rrReading.Due_Date__c = dueDate;
				  	 	 			  rrReading.Name = ver.Title;
				  	 				  rrReading.User_ID__c = vUserId;
				  	 				  rrReading.RR_Teams__c = ver.RR_Team__c;
				  	 				  createNewIntranetReqReadings.add(rrReading);
				  	 		   }
				         	}
				         }/*
				       	   Check if records to be created and assign Required Reading record for 
				       	   each user of team groups 
				     	 */else if(ver.Required_Readings__c && ver.RR_Team__c != null){
				     	 		for(String groupName : (ver.RR_Team__c).split(';',0)) {
				     	 			Id gId = groupByName.get(groupName);
										if(groupMembers.containsKey(gId)){
							         for(id vUserId:groupMembers.get(gId)){  
							         	if(!subcribedUserIds.contains(vUserId)) {
												 Intranet_Required_Reading__c rrReading = new Intranet_Required_Reading__c();
							  	 	 		 rrReading.ContentVersionID__c = ver.Id;
							  	 	  	 rrReading.Due_Date__c = dueDate;
							  	 	 		 rrReading.Name = ver.Title;
							  	 			 rrReading.User_ID__c = vUserId;
							  	 			 rrReading.RR_Teams__c = ver.RR_Team__c;
							  	 			 subcribedUserIds.add(vUserId);
							  	 			 createNewIntranetReqReadings.add(rrReading);					         	
							         	}
							  	 		 }
										}
				     	 		}
				        }
	  	 			} 
		      }
	  	 	}
	  	 	
	  	 if(!deleteIntranetReqReadings.isEmpty()) {
	  	 	list<Intranet_Required_Reading__c> deleteRRList = new list<Intranet_Required_Reading__c>();
	  	 	deleteRRList.addAll(deleteIntranetReqReadings);
	  	 	delete deleteRRList;
	  	 }
	  	 if(!createNewIntranetReqReadings.isEmpty()) {
	  	 	insert createNewIntranetReqReadings;
	  	 }
  }	
  
  /*
  	Method to get all users of selected groups. 
  */
  public static Map<Id,Set<Id>> getUsersFromGroups(List<Id> groupIds)
	{
		Map<Id,Set<Id>> groupMembers = new Map<Id,Set<Id>>();		
		// Get user and group key prefixes so we can test to see what the UserOrGroupId field contains
		String userType = Schema.SObjectType.User.getKeyPrefix();
		String groupType = Schema.SObjectType.Group.getKeyPrefix();
		
		// Loop through all group members in a group
		for (GroupMember gMember : [Select Id,GroupId, UserOrGroupId From GroupMember Where GroupId in :groupIds])
		{
			// If the user or group id is a user
			if (((String)gMember.UserOrGroupId).startsWith(userType))	{
				if(groupMembers.containsKey(gMember.GroupId)){
	  	 	  			groupMembers.get(gMember.GroupId).add(gMember.UserOrGroupId);
					}else{
			   		Set<Id> users = new Set<Id>();
			   		users.add(gMember.UserOrGroupId);
			   		groupMembers.put(gMember.GroupId,users);
				}		
			}
			// If the user or group id is a group
			else if (((String)gMember.UserOrGroupId).startsWith(groupType)) {
				if(groupMembers.containsKey(gMember.GroupId)){
								Map<Id,Set<Id>> InternalgroupMembers = getUsersFromGroups(new List<Id>{gMember.UserOrGroupId});
	  	 	  			groupMembers.get(gMember.GroupId).addAll(InternalgroupMembers.get(gMember.UserOrGroupId));
					}else{
			   		Set<Id> users = new Set<Id>();
			   		Map<Id,Set<Id>> InternalgroupMembers = getUsersFromGroups(new List<Id>{gMember.UserOrGroupId});
			   		users.addAll(InternalgroupMembers.get(gMember.UserOrGroupId));
			   		groupMembers.put(gMember.GroupId,users);
				}	
			}
		}
		//Return map of groups and list of assinged users.
		return groupMembers;
	}
	
}