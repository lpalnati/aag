/*****************************************************************************
* Author        :  Ashish Sharma
* Name          :  IntranetRRAssignmentTriggerHandlerTest
* Date          :  31st October, 2014
* Description   :  Test Class for IntranetRRAssignmentTriggerHandler
* Modified By   :  Ashish Sharma
* Modified Date :  3rd November, 2014
* Ref.          :  T-330704 - Create trigger on user creation that adds user to appropriate public group
*Modified By    : Ashish Sharma
*Modified Date  : 13th November, 2014
*Ref.           : T-333833 (Update test code coverage as necessary)  
******************************************************************************/
@isTest(seeAlldata=true)
public class IntranetRRAssignmentTriggerHandlerTest {
     public static string WSGlobal ='VX Master';
     public static string UserWS ='InFlight';
    
     public  static testMethod void TestRRWithTeam() {  
        Set<String> libraries = new Set<String>();
           
        for(ContentWorkSpace cws:[Select Id,Name from ContentWorkSpace where Name  != '*VX Master' limit 2]){
           libraries.add(cws.Name);
        }
        
        ContentVersion testContent = [SELECT ContentDocumentId,Start_Date__c,End_Date__c,Team__c FROM ContentVersion where Title like '%Content for Production Deploy']; 
        ContentWorkspace testWorkspace = [Select Id from ContentWorkSpace where Name like '%VX Master'];
        
        User user = [SELECT ID, Division FROM User WHERE Profile.Name = 'System Administrator'
                                                AND isActive =: true 
                                                AND ID !=: Userinfo.getUserId()
                                                limit 1];
        Test.startTest();
        User usr = TestUtil.createUser(false);
        usr.Division = 'InFlight';
        insert usr;
        
        System.runAs(user){
            testContent.Start_Date__c = System.now().addMinutes(-10);
            testContent.End_Date__c = System.now().addMinutes(60);
            testContent.Team__c = 'Test';
            testContent.Assign_Retroactively__c = true;
            testContent.Required_Readings__c = true;
            testContent.RR_Team__c = 'InFlight; Flight Ops';
            testContent.Due_Date__c = Datetime.now().addDays(5);
            update testContent; 
            
            User_Division_Group_Configuration__c userDivGrpConfig = new User_Division_Group_Configuration__c();
            userDivGrpConfig.Name = 'Test Division';
            userDivGrpConfig.Group_Name__c = 'TestGrpDemo';
            insert userDivGrpConfig;
        }
        
        
        user.Division = 'InFlight';
        update user;
        
        Group testGroup = new Group();
        testGroup.Name = 'TestGrpDemo';
        insert testGroup;
        
        user.Division = 'Test Division';
        update user; 
        
        //Assert test if User is assigned to Group or not
        System.assertNotEquals([SELECT ID FROM GroupMember WHERE UserOrGroupId =: user.Id], null);
        
       Test.stopTest(); 
    }
}