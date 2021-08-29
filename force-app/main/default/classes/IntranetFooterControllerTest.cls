/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetFooterControllerTest
* Date          :  March 21,2013
* Description   :  Verify functionality of IntranetFooterController class
*****************************************************************************************/
@isTest
private class IntranetFooterControllerTest {

    static testMethod void testFooterClass() {
        // TO DO: implement unit test
        //create test data
        Intranet_Config__c config1 = TestUtil.createIntranetConfig(false, 'Company_Name_Footer', 'Test value');
        Intranet_Config__c config2 = TestUtil.createIntranetConfig(false, 'Facebook Social Link', 'Test value');
        Intranet_Config__c config3 = TestUtil.createIntranetConfig(false, 'Twitter Social Link', 'Test value');
        Intranet_Config__c config4 = TestUtil.createIntranetConfig(false, 'LinkedIn Social Link', 'Test value');
        Intranet_Config__c config5 = TestUtil.createIntranetConfig(false, 'Pinterest Social Link', 'Test value');
        Intranet_Config__c config6 = TestUtil.createIntranetConfig(false, 'Instgram Social Link', 'Test value');
        Intranet_Config__c config7 = TestUtil.createIntranetConfig(false, 'YouTube Social Link', 'Test value');
        insert new list<Intranet_Config__c>{config1,config2,config3,config4,config5,config6,config7};
        
        Test.startTest();
        	IntranetFooterController controller= new IntranetFooterController();
        	system.assertEquals(controller.companyName, 'Test value');
        Test.stopTest(); 
    }
}