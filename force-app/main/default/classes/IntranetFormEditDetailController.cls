/*******************************************************************************************************
  * Apex Class  : IntranetFormEditDetailController 
  * Created By  : Harshit Jain (Appirio Off)
  * Created Date: April 2, 2013.
  * Description : This class is used to provide edit and display detail functionality of intranet form.
*******************************************************************************************************/
public with sharing class IntranetFormEditDetailController {
  public IntranetFormList__c IntranetFormType { get; set; }//User selected form type
  public Intranet_Form__c intranetForm{get;set;}
  public Boolean isEdit {get;set;}
	
	//Constructor
	public IntranetFormEditDetailController(ApexPages.StandardController controller) {
		 intranetForm  = (Intranet_Form__c)controller.getRecord(); 
		 isEdit = (ApexPages.currentPage().getParameters().get('retURL') != null)? true : false;
		 for (IntranetFormList__c intranetForm : [Select (Select Field_API_Name__c, Sequence_Order__c,Required__c 
                                             From IntranetFormListFields__r 
                                             order by Sequence_Order__c) 
                                             From IntranetFormList__c 
		                                         where Id =: intranetForm.Form_Type__c]) 
			IntranetFormType = intranetForm;
			intranetForm = getFormData();
	}
	
	/**************************************************************
  * Fetch only those fields present into user selected form type.
  **************************************************************/
  private Intranet_Form__c getFormData() {
    String query = 'Select Id,Name,Form_Type__r.Name,Form_Type__c,Status__c,Locked__c,';
    for(IntranetFormListFields__c formField : IntranetFormType.IntranetFormListFields__r) {
        query += formField.Field_API_Name__c + ',';
    }
    query = query.substringBeforeLast(','); 
    query += ' From Intranet_Form__c where Id = \''+ApexPages.currentPage().getParameters().get('Id') + '\'';
    return Database.query(query);
  }
  
  /**************************************************************
  * Update IntranetForm detail and redirect to deatil page
  **************************************************************/
  public pageReference save() {
  	try{
  		update intranetForm;
  	}catch(DMLException e) {
  		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	    return null;	
  	}
  	pageReference pg = new PageReference('/apex/IntranetFormEditDetail?id='+intranetForm.Id);
    pg.setRedirect(true);
   	return pg;
  }
}