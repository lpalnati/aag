/*******************************************************************************
Created By     :   Suraj Rajoria(Appirio Offshore)
Date           :   15 Dec 2012
Description    :   To test contents sharing
Class Name     :   IntranetContents_ShareWithOtherLibTest
Modified By    : Ashish Sharma
Modified Date  : 29th October, 2014
Ref.           : T-329194      
Modified By    : Ashish Sharma
Modified Date  : 13th November, 2014
Ref.           : T-333833 (Update test code coverage as necessary)   
*******************************************************************************/
@isTest(seeAllData = true)
private class IntranetContents_ShareWithOtherLibTest {
    public static string WSGlobal ='VX Master';
    public static string UserWS ='InFlight';
    static testMethod void myUnitTest() {

       Set<String> libraries = new Set<String>();
       
       for(ContentWorkSpace cws:[Select Id,Name from ContentWorkSpace where Name  != '*VX Master' limit 2]){
           libraries.add(cws.Name);
       }
       
     
        ContentVersion testContent = [SELECT ContentDocumentId,Start_Date__c,End_Date__c,Team__c FROM ContentVersion where Title like '%Content for Production Deploy']; 
        ContentWorkspace testWorkspace = [Select Id from ContentWorkSpace where Name like '%VX Master'];
        
        User user = [SELECT ID FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' limit 1];
        
        List<Intranet_Required_Reading__c> intranetReqList = new List<Intranet_Required_Reading__c>();
        
        Intranet_Required_Reading__c intranetReq = new Intranet_Required_Reading__c();
        intranetReq.ContentVersionID__c = testContent.Id;
        intranetReq.Name = 'Test';
        intranetReq.User_ID__c = Userinfo.getUserId();
        intranetReqList.add(intranetReq);
        
        intranetReq = new Intranet_Required_Reading__c();
        intranetReq.ContentVersionID__c = testContent.Id;
        intranetReq.Name = 'Test1';
        intranetReq.User_ID__c =user.Id;
        intranetReqList.add(intranetReq);
        
        insert intranetReqList;
        
        System.runAs(user){
            Group grpMem = [SELECT ID FROM Group Where Type = 'Regular' limit 1];
        
            List<GroupMember> grpMembers = new List<GroupMember>();
            
            for(Group grp : [SELECT ID, Name FROM Group WHERE Name = 'InFlight' OR Name = 'All Virgin America']){
                grpMembers.add(new GroupMember(GroupId = grp.Id, UserOrGroupId = grpMem.Id));
            }
            
            insert grpMembers;
        }
        
        testContent.RR_Team__c = 'InFlight; Flight Ops';
        testContent.Due_Date__c = Datetime.now();
        testContent.Required_Readings__c = true;
        update testContent;
        
        testContent.Start_Date__c = System.now().addMinutes(-10);
        testContent.End_Date__c = System.now().addMinutes(60);
        testContent.Required_Readings__c = true;
        testContent.RR_Team__c = 'InFlight; Flight Ops';
        testContent.Due_Date__c = Datetime.now();
        testContent.Required_Readings_for_all_users__c = true;
        testContent.Required_Readings__c = true;
        update testContent; 
            
        test.startTest();
            testContent.Required_Readings_for_all_users__c = false;
            update testContent;
            
            testContent.Due_Date__c = null;
            testContent.RR_Team__c = null;
            testContent.Required_Readings_for_all_users__c = false;
            testContent.Required_Readings__c = false;
            update testContent; 
            
            testContent.Required_Readings__c = true;
            testContent.RR_Team__c = 'InFlight; Flight Ops';
            testContent.Due_Date__c = Datetime.now();
            testContent.Required_Readings_for_all_users__c = true;
            testContent.Required_Readings__c = true;
            update testContent;
            
            testContent.RR_Team__c = 'InFlight';
            update testContent;
            
            System.assertNotEquals(null, [SELECT ID FROM Intranet_Required_Reading__c WHERE Name = 'Test']);
        test.stopTest();
    }
}