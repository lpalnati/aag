/***************************************************************************************
* Author        :  Harshit Jain(Appirio offshore)
* Name          :  IntranetFormShareWithApproverTest
* Date          :  March 18,2013
* Description   :  Verify functionality of IntranetFormShareWithApprover trigger
****************************************************************************************/  
@isTest
private class IntranetFormShareWithApproverTest {

    static testMethod void testFormSharing() {
        User user = TestUtil.createUser(true);
        User approver = TestUtil.createUser(false);
        approver.Username = approver.Username + '.approver';
        insert approver; 
        system.runAs(user){
	        Group grp = new Group(Name='Test queue');
	        insert grp;
	        GroupMember grpMember = new GroupMember(GroupId = grp.id,UserOrGroupId = approver.Id);
	        GroupMember grpMember1 = new GroupMember(GroupId = grp.id,UserOrGroupId = userInfo.getUserId());
	        insert new List<GroupMember>{grpMember,grpMember1};
	        //if approver is user
        	Intranet_Form__c form = TestUtil.createForm(false);
        	form.Approver__c = approver.Id;
        	insert form;
        
	        //if approver is queue
        	Intranet_Form__c frm = TestUtil.createForm(false);
        	frm.Approver__c = grp.Id;
        	insert frm;
        	
        	Test.startTest();
	        //Form submitted for approval
	        form.Locked__c = true;
	        update form;
	        //assert sharing record
	        //should be 2 records for approver and owner
	        system.assertEquals(getTotalSharingRecords(form.Id),2);
	        
	        //Form submitted for approval
	        frm.Locked__c = true;
	        update frm;
	        system.assertEquals(getTotalSharingRecords(form.Id),2);
	        Test.stopTest();	
        }
    }
    
    static Integer getTotalSharingRecords(Id parentId) {
    	return [select count() from Intranet_Form__Share where parentId =:parentId];
    }
}