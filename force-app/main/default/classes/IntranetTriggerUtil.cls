/*****************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetCreateChatterGroupForCMSPages
* Date          :  March 15,2013
* Description   :  Utility functions for intranet triggers             
******************************************************************************/
public without sharing class IntranetTriggerUtil {
	
	/******************************************************************
	*Share Form records to Approver when submitted for approval.
	*******************************************************************/
	public static void createFormSharing(List<Intranet_Form__c> forms) {
		List<Intranet_Form__Share> formShareList = new list<Intranet_Form__Share>();
		//set of all form ids being submitted for approval
		Set<Id> formIds = new Set<Id>();
		//set of all queues used for approval
		Set<Id> queueIds = new Set<Id>();
		map<Id,Group> queueIdMap;
		//For each form record separate out which is submitted for approval and thier approver(if queue) 
		for(Intranet_Form__c form : forms) {
			if(form.Approver__c.startsWithIgnoreCase('00G')) {
				queueIds.add(form.Approver__c);
			}	
			formIds.add(form.id);
		}
		
		//fetch members of all queue. 
		if(!queueIds.isEmpty()) 
			queueIdMap = new map<Id,Group>([Select g.Name, g.Id, (Select UserOrGroupId From GroupMembers) From Group g where id in :queueIds]);
			
		map<Id,Set<Id>> sharedRecordMap = populatePreviousSharingRecord(formIds);
		
		//For each of the form records being submitted for approval, do the following:
    for(Intranet_Form__c form : forms){
			if(form.Approver__c.startsWithIgnoreCase('00G')) {
				//create separate sharing record for each user or group if approver is queue. 
				for(GroupMember grpMember : queueIdMap.get(form.Approver__c).GroupMembers) {
						if(!sharedRecordMap.get(form.Id).contains(grpMember.UserOrGroupId))
							formShareList.add(createShareRecord(form.id,grpMember.UserOrGroupId));
				}
			}else{
				if(!sharedRecordMap.get(form.Id).contains(form.Approver__c))
					formShareList.add(createShareRecord(form.id,form.Approver__c));
			}
		}
		
		// Insert all of the newly created Share records  
    if(!formShareList.isEmpty()) {
    	insert formShareList;
    }
  }
  
  /***********************************************************************************
	* Mantain a map of submitted forms and set of their previously shared user or groups
	************************************************************************************/
  static map<Id,Set<Id>> populatePreviousSharingRecord(Set<Id> formIds){
  	//Map of all sharing records of forms 
		map<Id,Set<Id>> sharedRecordMap = new map<Id,Set<Id>>();
		for(Intranet_Form__Share shareRec : [Select i.UserOrGroupId, i.ParentId, i.AccessLevel From Intranet_Form__Share i where ParentId in:formIds]){
			if(sharedRecordMap.containsKey(shareRec.ParentId)){
				sharedRecordMap.get(shareRec.ParentId).add(shareRec.UserOrGroupId);
			}else{
				sharedRecordMap.put(shareRec.ParentId,new set<Id>{shareRec.UserOrGroupId});
			}
		}
		return sharedRecordMap;
  }
	
	/********************************************************
	*Create Sharing records for Intranet_form
	*********************************************************/
	static Intranet_Form__Share createShareRecord(Id formId,Id UserOrGroupId) {
		Intranet_Form__Share approverShare = new Intranet_Form__Share();
		approverShare.ParentId = formId;
		approverShare.UserOrGroupId = UserOrGroupId;
		approverShare.AccessLevel = 'edit';
		return approverShare;
  }
}