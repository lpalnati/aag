/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetFormTypesControllerTest
* Date          :  March 05,2013
* Description   :  Verify functionality of IntranetFormTypesController class
****************************************************************************************/ 
@isTest
private class IntranetFormTypesControllerTest {

    static testMethod void testAvailableFormTypes() {
			user user = TestUtil.createUser(true);
    	IntranetFormList__c formList;
      List<IntranetFormList__c> formListList = new list<IntranetFormList__c>();
      for(Integer i=0; i<5; i++) {
      	formList = new IntranetFormList__c();
      	formList = TestUtil.createFormList(false, UserInfo.getUserId());
      	formListList.add(formList);
      }
      formListList.add(new IntranetFormList__c(Active__c = true,Select_Approver__c = UserInfo.getUserId(),Selected_Users__c = UserInfo.getUserId()+';'+user.Id));
      if(!formListList.isEmpty()) {
      	insert formListList;
      }
      
      Test.startTest();
      IntranetFormTypesController controller = new IntranetFormTypesController();
      controller.getList();
      //assert total form types available on intranet
      system.assertEquals(controller.formsList.size(),6);
      Test.stopTest();    
    }
}