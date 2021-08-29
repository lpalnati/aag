/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetMultiselectControllerTest
* Date          :  March 04,2013
* Description   :  Verify functionality of IntranetMultiselectController class
****************************************************************************************/    
@isTest
private class IntranetMultiselectControllerTest {

    static testMethod void testMultiPicklist() {
    	IntranetMultiselectController c = new IntranetMultiselectController();
        
      c.leftOptions = new List<SelectOption>();
      c.rightOptions = new List<SelectOption>();

      c.leftOptionsHidden = 'A&a&b&b&C&c';
      c.rightOptionsHidden = '';
       
      System.assertEquals(c.leftOptions.size(), 3);
      System.assertEquals(c.rightOptions.size(), 0);    
    }
}