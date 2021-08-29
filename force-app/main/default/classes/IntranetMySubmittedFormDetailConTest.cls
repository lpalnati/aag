/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetMySubmittedFormDetailConTest
* Date          :  March 05,2013
* Description   :  Verify functionality of IntranetMySubmittedFormDetailController class
****************************************************************************************/        
@isTest
private class IntranetMySubmittedFormDetailConTest {

    static testMethod void testFormDetail() {
    	IntranetFormList__c formList = new IntranetFormList__c();
	  	formList = TestUtil.createFormList(false, UserInfo.getUserId());
	  	formList.Skip_Reviewer__c = true;
	  	insert formList;
      
      IntranetFormListFields__c formListField = new IntranetFormListFields__c();
	  	formListField = TestUtil.createFormListField(true, formList.Id, 1, 'enter_name_of_airline__c');
	  	
	  	Intranet_Form__c form = TestUtil.createForm(false);
	  	form.Form_Type__c = formList.Id;
	  	form.Approver__c = Userinfo.getUserId();
	  	insert form;
	  	
	  	Intranet_Form__c form1 = TestUtil.createForm(false);
	  	form1.Form_Type__c = formList.Id;
	  	form1.Approver__c = Userinfo.getUserId();
	  	form1.Skip_Reviewer__c = true;
	  	insert form1;
	  	
	  	// Using Page IntranetMySubmittedFormDetail and setting as CurrentPage
      PageReference thePage = Page.IntranetMySubmittedFormDetail; 
      Test.setCurrentPage(thePage);
      ApexPages.currentPage().getParameters().put('formTypeId',formList.Id);
      ApexPages.currentPage().getParameters().put('Id',form.Id);  
      
	  	Test.startTest();
	  	IntranetMySubmittedFormDetailController controller = new IntranetMySubmittedFormDetailController();
	  	//assert form deatil
	  	system.assertEquals(controller.formDetail.Form_Type__c,formList.Id);
	  	//assert approval
	  	controller.submitForApproval();
	  	//assert recall
	  	controller.comments = 'Test recall process';
	  	controller.recallApprovalRequest();
	  	System.assertEquals(getFormData(form.Id).Locked__c,false);
	  	
	  	// verify funcationlity when skip reviewer ids true 
	  	ApexPages.currentPage().getParameters().put('formTypeId',formList.Id);
      ApexPages.currentPage().getParameters().put('Id',form1.Id);
      IntranetMySubmittedFormDetailController controller1 = new IntranetMySubmittedFormDetailController();
      //assert approval
	  	controller1.submitForApproval();
	  	system.assertEquals(getFormData(form1.Id).Locked__c,true);
	  	Test.stopTest();     
    }
    
    static Intranet_Form__c getFormData(Id id) {
    	Intranet_Form__c form = [Select Status__c, Locked__c, Form_Type__c From Intranet_Form__c where Id=:id];
    	return form;
    }
}