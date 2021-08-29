/**********************************************************************************
  Apex Class: IntranetFormListAdminController
  CreatedBy : Harshit Jain
  CreatedDate : Feb 19, 2012
  Description: This class is used to show detail of selected form type create by content admin.
**********************************************************************************/
public with sharing class IntranetFormListDetailController {
	public IntranetFormList__c intranetformType {get;set;}
	public Boolean isEdit{get;set;}
	public String approver{get;set;}
	private map<Id,IntranetFormListFields__c> formFieldMap{get;set;}
	public list<User> selectedUsers {get;set;}
	
	/**********************************************************************************
  * initialization
	**********************************************************************************/
	public IntranetFormListDetailController() {
		formFieldMap = new map<Id, IntranetFormListFields__c>();
		//Decide either page open in edit mode or detatil mode 
		isEdit = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isEdit'));
		for(IntranetFormList__c form : [Select Name, Id, Active__c,Select_Approver__c,Selected_Users__c,Skip_Reviewer__c,Form_Category__c, 
																	 (Select Id, Field_API_Name__c, Sequence_Order__c,Required__c
  																	  From IntranetFormListFields__r order by Sequence_Order__c) 
    																	From IntranetFormList__c where Id = :ApexPages.currentPage().getParameters().get('formId')]) {
			for(IntranetFormListFields__c field: form.IntranetFormListFields__r) {
				formFieldMap.put(field.Id,field);
			}
			//Clone child records of selected field to track weather it is updated or not
			formFieldMap = formFieldMap.deepClone();  																					
			intranetformType = form;
		}	
		if(intranetformType.Select_Approver__c.startsWithIgnoreCase('00G')) {
			approver = [Select Name From Group where id =:intranetformType.Select_Approver__c].Name;	
		}else{
			approver = [select Name from User where id =:intranetformType.Select_Approver__c].Name;
		}
		populateSelectedUser();
	}
	
	private void populateSelectedUser() {
		selectedUsers = new list<User>();
		if(intranetformType.Selected_Users__c != null && intranetformType.Selected_Users__c != '') {
			List<String> userIds = new List<String>(intranetformType.Selected_Users__c.split(';'));
			selectedUsers = [select Id, name from user where id in:userIds];
		}
	}
	
	/**********************************************************************************
  * Save updated IntranetFormListFields__c records
	**********************************************************************************/
	public pageReference save() {
		List<IntranetFormListFields__c> updatedFields = new List<IntranetFormListFields__c>();
		for(IntranetFormListFields__c field: intranetformType.IntranetFormListFields__r) {
			if(field.Required__c != formFieldMap.get(field.Id).Required__c) {
				updatedFields.add(field);	
			}
		}
		if(!updatedFields.isEmpty())
			update updatedFields;
		pageReference pg = new pageReference('/apex/IntranetFormListDetail?formId='+intranetformType.id+'&isEdit=false');
		pg.setRedirect(true); 
		return pg;
	}
	
	/****************************************************************************************
  * User redirect to edit page where user can select required fields for intranet form page 
	*****************************************************************************************/
	public pageReference editPermission() {
		pageReference pg = new pageReference('/apex/IntranetFormListDetail?formId='+intranetformType.id+'&isEdit=true');
		pg.setRedirect(true); 
		return pg;
	}
	
	/**********************************************************************************
  * User redirect to edit page where user can select fields for intranet form page 
	**********************************************************************************/
	public pageReference edit() {
		pageReference pg = new pageReference('/apex/IntranetCreateFormList?Id='+intranetformType.id);
		pg.setRedirect(true); 
		return pg;
	}
	
	/**********************************************************************************
  * Redirect to detail view of record 
	**********************************************************************************/
	public pageReference cancel() {
		pageReference pg = new pageReference('/apex/IntranetFormListDetail?formId='+intranetformType.id+'&isEdit=false');
		pg.setRedirect(true); 
		return pg;
	}
}