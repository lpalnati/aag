/*******************************************************************************
Created By     :   Virendra(Appirio Offshore)
Date           :   Jan 17 Dec 2012
Description    :   To test IntranetRequiredReadingsAssignment
Class Name     :   IntranetRequiredReadingsAssignmentTest
Modified By    : Ashish Sharma
Modified Date  : 13th November, 2014
Ref.           : T-333833 (Update test code coverage as necessary)  
*******************************************************************************/
@isTest(seeAllData = true)
private class  IntranetRequiredReadingsAssignmentTest {
    
     public  static testMethod void TestRRAssignments() {  
        Set<String> libraries = new Set<String>();
           
        for(ContentWorkSpace cws:[Select Id,Name from ContentWorkSpace where Name  != '*VX Master' limit 2]){
           libraries.add(cws.Name);
        }
        
        Test.startTest();
        ContentVersion testContent = [SELECT ContentDocumentId,Start_Date__c,End_Date__c,Team__c FROM ContentVersion where Title like '%Content for Production Deploy']; 
        ContentWorkspace testWorkspace = [Select Id from ContentWorkSpace where Name like '%VX Master'];
    
        testContent.Start_Date__c = System.now().addMinutes(-10);
        testContent.End_Date__c = System.now().addMinutes(60);
        testContent.Team__c = 'Test';
        testContent.Team_Category__c = 'Test category';
        testContent.Required_Readings__c = true;
        testContent.RR_Team__c = 'Test';
        testContent.Due_Date__c = system.now().addDays(20);
        testContent.Published__c = true;
        update testContent; 
        
        //Create test user
        User user = TestUtil.createUser(true);
        
        //Add user to subscription list of created doucment
        Intranet_Required_Reading__c rrReading = new Intranet_Required_Reading__c();
        rrReading.ContentVersionID__c = testContent.Id;
        rrReading.Name = testContent.Title;
        rrReading.User_ID__c = user.Id;
        insert rrReading;
        
        IntranetRequiredReadingsAssignment rrsController = new IntranetRequiredReadingsAssignment();
        rrsController.contentVersion.Team__c = 'Test';
        rrsController.contentVersion.Team_Category__c = 'Test category';
        rrsController.getSelectedGroupContentList();
        system.assertEquals(rrsController.conPagination.isMoreNext,false);
        system.assertEquals(rrsController.conPagination.isMorePrevious,false);
            
        rrsController.selectedContentId = testContent.Id;
        rrsController.getSubscribeUserList();
        rrsController.getfilteredContentList();
        rrsController.subscribeUserSearchText = 'Content for Production Deploy';
        rrsController.searchSubscribeUser();
                
        rrsController.defaultUserSearchText = 'test';
        rrsController.searchDefaultUsers();
       
        rrsController.subscribeUserSearchText = '';
        rrsController.searchSubscribeUser();
        
        rrsController.unsubscribeUser();
        rrsController.subscribeUser();
        
        System.assertEquals(rrsController.getDefUserList(),  null);
      
      Test.stopTest();
    }

}