/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetFormListAdminTest
* Date          :  March 04,2013
* Description   :  Verify functionality of IntranetFormListAdminController class
****************************************************************************************/        
@isTest
private class IntranetFormListAdminTest {

    static testMethod void testFormTypeList() {
    	// Using Page IntranetFormListAdmin and setting as CurrentPage
      PageReference thePage = Page.IntranetFormListAdmin; 
      Test.setCurrentPage(thePage);  
      
    	IntranetFormList__c formList;
      list<IntranetFormList__c> formListList = new list<IntranetFormList__c>();
      for(Integer i=0; i<5; i++) {
      	formList = new IntranetFormList__c();
      	formList = TestUtil.createFormList(false, UserInfo.getUserId());
      	formListList.add(formList);
      }
      if(!formListList.isEmpty()) {
      	insert formListList;
      }
      
      IntranetFormListFields__c formListField;
      list<IntranetFormListFields__c> formListFieldList = new list<IntranetFormListFields__c>();
      for(Integer i=0; i<5; i++) {
      	for(Integer j=0; j<5; j++) {
					formListField = new IntranetFormListFields__c();
      		formListField = TestUtil.createFormListField(false, formListList.get(i).Id, j, 'Test_Field'+j+'__c');
      		formListFieldList.add(formListField);      	
      	}
      }
      if(!formListFieldList.isEmpty()) {
      	insert formListFieldList;
      }
      
      Test.startTest();
      IntranetFormListAdminController controller = new IntranetFormListAdminController();
      //assert size of form list
      system.assertEquals(controller.formList.size(), 5);
      //assert CreateNewForm method
      system.assertEquals(controller.createNewForm().getUrl(),'/apex/IntranetCreateFormList');
      controller.getList();
      
      //Create assiociated form record for first form type
      Intranet_Form__c form = new Intranet_Form__c();
      form.Form_Type__c = formListList.get(0).Id;
      insert form;
      
      controller.deleteFormIndex = 0;
      controller.deleteForm();
			
			controller.deleteFormIndex = 1;
      controller.deleteForm();
			Test.stopTest();          	
    }
   
}