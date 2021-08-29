/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetFormListDetailControllerTest
* Date          :  March 04,2013
* Description   :  Verify functionality of IntranetFormListDetailController class
****************************************************************************************/        
@isTest
private class IntranetFormListDetailControllerTest {

    static testMethod void testFormDetail() {
    	IntranetFormList__c formList;
      List<IntranetFormList__c> formListList = new list<IntranetFormList__c>();
      for(Integer i=0; i<5; i++) {
      	formList = new IntranetFormList__c();
      	formList = TestUtil.createFormList(false, UserInfo.getUserId());
      	formList.Selected_Users__c = Userinfo.getUserId()+';';
      	formListList.add(formList);
      }
      if(!formListList.isEmpty()) {
      	insert formListList;
      }
      
      IntranetFormListFields__c formListField;
      List<IntranetFormListFields__c> formListFieldList = new list<IntranetFormListFields__c>();
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
    	// Using Page IntranetFormListDetail and setting as CurrentPage
      PageReference thePage = Page.IntranetFormListDetail; 
      Test.setCurrentPage(thePage);
      ApexPages.currentPage().getParameters().put('formId',formListList.get(0).Id);
      ApexPages.currentPage().getParameters().put('isEdit','true');
      IntranetFormListDetailController controller = new IntranetFormListDetailController();
      controller.intranetformType.IntranetFormListFields__r.get(0).Required__c = true;
      controller.intranetformType.IntranetFormListFields__r.get(1).Required__c = true;
      controller.intranetformType.IntranetFormListFields__r.get(2).Required__c = true;
      controller.save();
      //assert intranet form field permission
      system.assertEquals(getFormListFields(controller.intranetformType.Id).size(),3);
      //assert pageReferernce methods
      system.assertEquals(controller.edit().getUrl(),'/apex/IntranetCreateFormList?Id='+controller.intranetformType.Id);
      system.assertEquals(controller.editPermission().getUrl(),'/apex/IntranetFormListDetail?formId='+controller.intranetformType.id+'&isEdit=true');
      system.assertEquals(controller.cancel().getUrl(),'/apex/IntranetFormListDetail?formId='+controller.intranetformType.id+'&isEdit=false');
      Test.stopTest();
       
    }
    
    static List<IntranetFormListFields__c> getFormListFields(Id formTypeId) {
    	List<IntranetFormListFields__c> formListFields = [Select Id From IntranetFormListFields__c 
    																										where Related_Form__c =:formTypeId 
    																										AND Required__c = true];
    	return formListFields;
    } 
}