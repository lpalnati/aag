/**********************************************************************************
  Apex Class: IntranetFormTypesController
  CreatedBy : Harshit Jain
  CreatedDate : Feb 19, 2012
  Description: This class is used to create IntranetFormsType page. 
  						 it show list of all form types available for intranet end user with pagination. 	
**********************************************************************************/
public with sharing class IntranetFormTypesController {
	public Integer selectedPageNumber{get;set;} 
  public IntranetPaginationUtility formListPagination{get;set;}
	public list<formListWrapper> formsList {get;set;}
  
  
  /*******************************************************
  * The constructor initializes the public member
  ********************************************************/ 
	public IntranetFormTypesController() {
	 	formsList = new list<formListWrapper>();
    addPaginationOnFormList(); 
	}
	
	/***************************************************************
  * Add pagination on Form list 
  * IntranetPaginationUtility class to used for pagination.
  ***************************************************************/   
	public void addPaginationOnFormList() {
   	List<formListWrapper> intranetFormListWrapper = new List<formListWrapper>();
  	formListPagination = new IntranetPaginationUtility();
  	set<String> reviewerNames;
  	selectedPageNumber = 1;
  	map<Id,User> userMap = new map<Id,User>([select Name,Id from User]);
  	map<Id,Group> queueMap = new map<Id,Group>();
  	for(Group grp : [select Name,Id from Group where type = 'Queue']) {
			 queueMap.put(grp.id,grp);
  	}
  	for(IntranetFormList__c form : [Select Id,Selected_Users__c, Select_Approver__c, Name, Active__c 
  																					From IntranetFormList__c where Active__c = true  
  																					order by Name]) {
  		reviewerNames = new set<String>();
  		/*
  			pupolate reviewer name set based on 3 cases:
  			1)Form has multiple users so end user can select reviewer
  			2)Form has only one users
  			3)Form has queue  
  		*/ 																		
  		if(String.isNotBlank(form.Selected_Users__c)) {
  			for(String userId : form.Selected_Users__c.split(';')) {
  				reviewerNames.add(userMap.get(userId).Name);
  			}
  		}else if(form.Select_Approver__c.startsWithIgnoreCase('00G')) {
  			reviewerNames.add(queueMap.get(form.Select_Approver__c).Name);
  		}else{
  			reviewerNames.add(userMap.get(form.Select_Approver__c).Name);
  		}																				
      intranetFormListWrapper.add(new formListWrapper(form,reviewerNames));
    }
    if(intranetFormListWrapper.size() > 0) {
      formListPagination.pageSize = 10;
      List<Object> tempList = formListPagination.setPagination(intranetFormListWrapper);
      formsList = getWrapperList(tempList);
    }
  }
   
  /************************************************************
  * Method to cast object into forms wrapper
  ************************************************************/
  private List<formListWrapper> getWrapperList(List<Object> currentList) {
	  formsList.clear();
    for(Object obj : currentList) {
        formsList.add((formListWrapper)obj);
    }
    return formsList;
  }
    
  /************************************************************
  * Method to get pagination list of forms wrapper
  ************************************************************/
  public PageReference getList() {
    formsList = getWrapperList(formListPagination.getPage(selectedPageNumber));
    return null;
  }
  
  public class formListWrapper {
  	public IntranetFormList__c formList{get;set;}
  	public set<String> reviewerNameList{get;set;}
  	public Integer reviewerListSize{get;set;}
  	public formListWrapper(IntranetFormList__c formList,set<String> reviewerList) {
  		this.formList = formList;
  		this.reviewerNameList = new set<String>();
  		this.reviewerNameList.addAll(reviewerList);
  		this.reviewerListSize = reviewerList.size();
  	} 
  }
}