/********************************************************************************
  * Apex Class  : IntranetMySubmittedFormDetailController 
  * Created By  : Harshit Jain (Appirio Off)
  * Created Date: Feb 13, 2012.
  * Description : This class is used to show detail of submitted from on Intranet
**********************************************************************************/
public without sharing class IntranetMySubmittedFormDetailController {
   public Intranet_Form__c formDetail{get;set;} // form record
   public list<IntranetFormListFields__c> intranetformFieldList{get;set;} //list of fields available on selected form type
   public String comments{get;set;}//comment for recall approval process
    
   /***************************************************************
   * Initializes 
   ***************************************************************/   
   public IntranetMySubmittedFormDetailController() {
   	intranetformFieldList = new List<IntranetFormListFields__c>();
   	//Fetch list of fields present on submitted form type 
    for(IntranetFormListFields__c formField : [Select Id, Field_API_Name__c 
                                                 From IntranetFormListFields__c 
                                                where Related_Form__c =:ApexPages.currentPage().getParameters().get('formTypeId') 
                                             order by Sequence_Order__c]) {
     	intranetformFieldList.add(formField);                                                                                   
    }
    formDetail = getFormData(); 
   }
   
   /*****************************************************************************
   * Created dynamic query to fetch submitted form data based on selected fields.
   *****************************************************************************/
   private Intranet_Form__c getFormData() {
   	String query = 'Select Id,Form_Type__r.Name,Form_Type__c,Locked__c,Status__c,Approver__c,Skip_Reviewer__c,';
    for(IntranetFormListFields__c formField : intranetformFieldList) {
      query += formField.Field_API_Name__c + ',';
    }
    query = query.substringBeforeLast(','); 
    query += ' From Intranet_Form__c where Id = \''+ApexPages.currentPage().getParameters().get('Id') + '\'';
    return Database.query(query);
   } 
   
   /**************************************************************
   * Submit intranet form for approval 
   **************************************************************/
   public pageReference submitForApproval() {
   	if(formDetail.Skip_Reviewer__c == true) {
   		formDetail.Status__c = 'New';
    	formDetail.Locked__c = true;
    	update formDetail;
   	}else{
   		if(!Test.isRunningTest()) {
		   	// Create an approval request for the Intranet Form
		    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		    req1.setComments('Submitting request for approval');
		    req1.setObjectId(formDetail.id);
		    req1.setNextApproverIds(new Id[] {formDetail.Approver__c});
		    try {
		    	// Submit the approval request for the Intranet Form
		    	Approval.ProcessResult result = Approval.process(req1);
		    }catch(Exception e) {
		    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		    	return null;	
		    }
   		}
   	}
   	pageReference pg = new PageReference('/apex/IntranetMySubmittedFormDetail?Id='+formDetail.Id+'&formTypeId='+formDetail.Form_Type__c);
    pg.setRedirect(true);
   	return pg;
   }
   
   /**************************************************************
   * Recall intranet form form approval 
   **************************************************************/
   public pageReference recallApprovalRequest() {
   	//get process instance of approval process 
		for(ProcessInstanceWorkitem workitem : [select Id, ProcessInstance.TargetObjectId 
   																					  from ProcessInstanceWorkitem 
   																					 where ProcessInstance.TargetObjectId = : formDetail.Id 
   																					   and ProcessInstance.Status = 'Pending']) {
			Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
			pwr.setWorkitemId(workitem.id);
	    pwr.setComments(comments);
	    pwr.setAction('Removed'); 
      Approval.ProcessResult pr = Approval.process(pwr);   																					   	
		}   																																								  
   	pageReference pg = new PageReference('/apex/IntranetMySubmittedFormDetail?Id='+formDetail.Id+'&formTypeId='+formDetail.Form_Type__c);
    pg.setRedirect(true);
   	return pg;
   }
}