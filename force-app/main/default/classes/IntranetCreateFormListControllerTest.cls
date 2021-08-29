/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetCreateFormListControllerTest
* Date          :  March 04,2013
* Description   :  Verify functionality of IntranetCreateFormListController class
****************************************************************************************/        
@isTest
private class IntranetCreateFormListControllerTest {

    static testMethod void testFormTypeList() {
    	Test.startTest();
    	 // Using Page IntranetCreateFormList and setting as CurrentPage
      PageReference thePage = Page.IntranetCreateFormList; 
      Test.setCurrentPage(thePage);  
      
    	IntranetCreateFormListController controller = new IntranetCreateFormListController();
    	//assert Intranet_Form__c fields
    	system.assert(controller.allFields.size()>0 );
    	controller.intranetFormList.Active__c = true;
    	controller.intranetFormList.Select_Approver__c = Userinfo.getUserId();
    	controller.intranetFormList.Name = 'Test form';
    	controller.selectedFields.add(new SelectOption('Date__c', 'Date__c'));
    	controller.selectedUsers.add(new SelectOption(UserInfo.getUserId(), Userinfo.getName()));
    	controller.save();
    	system.assertEquals(getFormList('Test form').size(), 1);
    	system.assertEquals(getFormList('Test form').get(0).IntranetFormListFields__r.size(), 1);
    	
    	//Verify edit functionality
    	ApexPages.currentPage().getParameters().put('Id',getFormList('Test form').get(0).Id);
    	IntranetCreateFormListController controller1 = new IntranetCreateFormListController();
    	controller1.selectedFields.add(new SelectOption('Test__c', 'Test__c'));
    	controller1.save();
    	system.assertEquals(getFormList('Test form').get(0).IntranetFormListFields__r.size(), 2);
    	Test.stopTest();
    }
    
    static List<IntranetFormList__c> getFormList(String name) {
    	List<IntranetFormList__c> formListList = [Select Id,(Select Id From IntranetFormListFields__r)From IntranetFormList__c where Name = :name ];
    	return formListList;
    }
}