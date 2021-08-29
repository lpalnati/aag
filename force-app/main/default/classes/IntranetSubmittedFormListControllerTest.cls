/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetSubmittedFormListControllerTest
* Date          :  March 05,2013
* Description   :  Verify functionality of IntranetSubmittedFormListController class
****************************************************************************************/ 
@isTest
private class IntranetSubmittedFormListControllerTest {

    static testMethod void testSubmittedFormList() {
    	createDummyData();
    	Test.startTest();
    	IntranetSubmittedFormListController controller = new IntranetSubmittedFormListController();
    	//assert size of form list
    	system.assertEquals(controller.submittedFormList.size(),5);
    	controller.getList();
    	controller.setSortDirection('DESC');
    	//assert sort direction
    	System.assertEquals(controller.getSortDirection(),'DESC');
    	Test.stopTest();
    }
    
    static void createDummyData() {
    	IntranetFormList__c formList = new IntranetFormList__c();
	  	formList = TestUtil.createFormList(true, UserInfo.getUserId());
      	
      IntranetFormListFields__c formListField = new IntranetFormListFields__c();
	  	formListField = TestUtil.createFormListField(true, formList.Id, 1, 'Test_Field__c');
	  	
	  	Intranet_Form__c form;
      list<Intranet_Form__c> intranetFormList = new list<Intranet_Form__c>();
      for(Integer i=0; i<5; i++) {
      	form = new Intranet_Form__c();
      	form = TestUtil.createForm(false);
      	form.Form_Type__c = formList.Id;
      	intranetFormList.add(form);
      }
      if(!intranetFormList.isEmpty()) {
      	insert intranetFormList;
      }
    }
}