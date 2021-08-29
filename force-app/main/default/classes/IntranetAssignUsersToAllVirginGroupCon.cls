/************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetAssignUsersToAllVirginGroupCon
* Date          :  April 3,2013
* Description   :  Provide funcationlity to add remaining user to All Virgin America
								:  public and chatter group          
*************************************************************************************/
public without sharing class IntranetAssignUsersToAllVirginGroupCon {
	public list<userMappingWrapper> userToAddPublicGroup{get;set;}//list of users needs to be added in all virgin public group
	public list<userMappingWrapper> userToAddChatterGroup{get;set;}//list of users needs to be added in all virgin chatter group 
	public IntranetPaginationUtility publicGroupPagination{get;set;}//pagination on users list needs to be added in all virgin public group
	public IntranetPaginationUtility chatterGroupPagination{get;set;}//pagination on users list needs to be added in all virgin chatter group
	public Integer selectedPageNumberPublic{get;set;}//selected page number on users list needs to be added in all virgin public group
	public Integer selectedPageNumberChatter{get;set;}//selected page number on users list needs to be added in all virgin chatter group
	set<Id> userLicenseIds = new Set<Id>();//id set of Salesforce and Salesforce Platform license
	transient map<Id,user> allUserMap{get;set;} //map of all user have salesforce
	static final list<String> userLicense = new list<String>{'Salesforce','Salesforce Platform'};
	Id allVirginPublicGroupId{get;set;}//id of all virgin america public group
	Id allVirginChatterGroupId{get;set;}//id of all virgin america chatter group
	
	
	/************************************************************************************
	* Initialization of public members
	*************************************************************************************/
  public IntranetAssignUsersToAllVirginGroupCon() {
  	userToAddPublicGroup = new list<userMappingWrapper>();
  	userToAddChatterGroup = new list<userMappingWrapper>();
  	
  	//fetch the ids salesforce licenses 
  	for(UserLicense license : [Select u.Id From UserLicense u where Name in:userLicense]) {
  		userLicenseIds.add(license.Id);
  	}
  	//fetch all active users have salesforce licenses 
		allUserMap = new map<Id,User>([Select name,Email,Profile.Name from user where Profile.UserLicenseId in:userLicenseIds and IsActive = true order by Name limit 50000]);
		getUsersNotInPublicGroup();
		getUsersNotInChatterGroup();
  }	
  
  
  /************************************************************************************
	* Populate list of all users not member of all virgin public group
	*************************************************************************************/
  private void getUsersNotInPublicGroup() {
  	list<userMappingWrapper> allusersToAddPublicGroup = new list<userMappingWrapper>();
 		set<Id> UsersAllVirginMembers = new set<Id>();
 		publicGroupPagination = new IntranetPaginationUtility();
 		selectedPageNumberPublic = 1;
		List<GroupMember> virginGroupMembers = [Select g.UserOrGroupId,g.GroupId From GroupMember g where Group.Name ='All Virgin America'];
		//populate id of all virgin public group
		if(virginGroupMembers.size() > 0) {
			allVirginPublicGroupId = virginGroupMembers.get(0).GroupId;
		}
		for(GroupMember grpMember : virginGroupMembers) {
	    UsersAllVirginMembers.add(grpMember.UserOrGroupId);
		}
		//distinct all users not a member of all virgin public group
		for(User user : allUserMap.values()) {
			if(!UsersAllVirginMembers.contains(user.Id)) {
				allusersToAddPublicGroup.add(new userMappingWrapper(user,false));	
			}
		}
		//add pagination on user list
		if(allusersToAddPublicGroup.size() > 0) {
			publicGroupPagination.pageSize = 10;
			List<Object> tempList = publicGroupPagination.setPagination(allusersToAddPublicGroup);
			userToAddPublicGroup = getNotPublicUserWrapperList(tempList);
		}
  }
  
  /************************************************************************************
	* Populate list of all users not member of all virgin chatter group
	*************************************************************************************/
  private void getUsersNotInChatterGroup() {
  	list<userMappingWrapper> allusersToAddChatterGroup = new list<userMappingWrapper>();
  	chatterGroupPagination = new IntranetPaginationUtility();
		selectedPageNumberChatter = 1;
  	set<Id> UsersVirginChatterMembers = new set<Id>();
		List<CollaborationGroupMember> virginChatterGroupMembers = [Select c.MemberId,c.CollaborationGroupId From CollaborationGroupMember c where CollaborationGroup.Name ='All Virgin America'];
		//populate id of all virgin chatter group
		if(virginChatterGroupMembers.size() > 0) {
			allVirginChatterGroupId = virginChatterGroupMembers.get(0).CollaborationGroupId;
		}
		for(CollaborationGroupMember grpMember : virginChatterGroupMembers) {
   	 UsersVirginChatterMembers.add(grpMember.MemberId);
		}
		//distinct all users not a member of all virgin chatter group
		for(User user : allUserMap.values()) {
			if(!UsersVirginChatterMembers.contains(user.Id)) {
				allusersToAddChatterGroup.add(new userMappingWrapper(user,false));	
			}
		}
		//add pagination on user list
		if(allusersToAddChatterGroup.size() > 0) {
			chatterGroupPagination.pageSize = 10;
			List<Object> tempList = chatterGroupPagination.setPagination(allusersToAddChatterGroup);
			userToAddChatterGroup = getNotChatterUserWrapperList(tempList);
		}
  }
  
  /************************************************************************************
	* Add users to All virgin America public group
	*************************************************************************************/
  public PageReference addToAllVirginPublicGroup() {
  	List<GroupMember> addToGroupList = new List<GroupMember>();
  	for(List<Object> outerList : publicGroupPagination.customPaginationList) {
  		for(Object wrapper : outerList){
  			if(((userMappingWrapper)wrapper).isSelected) {
  			addToGroupList.add(new GroupMember(UserOrGroupId = ((userMappingWrapper)wrapper).user.Id,GroupId = allVirginPublicGroupId));	
  			}
  		}
  	}
  	if(!addToGroupList.isEmpty()) {
  		try{
  			insert addToGroupList;
  		}catch(Exception e) {
  			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		   	return null;	
  		}
  	}
  	pageReference pg = new PageReference('/apex/IntranetAssignUsersToAllVirginGroup');
    pg.setRedirect(true);
   	return pg;
  }
  
  /************************************************************************************
	* Add users to All virgin America chatter group
	*************************************************************************************/
  public PageReference addToAllVirginChatterGroup() {
  	List<CollaborationGroupMember> addToGroupList = new List<CollaborationGroupMember>();
  	for(List<Object> outerList : chatterGroupPagination.customPaginationList) {
  		for(Object wrapper : outerList){
  			if(((userMappingWrapper)wrapper).isSelected) {
  				addToGroupList.add(new CollaborationGroupMember(MemberId = ((userMappingWrapper)wrapper).user.Id,CollaborationGroupId = allVirginChatterGroupId));	
  			}
  		}
  	}
  	if(!addToGroupList.isEmpty()) {
  		try{
  			insert addToGroupList;
  		}catch(Exception e) {
  			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		   	return null;	
  		}
  	}
  	pageReference pg = new PageReference('/apex/IntranetAssignUsersToAllVirginGroup');
    pg.setRedirect(true);
   	return pg;
  }
	
	//Wrapper class
	public class userMappingWrapper {
		public User user{get;set;}
		public Boolean isSelected{get;set;}
		
		public userMappingWrapper(User usr, Boolean isSelected){
			this.user = usr;
			this.isSelected = isSelected;
		}
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to cast object into wrapper object
	//----------------------------------------------------------------------------------------------------------------------------------------
	private List<userMappingWrapper> getNotPublicUserWrapperList(List<Object> currentList) {
		userToAddPublicGroup.clear();
		for(Object obj : currentList) {
			userToAddPublicGroup.add((userMappingWrapper)obj);
		}
		return userToAddPublicGroup;
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to get pagination list of subscribed user
	//----------------------------------------------------------------------------------------------------------------------------------------
	public PageReference getNotPublicUserList() {
		userToAddPublicGroup = getNotPublicUserWrapperList(publicGroupPagination.getPage(selectedPageNumberPublic));
		return null;
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to cast object into wrapper object
	//----------------------------------------------------------------------------------------------------------------------------------------
	private List<userMappingWrapper> getNotChatterUserWrapperList(List<Object> currentList) {
		userToAddChatterGroup.clear();
		for(Object obj : currentList) {
			userToAddChatterGroup.add((userMappingWrapper)obj);
		}
		return userToAddChatterGroup;
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to get pagination list of subscribed user
	//----------------------------------------------------------------------------------------------------------------------------------------
	public PageReference getNotChatterUserList() {
		userToAddChatterGroup = getNotChatterUserWrapperList(chatterGroupPagination.getPage(selectedPageNumberChatter));
		return null;
	}
}