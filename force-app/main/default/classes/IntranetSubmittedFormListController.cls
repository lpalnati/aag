/***************************************************************************************
  Apex Class: IntranetCreateFormListController
  CreatedBy : Harshit Jain
  CreatedDate : Feb 19, 2012
  Description: This class provide list of submitted form with pagination funcationlity. 	
***************************************************************************************/
public with sharing class IntranetSubmittedFormListController {
  public Integer selectedPageNumber{get;set;} // Page number of form table
  public IntranetPaginationUtility formListPagination{get;set;}
  public String sortDirection = 'ASC'; //Sort Order
  public String sortExp = 'Status__c'; //initial sort field
	public list<Intranet_Form__c> submittedFormList {get;set;}//List of all forms submitted by login user 
	
  /*******************************************************
  * The constructor initializes the public member
  * form List based on login user.
  ********************************************************/ 
	public IntranetSubmittedFormListController() {
	 	submittedFormList = new list<Intranet_Form__c>();
    addPaginationOnFormList(); 
	}
	
	/***************************************************************
  * Initalize sorting order based on previous value.
  ***************************************************************/   
	public String sortExpression {
  	get {
    	return sortExp;
    } 
    set {
			if (value == sortExp)
			sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
			else
			sortDirection = 'ASC';
			sortExp = value;
    }
  }
	
	/***************************************************************
  * Return Sorting order
  ***************************************************************/  
  public String getSortDirection() {
    if (sortExpression == null || sortExpression == '')
    	return 'ASC';
    else
    	return sortDirection;
  }
             
  /***************************************************************
  * Set sorting order
  ***************************************************************/             
  public void setSortDirection(String value) {  
  	sortDirection = value;
  }
	
	/***************************************************************
  * Add pagination on Form list 
  * IntranetPaginationUtility class to used for pagination.
  ***************************************************************/   
	public void addPaginationOnFormList() {
   	List<Intranet_Form__c> intranetFormList = new List<Intranet_Form__c>();
  	formListPagination = new IntranetPaginationUtility();
  	selectedPageNumber = 1;
  	submittedFormList.clear();
  	for(Intranet_Form__c intranetForm : getFormData()) {
      intranetFormList.add(intranetForm);
    }
    if(intranetFormList.size() > 0) {
      formListPagination.pageSize = 10;
      List<Object> tempList = formListPagination.setPagination(intranetFormList);
      submittedFormList = getWrapperList(tempList);
    }
   }
   
  /***************************************************************
  * Return List of all submitted form by current user.
  ***************************************************************/    
  private List<Intranet_Form__c> getFormData() {
  	string sortFullExp = sortExpression  + ' ' + sortDirection;
   	return Database.query('Select Id,CreatedDate,Status__c,Form_Type__r.Name,Form_Type__c From Intranet_Form__c where CreatedById =\''+ Userinfo.getUserId()+'\' AND Form_Type__c != null order by ' + sortFullExp);
  }
   
  /************************************************************
  * Method to cast object into forms
  ************************************************************/
  private List<Intranet_Form__c> getWrapperList(List<Object> currentList) {
	  submittedFormList.clear();
    for(Object obj : currentList) {
        submittedFormList.add((Intranet_Form__c)obj);
    }
    return submittedFormList;
  }
    
  /************************************************************
  * Method to get pagination list of forms
  ************************************************************/
  public PageReference getList() {
    submittedFormList = getWrapperList(formListPagination.getPage(selectedPageNumber));
    return null;
  }
}