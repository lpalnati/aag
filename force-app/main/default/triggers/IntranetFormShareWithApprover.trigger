/*****************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetCreateChatterGroupForCMSPages
* Date          :  March 15,2013
* Description   :  Share Form records to Approver when submitted for approval.            
******************************************************************************/
trigger IntranetFormShareWithApprover on Intranet_Form__c (after update,after insert) {
	  // Intranet_Form__Share is the "Share" table that was created when the
    // Organization Wide Default sharing setting was set to "Private".
    // Allocate storage for a list of Intranet_Form__Share records.
		List<Intranet_Form__c> formList = new List<Intranet_Form__c>();
		List<Intranet_Form__c> statusUpdateformList = new List<Intranet_Form__c>();
					
		for(Intranet_Form__c form : trigger.new) {
			if(form.Locked__c == true && (trigger.isInsert || trigger.newMap.get(form.Id).Locked__c != trigger.oldMap.get(form.Id).Locked__c)) {
				formList.add(form);
			}
		}
		
		if(!formList.isEmpty())
			IntranetTriggerUtil.createFormSharing(formList);
}