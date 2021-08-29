/*******************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetCreateChatterGroupForCMSPages
* Date          :  March 02,2013
* Description   :  Create chatter group(if not exits) on CMSPage Insert
									 where(Create_Chatter_Group__c == true)             
*******************************************************************/
trigger IntranetCreateChatterGroupForCMSPages on Intranet_CMS_Page__c (after insert) {
	map<String, Intranet_CMS_Page__c> nameCMSPageMap = new map<String,Intranet_CMS_Page__c>();
	map<String, CollaborationGroup> namechatterGroupMap = new map<String,CollaborationGroup>();
	list<CollaborationGroup> newChateGroupList = new list<CollaborationGroup>(); 
	
	//Create list of all CMSPages where Create_Chatter_Group__c = true
	for(Intranet_CMS_Page__c cmsPage : trigger.new){
		if(cmsPage.Create_Chatter_Group__c == true) {
			nameCMSPageMap.put(cmsPage.Name,cmsPage);
		}
	}
	
	//Populate map of already exits chatter groups present in nameCMSPageMap
	for(CollaborationGroup chatterGroup : [Select Id,Name from CollaborationGroup where Name in:nameCMSPageMap.KeySet()]){
		namechatterGroupMap.put(chatterGroup.Name,chatterGroup);	
	}
	
	//Create list of new chatter groups if previously not exits
	for(String CMSPageName : nameCMSPageMap.KeySet()){
		if(!namechatterGroupMap.containsKey(CMSPageName)) {
			newChateGroupList.add(new CollaborationGroup(Name = CMSPageName,CollaborationType = 'public',description = 'All news and information related to '+CMSPageName));
		}
	}
	
	//insert list of chatter groups
	if(!newChateGroupList.isEmpty()){
		insert newChateGroupList;	
	}
}