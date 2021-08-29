/***************************************************************************************
* Author        :  Lakshmi Palnati
* Name          :  CountManagerIdReportsTest
* Date          :  Jan 24,2016
* Description   :  Verify functionality of CountManagerIdReports trigger
****************************************************************************************/
@isTest(seeAllData = true)
private class CountManagerIdReportsTest {
    //static User u = [SELECT Id, ManagerId, Title FROM User WHERE User.UserName='test@mail145.com'];
    static Group managersGrp = [Select Id,Name From Group where Name = 'Manager and Supervisor'];
    static User u;
    
    static User user1, user2, user3;
    
    static {     
        List<User> userList = new List<user>();
        User user;  
    
        user1 = TestUtil.createUser(false);         
        user1.Username += 1;
        user1.CommunityNickname += 1;
        userList.add(user1);
        
        user2 = TestUtil.createUser(false);         
        user2.Username += 2;
        user2.CommunityNickname += 2;
        userList.add(user2);
        
        user3 = TestUtil.createUser(false);         
        user3.Username += 3;
        user3.CommunityNickname += 3;
        userList.add(user3);
                
        //Test.startTest();
        insert userList;

                       
        u = [SELECT Id, ManagerId, Title FROM User WHERE User.UserName=:user1.Username];

        
        //testUserAsSupervisor();
        //testUserAsNonSupervisor();
        //testUserAssignManager();
        //testUserChangeManager();
        //testUserRemoveManager();
        //Test.stopTest();
    }

    static testMethod void testUserAsSupervisor() {

      //Test.startTest();
      
      u.Title = 'Supervisor';
      u.isActive = true;
      System.assertEquals([Select count() From User where Id=:u.Id], 1);
      update u;
      
      //assert user is now part of All Virgin America chatter group
      //System.assertEquals([Select count() From GroupMember where GroupId = :managersGrp.Id and UserOrGroupId = :u.Id], 1);

      
      
     // u.Title = 'non-supv';
     // update u;
      
      //assert user is now part of All Virgin America chatter group
      //System.assertEquals([Select count() From GroupMember where GroupId = :managersGrp.Id and UserOrGroupId = :u.Id], 0);
      
      
      //u.Title = 'supv';
      //update u;
      
      //assert user is now part of All Virgin America chatter group
      //System.assertEquals([Select count() From GroupMember where GroupId = :managersGrp.Id and UserOrGroupId = :u.Id], 1);
      //Test.stopTest();
    } 
    
    
    static testMethod void testUserAsNonSupervisor() {

      Test.startTest();
      User usrRec = [SELECT ManagerId, Title FROM User WHERE User.Id=:u.Id];
      
      usrRec.Title = 'supv';
      update usrRec;
      
      //assert user is now part of All Virgin America chatter group
      //System.assertEquals([Select count() From GroupMember where GroupId = :managersGrp.Id and UserOrGroupId = :usrRec.Id], 1);
      
      Test.stopTest();
    } 
    
    static testMethod void testUserAssignManager() {

      Test.startTest();
      User mgrRec = [SELECT Id, Title FROM User WHERE User.UserName=:user2.Username];
      
      u.ManagerId= mgrRec.Id;
      update u;
      
      //assert user is now part of All Virgin America chatter group
      List<User> mgr = [SELECT No_of_reporting_to__c FROM User WHERE User.Id=:mgrRec.Id];
      //System.assertEquals(mgr[0].No_of_reporting_to__c, 1);
      
      Test.stopTest();
    } 
    
    static testMethod void testUserChangeManager() {

      Test.startTest();
      User oldmgrRec = [SELECT Id, Title FROM User WHERE User.UserName=:user2.Username];
      User newmgrRec = [SELECT Id, Title FROM User WHERE User.UserName=:user3.Username];
      
      u.ManagerId= newmgrRec.Id;
      oldmgrRec.Title='Supervisor';
      newmgrRec.Title='supv';
      update u;
      update oldmgrRec;
      update newmgrRec;
      
      //assert user is now part of All Virgin America chatter group
     // List<User> oldMgr = [SELECT Id, No_of_reporting_to__c FROM User WHERE User.Id=:oldmgrRec.Id];
      List<User> newMgr = [SELECT No_of_reporting_to__c FROM User WHERE User.Id=:newmgrRec.Id];
      //if (oldMgr.size() == 1) {
      //    System.assertEquals(oldmgr[0].No_of_reporting_to__c, 0);
      //}
     // System.assertEquals(newmgr[0].No_of_reporting_to__c, 1);
      
      Test.stopTest();
    } 
    
    static testMethod void testUserRemoveManager() {

      Test.startTest();

      u.ManagerId=null;
     
      update u;
      
      User newmgrRec = [SELECT Id, Title FROM User WHERE User.UserName=:user3.Username];
      List<User> newMgr = [SELECT No_of_reporting_to__c FROM User WHERE User.Id=:newmgrRec.Id];
     
      //System.assertEquals(newmgr[0].No_of_reporting_to__c, null);
      
      Test.stopTest();
    } 
}