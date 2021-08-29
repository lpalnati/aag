/**
  * Apex Class  : IntranetSubmitFormController 
  * Created By  : Harshit Jain (Appirio Off)
  * Created Date: Feb 14, 2012.
  * Description : This class is used to create intranet form.
*/
public with sharing class IntranetSubmitFormController {
  public IntranetFormList__c IntranetFormType { get; set; }//User selected form type
  public Intranet_Form__c intranetForm{get;set;}
  public String reviewerId {get;set;}
  private Id formId{get;set;}
   
  /************************************************************************
  * Initialize intranetForm detail based on wheather it is new form 
  * or previously submitted form.    
  *************************************************************************/ 
  public IntranetSubmitFormController() { 
    formId = ApexPages.currentPage().getParameters().get('Id');
   	for (IntranetFormList__c intranetForm : [Select Name, Id,Select_Approver__c,Skip_Reviewer__c,Selected_Users__c,Form_Category__c,  
                                            (Select Field_API_Name__c, Sequence_Order__c,Required__c 
                                             From IntranetFormListFields__r 
                                             order by Sequence_Order__c ) 
                                             From IntranetFormList__c 
		                                        where Id =: ApexPages.currentPage().getParameters().get('formTypeId')])
			IntranetFormType = intranetForm;		                                        

    if(formId == null) {
    	intranetForm = new Intranet_Form__c();
    	autoPopulateFormData();
    }else {
    	intranetForm = getFormData();
    }
  }
  
  /**************************************************************	
	*Populate review list so end user can select user as reviewer  	
	***************************************************************/ 
	public List<selectOption> reviewerOptions {
		get {
			List<selectOption> reviewer = new List<selectOption>();
			if(IntranetFormType.Selected_Users__c != null && IntranetFormType.Selected_Users__c != '') {
				List<String> userIds = new List<String>(IntranetFormType.Selected_Users__c.split(';'));
				reviewer.add(new selectOption('','--None--'));
				for (User user : [select Id, name from user where id in:userIds]) {
					reviewer.add(new selectOption(user.Id, user.Name));
					if(intranetForm.Approver__c == user.Id) {
						reviewerId = user.Id;
					}
				} 
			}	
	    return reviewer;
	 	}
	}
   
  /**************************************************************
  * Save form detail filled by end user and submit for approval.
  **************************************************************/
  public PageReference saveAndSubmitForApproval() {
    intranetForm.Form_Type__c = (intranetForm.Form_Type__c == null) ? IntranetFormType.Id : intranetForm.Form_Type__c;
    intranetForm.Form_Category__c = IntranetFormType.Form_Category__c;
    if(formId == null) {
			pouplateFieldsForNewForm();    
    }else{
    	pouplateFieldsForOldForm();
    }
    if(intranetForm.Skip_Reviewer__c == true){
    	intranetForm.Status__c = 'New';
    	intranetForm.Locked__c = true;
    	upsert intranetForm;
    }else{
    	upsert intranetForm;
    	if(!Test.isRunningTest()) {
				// Create an approval request for the Intranet Form
	    	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
	    	req1.setComments('Submitting request for approval');
	    	req1.setObjectId(intranetForm.id);
	    	req1.setNextApproverIds(new Id[] {intranetForm.Approver__c});
	    	// Submit the approval request for the Opportunity
	    	Approval.ProcessResult result = Approval.process(req1);	    	
    	}else{
    		intranetForm.Locked__c = true;
    		upsert intranetForm; 	
    	}
    }
    return new PageReference('/apex/IntranetMySubmittedFormDetail?Id='+intranetForm.Id+'&formTypeId='+IntranetFormType.Id);//redirect to detail page
  }
  
  /**************************************************************
  * Save form detail filled by end user.
  **************************************************************/
  public PageReference save() {
    intranetForm.Form_Type__c = (intranetForm.Form_Type__c == null) ? IntranetFormType.Id : intranetForm.Form_Type__c;
    intranetForm.Form_Category__c = IntranetFormType.Form_Category__c;
    if(formId == null) {
			pouplateFieldsForNewForm();    
    }else{
    	pouplateFieldsForOldForm();
    }
    intranetForm.Status__c = 'Not Submitted';
    upsert intranetForm;
    return new PageReference('/apex/IntranetMySubmittedFormDetail?Id='+intranetForm.Id+'&formTypeId='+IntranetFormType.Id);//redirect to detail page
  }
	
	private void pouplateFieldsForNewForm(){
		intranetForm.Approver__c = (reviewerId != null) ? reviewerId  : IntranetFormType.Select_Approver__c;	
		if(IntranetFormType.Skip_Reviewer__c == true) {
			intranetForm.Skip_Reviewer__c = true;
    }
	}
	
	private void pouplateFieldsForOldForm(){
		intranetForm.Approver__c = (reviewerId != null && intranetForm.Approver__c != reviewerId) ? reviewerId  : intranetForm.Approver__c;
	}
	
	/**************************************************************
  * Fetch only those fields present into user selected form type.
  **************************************************************/
  private Intranet_Form__c getFormData() {
    String query = 'Select Id,Form_Type__r.Name,Form_Type__c,Approver__c,Skip_Reviewer__c,Form_Category__c,';
    for(IntranetFormListFields__c formField : IntranetFormType.IntranetFormListFields__r) {
        query += formField.Field_API_Name__c + ',';
    }
    query = query.substringBeforeLast(','); 
    query += ' From Intranet_Form__c where Id = \''+ApexPages.currentPage().getParameters().get('Id') + '\'';
    return Database.query(query);
  }
  
  /**************************************************************
  * Fetch current user data to populate into intranet form fields
  **************************************************************/
  private User getUserData() {
    String query = 'Select ';
   	for(Intranet_Form_Config__c formConfig : Intranet_Form_Config__c.getAll().values()) {
    	query += formConfig.Related_User_Field_API_Name__c + ',';
   	}
    query = query.substringBeforeLast(','); 
    query += ' From User where Id = \''+Userinfo.getUserId() + '\'';
    return Database.query(query);
  }
  
  /****************************************************************
  * Autopopulate intranet from fields form user fields.
  * Get mapping of fields from Intranet form config custom setting. 
  *****************************************************************/
  private void autoPopulateFormData(){
  	User currentUser;
  	if(Intranet_Form_Config__c.getAll().values().size() > 0) {
  		currentUser = getUserData();
  	} 
  	Map<String, Intranet_Form_Config__c> formFieldConfigMap = new Map<String, Intranet_Form_Config__c>();
  	for(Intranet_Form_Config__c formConfig : Intranet_Form_Config__c.getall().values()) {
    	formFieldConfigMap.put(formConfig.Form_Field_API_Name__c.toLowerCase(), formConfig);
   	}
   	for(IntranetFormListFields__c formField : IntranetFormType.IntranetFormListFields__r) {
	    if(formFieldConfigMap.containsKey(formField.Field_API_Name__c)) {
	    	intranetForm.put(formField.Field_API_Name__c,currentUser.get(formFieldConfigMap.get(formField.Field_API_Name__c).Related_User_Field_API_Name__c));	
	    }
    }
  } 
}