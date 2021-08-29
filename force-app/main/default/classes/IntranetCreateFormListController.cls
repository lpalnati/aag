/**********************************************************************************
  Apex Class: IntranetCreateFormListController
  CreatedBy : Harshit Jain
  CreatedDate : Feb 19, 2012
  Description: This class is used to create intranet forms types. 
  						 it decide fields type and thier order on intranet form. 	
**********************************************************************************/
public with sharing class IntranetCreateFormListController {
  public IntranetFormList__c intranetFormList {get;set;}
  public SelectOption[] selectedFields {get;set;}//List of selected fields display on form
  public SelectOption[] allFields {get;set;}//List of all fields present on intranet_Form__c
  public SelectOption[] selectedUsers {get;set;}//List of selected fields display on form
  public SelectOption[] allUsers {get;set;}//List of all fields present on intranet_Form__c 
  public String message {get;set;}
  public String searchUserString {get;set;}//search string for user
  private Map<String, IntranetFormListFields__c> intranetFormListFieldMap {get;set;}
  private Set<Id> selectedUserSet {get;set;}
  //list of fields should not be included in intranet form   
  static final Set<String> fieldNotIncluded = new Set<String>{'form_type__c','status__c','approver__c','locked__c','skip_reviewer__c','form_category__c'};
  
  /***************************************************************
  * Initializes the public member
  ***************************************************************/  
  public IntranetCreateFormListController() {
  	Id id = ApexPages.currentPage().getParameters().get('Id');
  	searchUserString = '';
  	intranetFormListFieldMap = new Map<String, IntranetFormListFields__c>();
  	selectedUserSet = new Set<Id>();
  	intranetFormList = (id == null) ? new IntranetFormList__c() : [Select Name, Id, Active__c,Select_Approver__c,OwnerId,Form_Category__c,
  																																 Skip_Reviewer__c,Selected_Users__c, 
  																																(Select Id, Field_API_Name__c, Sequence_Order__c 
  																																	 From IntranetFormListFields__r order by Sequence_Order__c) 
  																																 From IntranetFormList__c where Id = :id];
		if(id != null) {
				intranetFormList.OwnerId = intranetFormList.Select_Approver__c;
		}  																																 
		selectedFields = new List<SelectOption>();
    for(IntranetFormListFields__c intranetFormListField : intranetFormList.IntranetFormListFields__r) {
    	intranetFormListFieldMap.put(intranetFormListField.Field_API_Name__c,intranetFormListField);
    	selectedFields.add(new SelectOption(intranetFormListField.Field_API_Name__c, intranetFormListField.Field_API_Name__c));
    }
    allFields = new List<SelectOption>();
    for (String FieldName :  Schema.sObjectType.Intranet_Form__c.fields.getMap().keySet()) {
        if(!intranetFormListFieldMap.ContainsKey(FieldName) && !fieldNotIncluded.contains(FieldName) && FieldName.endsWith('__c'))
	        allFields.add(new SelectOption(FieldName, FieldName));
    }
    allFields.sort();
    populateSelectedUsers();
    populateUsersToSelect();
  }
  
  /***************************************************************
  * Populate selected user list. 
  ***************************************************************/  
  public void populateSelectedUsers(){
  	selectedUsers = new List<SelectOption>();
  	if(intranetFormList.Selected_Users__c != null && intranetFormList.Selected_Users__c != '') {
  		for(String userId : intranetFormList.Selected_Users__c.split(';')) {
  			selectedUserSet.add(userId);
  		}
  	}
  	for(user user : [select Id, name from user where id in:selectedUserSet]) {
  		selectedUsers.add(new SelectOption(user.Id, user.Name));
  	}
  }
  
  
  /***************************************************************
  * Populate user list to select reviewer. 
  ***************************************************************/  
  public void populateUsersToSelect(){
  	allUsers = new List<SelectOption>();
  	String query = 'Select Id,Name from user where name like \'%' + searchUserString + '%\' order by Name limit 100';
  	for(User user : Database.query(query)) {
  		allUsers.add(new SelectOption(user.Id, user.Name));
  	}
  }
    
	/***************************************************************
  * Save Intranet form type(intranetFormList) created by user  
  ***************************************************************/  
  public PageReference save() {
		intranetFormList.Select_Approver__c = intranetFormList.OwnerId;
 		intranetFormList.OwnerId = Userinfo.getUserId();
 		populateSelectedUserField(); 
   	upsert intranetFormList; 
    upsertFormListFieldsRecord(intranetFormList.Id);
    return new pageReference('/apex/IntranetFormListDetail?formId='+intranetFormList.id+'&isEdit=false'); 
  }
  
  /*************************************************************************
  * Populate select user field by semi column separeted user ids  
  *************************************************************************/
  private void populateSelectedUserField() {
	  intranetFormList.Selected_Users__c = '';
	  for(SelectOption so : selectedUsers) {
	  	if(!intranetFormList.Selected_Users__c.contains(so.getValue())) {
	  		intranetFormList.Selected_Users__c += so.getValue() + ';';
	  	}
    }
  }
  
  /*************************************************************************
  * Create child(IntranetFormListFields__c) records for each selected field   
  *************************************************************************/
  private void upsertFormListFieldsRecord(Id intranetFormListId) {
    Integer sequenceOrder = 1;//Decide sequence order of field on intranet form page
    List<IntranetFormListFields__c> intranetFormListFieldList = new List<IntranetFormListFields__c>();
    IntranetFormListFields__c intranetFormListField;
    for(SelectOption so : selectedFields) {
    	//if field already present then update else create new record
    	if(intranetFormListFieldMap.containsKey(so.getValue())) {
    		if(intranetFormListFieldMap.get(so.getValue()).Sequence_Order__c != sequenceOrder) {
    			intranetFormListFieldMap.get(so.getValue()).Sequence_Order__c = sequenceOrder;
    			intranetFormListFieldList.add(intranetFormListFieldMap.get(so.getValue()));	 
    		}
				intranetFormListFieldMap.remove(so.getValue());   		
    	}else{
	      intranetFormListField = new IntranetFormListFields__c();
	      intranetFormListField.Field_API_Name__c = so.getValue();
	      intranetFormListField.Sequence_Order__c = sequenceOrder;
	      intranetFormListField.Related_Form__c = intranetFormListId;
	      intranetFormListFieldList.add(intranetFormListField);
    	}
      sequenceOrder++;  
    }
    if(!intranetFormListFieldList.isEmpty())
     upsert intranetFormListFieldList;
    //delete already present child records of unselected field  
    if(!intranetFormListFieldMap.isEmpty())
     delete intranetFormListFieldMap.values(); 
  }
  
}