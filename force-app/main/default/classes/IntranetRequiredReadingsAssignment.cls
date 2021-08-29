/**
  * Apex Class: IntranetRequiredReadingsAssignment
  * Description: This class is used to manage user subscription for content.
  * Created By: Harshit Jain(Appirio Off)
  * Created Date: Jan 16, 2012
*/
public with sharing class IntranetRequiredReadingsAssignment {
	 public ContentVersion contentVersion {get; set;}  
	 public list<ContentVersion> contentList {get;set;} // Document list of selected group  
	 public List<SubscribeUserWrapper> subscribedUserList {get; set;} // Subscribe user list of selected document 
	 public List<SubscribeUserWrapper> searchingSubscribedUserList {get;set;} // search result of subscribed user list
	 public List<SubscribeUserWrapper> searchDefaultUsersList {get;set;} // Default user list
	 
	 
	 public Boolean isSearch {get;set;}  
   public Integer selectedPageNumber{get;set;} // Page number of Content table
   public IntranetPaginationUtility conPagination{get;set;}
   public Integer selectedSubUserPageNumber{get;set;} // Page number of subcribe user table
   public IntranetPaginationUtility subPagination{get;set;}
   public Integer selectedDefUserPageNumber{get;set;} // Page number of subcribe user table
   public IntranetPaginationUtility defPagination{get;set;}
	 public String selectedContentId {get;set;}
	 public String subscribeUserSearchText {get;set;}
	 public String defaultUserSearchText {get;set;}
	 
	 private Integer subscribedUserSearchingTableLimit {get;set;}
	 private static final list<String> NOT_INCLUDED_PROFILE_USERS = new List<String>{'Chatter External User','Chatter Free User','Chatter Moderator User'};
	 
	  
	 
	 //----------------------------------------------------------------------------------------------------------------------------------------
   // Constructure(initialization of member varibles) 
	 //----------------------------------------------------------------------------------------------------------------------------------------
	 public IntranetRequiredReadingsAssignment() {
	  contentVersion =  new ContentVersion();
	  contentList = new list<ContentVersion>();
	  subscribedUserList = new list<SubscribeUserWrapper>();
	  searchingSubscribedUserList = new List<SubscribeUserWrapper>();
	  searchDefaultUsersList = new List<SubscribeUserWrapper>();
	  isSearch= false;
	  for(Intranet_Config__c RRSetting : [Select i.Value__c, i.Name From Intranet_Config__c i where Name = 'Subscribed user searching table limit' limit 1]) {
			subscribedUserSearchingTableLimit = Integer.valueOf(RRSetting.Value__c);	  	
	  }
	 }
	 
 	 //----------------------------------------------------------------------------------------------------------------------------------------
   // Method to get list of all contents share with selected group on page.
	 //----------------------------------------------------------------------------------------------------------------------------------------
 	 public void getSelectedGroupContentList(){
 	 	List<ContentVersion> selectedGroupContent = new List<ContentVersion>();
	 	contentList.clear();
	 	conPagination = new IntranetPaginationUtility();
	 	selectedPageNumber = 1;
	 	subscribedUserList.clear();
	 	subPagination = new IntranetPaginationUtility();
	 	selectedSubUserPageNumber = 1;
	 	for(ContentVersion contentVersion : [Select c.Id, c.Title, Team_Category__c, c.Start_Date__c, c.Required_Readings__c, c.End_Date__c, c.Due_Date__c 
	 																				 From ContentVersion c
	 																				Where Team__c =: contentVersion.Team__c
	 																				  And Published__c = true
	 																					And Required_Readings__c = true]){
			selectedGroupContent.add(contentVersion);
		}
		if(selectedGroupContent.size() > 0) {
			conPagination.pageSize = 5;
			List<Object> tempList = conPagination.setPagination(selectedGroupContent);
			contentList = getWrapperList(tempList);
		}
	 }
	 
	 //----------------------------------------------------------------------------------------------------------------------------------------
   // Filter content list based on selected Team categories
	 //----------------------------------------------------------------------------------------------------------------------------------------
	 public void getfilteredContentList() {
	 	List<ContentVersion> selectedGroupContent = new List<ContentVersion>();
	 	contentList.clear();
	 	conPagination = new IntranetPaginationUtility();
	 	selectedPageNumber = 1;
	 	subscribedUserList.clear();
	 	subPagination = new IntranetPaginationUtility();
	 	selectedSubUserPageNumber = 1;
	 	for(ContentVersion contentVersion : [Select c.Id, c.Title, Team_Category__c, c.Start_Date__c, c.Required_Readings__c, c.End_Date__c, c.Due_Date__c 
	 																				 From ContentVersion c
	 																				Where Team__c =: contentVersion.Team__c
	 																				  And Published__c = true
	 																				  And Team_Category__c =: contentVersion.Team_Category__c
	 																					And Required_Readings__c = true]){
			selectedGroupContent.add(contentVersion);
		}
		if(selectedGroupContent.size() > 0) {
			conPagination.pageSize = 5;
			List<Object> tempList = conPagination.setPagination(selectedGroupContent);
			contentList = getWrapperList(tempList);
		}
	 }
 	 
 	 //----------------------------------------------------------------------------------------------------------------------------------------
   // Method to get list of all subscribed users of selected content on page.
	 //----------------------------------------------------------------------------------------------------------------------------------------	
	 public void getSubscribeUserList(){
	 	List<SubscribeUserWrapper> selectedContentRRWrapperList = new List<SubscribeUserWrapper>();	
	 	isSearch = false;
	 	selectedContentRRWrapperList.clear();
	 	subscribedUserList.clear();
	 	subPagination = new IntranetPaginationUtility();
	 	selectedSubUserPageNumber = 1;
	 	for(Intranet_Required_Reading__c IntranetRR : [Select i.User_ID__r.Name,i.User_ID__r.Email, i.User_ID__c, i.Name, i.Id, i.ContentVersionID__c, i.Complete_Date__c 
	 																				 					 From Intranet_Required_Reading__c i
	 																				 					 Where ContentVersionID__c = : selectedContentId]){
			selectedContentRRWrapperList.add(new SubscribeUserWrapper(true, IntranetRR, null));
		}
 	  if(selectedContentRRWrapperList.size() > 0) {
			subPagination.pageSize = 5;
			List<Object> tempList = subPagination.setPagination(selectedContentRRWrapperList);
			subscribedUserList = getSubUserWrapperList(tempList);
	  }
   }
   
   //----------------------------------------------------------------------------------------------------------------------------------------
   // Method to search user in subscribed user list. 
	 //---------------------------------------------------------------------------------------------------------------------------------------- 
	 public PageReference searchSubscribeUser() {
		if(subscribeUserSearchText != '' && subscribeUserSearchText != null) {
			isSearch = true;
			searchingSubscribedUserList.clear();
			for(List<Object> outerList : subPagination.customPaginationList) {
					for(Object  subUserWrapper : outerList){
						if((((SubscribeUserWrapper)subUserWrapper).RRRecords.User_ID__r.Name).containsIgnoreCase(subscribeUserSearchText) && searchingSubscribedUserList.size() <= subscribedUserSearchingTableLimit){
		 					searchingSubscribedUserList.add(((SubscribeUserWrapper)subUserWrapper));
		 				}
					}
			}
		}else{
			isSearch = false;
			searchingSubscribedUserList.clear();		
		}
		return null;
	 }
 	 
 	 //----------------------------------------------------------------------------------------------------------------------------------------
   // Method to search users 
	 //----------------------------------------------------------------------------------------------------------------------------------------	
	 public void searchDefaultUsers() {
	 	list<SubscribeUserWrapper> defaultUserList = new list<SubscribeUserWrapper>();
	 	defaultuserList.clear();
	 	defPagination = new IntranetPaginationUtility();
	 	selectedDefUserPageNumber = 1;
	 	set<Id> subscribedUsersIds = new set<Id>();
	 	for(List<Object> outerList : subPagination.customPaginationList) {
			for(Object  subUserWrapper : outerList){
	 			subscribedUsersIds.add(((SubscribeUserWrapper)subUserWrapper).RRRecords.User_ID__c);
	 		}
	 	}	
	 	String query = 'Select Id, Name, Email From User where Name like \'%'+String.escapeSingleQuotes(defaultUserSearchText)+'%\'';
	 	for(User user:Database.query(query + 'AND Id NOT IN : subscribedUsersIds AND Profile.Name NOT IN:NOT_INCLUDED_PROFILE_USERS limit 100')){
	 		defaultuserList.add(new SubscribeUserWrapper(false,null,user));		
	 	}
	 	if(defaultuserList.size() > 0) {
			defPagination.pageSize = 5;
			List<Object> tempList = defPagination.setPagination(defaultuserList);
			searchDefaultUsersList = getDefUserWrapperList(tempList);
	  }else{
	  	searchDefaultUsersList.clear();
	  }
	 }
   
   //----------------------------------------------------------------------------------------------------------------------------------------
   // Method to unsubscribe users form selected document
	 //----------------------------------------------------------------------------------------------------------------------------------------
	 public void unsubscribeUser() {
	 	list<Intranet_Required_Reading__c> unsubcribeList = new list<Intranet_Required_Reading__c>();
	 	for(List<Object> outerList : subPagination.customPaginationList) {
			for(Object  subUserWrapper : outerList){
		 		if(((SubscribeUserWrapper)subUserWrapper).isSubscribe == false){
		 			unsubcribeList.add(((SubscribeUserWrapper)subUserWrapper).RRRecords);
		 		}
	 		}
	 	}
 		if(unsubcribeList.size() > 0) {
 			delete unsubcribeList;
 			getSubscribeUserList();
 		}
 	}
 
 	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to subscribe users for selected document
	//----------------------------------------------------------------------------------------------------------------------------------------
	public void subscribeUser() {
	 list<Intranet_Required_Reading__c> subscribeUserList = new list<Intranet_Required_Reading__c>();
	 Intranet_Required_Reading__c rrReading;
	 ContentVersion contentVersion;
	 	for(List<Object> outerList : conPagination.customPaginationList) {
			for(Object  conVer : outerList){
				if(((ContentVersion)conVer).Id == selectedContentId) {
					contentVersion = ((ContentVersion)conVer);
				}
			}
	 	}	
	 Date dueDate = Date.newInstance(contentVersion.Due_Date__c.year(), contentVersion.Due_Date__c.month(),  contentVersion.Due_Date__c.day());	
	 for(SubscribeUserWrapper subWrapper : searchDefaultUsersList) {
	 	if(subWrapper.isSubscribe == true){
	 		rrReading = new Intranet_Required_Reading__c();
	 	 	rrReading.ContentVersionID__c = contentVersion.Id;
	 	 	rrReading.Due_Date__c = dueDate;
	 	 	rrReading.Name = contentVersion.Title;
	 	 	rrReading.User_ID__c = subWrapper.user.Id;
	 		subscribeUserList.add(rrReading);
	 	}
	 }
	 If(subscribeUserList.size() > 0) {
	 	insert subscribeUserList;
	 	searchDefaultUsersList.clear();
	 	getSubscribeUserList();
	 }
	}
 
 //Wrapper class to manage subscription of user with documents
 public class SubscribeUserWrapper {
 		public boolean isSubscribe{get;set;}
 		public Intranet_Required_Reading__c RRRecords {get;set;}
 		public User user {get;set;}
 		public SubscribeUserWrapper(boolean isSubscribe, Intranet_Required_Reading__c RRRecords, User user) {
 			this.isSubscribe = isSubscribe;
 			this.RRRecords = RRRecords;
 			this.user = user;
 		} 
 } 
 
 	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to cast object into content Version
	//----------------------------------------------------------------------------------------------------------------------------------------
  private List<ContentVersion> getWrapperList(List<Object> currentList) {
		contentList.clear();
		for(Object obj : currentList) {
			contentList.add((ContentVersion)obj);
		}
		return contentList;
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to get pagination list of contents
	//----------------------------------------------------------------------------------------------------------------------------------------
	public PageReference getList() {
		contentList = getWrapperList(conPagination.getPage(selectedPageNumber));
		return null;
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to cast object into wrapper object
	//----------------------------------------------------------------------------------------------------------------------------------------
	private List<SubscribeUserWrapper> getSubUserWrapperList(List<Object> currentList) {
		subscribedUserList.clear();
		for(Object obj : currentList) {
			subscribedUserList.add((SubscribeUserWrapper)obj);
		}
		return subscribedUserList;
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to get pagination list of subscribed user
	//----------------------------------------------------------------------------------------------------------------------------------------
	public PageReference getSubUserList() {
		subscribedUserList = getSubUserWrapperList(subPagination.getPage(selectedSubUserPageNumber));
		return null;
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to cast object into wrapper object
	//----------------------------------------------------------------------------------------------------------------------------------------
	private List<SubscribeUserWrapper> getDefUserWrapperList(List<Object> currentList) {
		searchDefaultUsersList.clear();
		for(Object obj : currentList) {
			searchDefaultUsersList.add((SubscribeUserWrapper)obj);
		}
		return searchDefaultUsersList;
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------------
  // Method to get pagination list of default user
	//----------------------------------------------------------------------------------------------------------------------------------------
	public PageReference getDefUserList() {
		searchDefaultUsersList = getDefUserWrapperList(defPagination.getPage(selectedDefUserPageNumber));
		return null;
	}
}