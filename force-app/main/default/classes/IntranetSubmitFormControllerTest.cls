/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetSubmitFormControllerTest
* Date          :  March 05,2013
* Description   :  Verify functionality of IntranetSubmitFormController class
****************************************************************************************/   
@isTest
private class IntranetSubmitFormControllerTest {

    static testMethod void testSubmitFormFunctionality() {
    	//create form config custom setting
    	Intranet_Form_Config__c formConfig = TestUtil.createIntranetFromConfig(true, 'Enter name of airline', 'Enter_Name_Of_Airline__c', 'Name');
    	
    	IntranetFormList__c formList = new IntranetFormList__c();
	  	formList = TestUtil.createFormList(false, UserInfo.getUserId());
	  	formList.Selected_Users__c = Userinfo.getUserId() + ';';
	  	insert formList;
      
      IntranetFormListFields__c formListField = new IntranetFormListFields__c();
	  	formListField = TestUtil.createFormListField(true, formList.Id, 1, 'enter_name_of_airline__c');
	  	
    	// Using Page IntranetSubmitForm and setting as CurrentPage
      PageReference thePage = Page.IntranetSubmitForm; 
      Test.setCurrentPage(thePage);      
      ApexPages.currentPage().getParameters().put('formTypeId',formList.Id);
      
      Test.startTest();
      IntranetSubmitFormController controller = new IntranetSubmitFormController();
      system.assertEquals(controller.reviewerOptions.size(),2);
     	//assert autopopulate
      system.assertEquals(controller.intranetForm.Enter_Name_Of_Airline__c, Userinfo.getName());
      controller.save();
      //assert save
      system.assertEquals(getFormData(controller.intranetForm.Id).Status__c,'Not Submitted');
      
      //verify edit functionality
			ApexPages.currentPage().getParameters().put('Id',controller.intranetForm.Id);
			IntranetSubmitFormController con = new IntranetSubmitFormController();
			con.saveAndSubmitForApproval();
			//assert form approval
			system.assertEquals(getFormData(con.intranetForm.Id).Locked__c,true);
      Test.stopTest();
    }
     
    static Intranet_Form__c getFormData(Id id) {
    	Intranet_Form__c form = [Select Status__c, Locked__c, Form_Type__c From Intranet_Form__c where Id=:id];
    	return form;
    }
}