/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetFormEditDetailControllerTest
* Date          :  March 04,2013
* Description   :  Verify functionality of IntranetFormEditDetailController class
****************************************************************************************/    
@isTest
private class IntranetFormEditDetailControllerTest {

    static testMethod void testFormDetail() {
    	//create test Data
      IntranetFormList__c formList = TestUtil.createFormList(true, UserInfo.getUserId());
      IntranetFormListFields__c formListField = TestUtil.createFormListField(true, formList.Id, 1, 'enter_name_of_airline__c');
	  	
	  	Intranet_Form__c form = TestUtil.createForm(false);
	  	form.Form_Type__c = formList.Id;
	  	form.Approver__c = Userinfo.getUserId();
	  	insert form;
	  	
	  	Test.startTest();
	  		PageReference pageRef = Page.IntranetFormEditDetail;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('Id', form.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(form);
	  		IntranetFormEditDetailController controller = new IntranetFormEditDetailController(stdController);
	  		//assert list of fields display on form detail and edit page
	  		//should be 1
	  		system.assertEquals(controller.IntranetFormType.IntranetFormListFields__r.size(), 1);
	  		//assert isEdit
	  		//Should be false because returnUrl is null
	  		system.assertEquals(controller.isEdit, false);
	  		//assert save
	  		system.assertEquals(controller.save().getUrl(), '/apex/IntranetFormEditDetail?id='+form.Id);
	  	Test.stopTest();
    }
}