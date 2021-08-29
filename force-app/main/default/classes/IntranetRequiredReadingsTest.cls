/*******************************************************************************
Created By     :   Virendra(Appirio Offshore)
Date           :   Jan 17 Dec 2012
Description    :   To test IntranetRequiredReadings
Class Name     :   IntranetRequiredReadingsTest
* Modified By   :  Ashish Sharma
* Modified Date :  27th October, 2014
* Ref.          :  T-328420     
*******************************************************************************/
@isTest(seeAllData = true)
private class IntranetRequiredReadingsTest {

     public static string WSGlobal ='VX Master';
     public static string UserWS ='InFlight';
    
     public  static testMethod void TestRRWithTeam() {  
        Set<String> libraries = new Set<String>();
           
        for(ContentWorkSpace cws:[Select Id,Name from ContentWorkSpace where Name  != '*VX Master' limit 2]){
           libraries.add(cws.Name);
        }
        ContentVersion testContent = [SELECT ContentDocumentId,Start_Date__c,End_Date__c,Team__c FROM ContentVersion where Title like '%Content for Production Deploy']; 
        ContentWorkspace testWorkspace = [Select Id from ContentWorkSpace where Name like '%VX Master'];
        Test.startTest();
        testContent.Start_Date__c = System.now().addMinutes(-10);
        testContent.End_Date__c = System.now().addMinutes(60);
        testContent.Team__c = 'Test';
          update testContent; 
        
          PageReference pageRef = Page.IntranetRequiredReadings;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('tabName', 'HOME');
        
                Intranet_Required_Reading__c rrReading1 = new Intranet_Required_Reading__c(ContentVersionID__c = testContent.Id, Name =testContent.Title, User_ID__c = UserInfo.getUserId());
        Intranet_Required_Reading__c rrReading2 = new Intranet_Required_Reading__c(ContentVersionID__c = testContent.Id, Name =testContent.Title, User_ID__c = UserInfo.getUserId(),Complete_Date__c = Date.today());    
        insert new List<Intranet_Required_Reading__c>{rrReading1, rrReading2};
        
        IntranetRequiredReadings conObj = new IntranetRequiredReadings();
        conObj.setNext();
        conObj.setNextRR();
        
        conObj.setPrev();
        conObj.setNextRR();
        conObj.setPage();
       
        conObj.getAllRows();
           
        conObj.getPage();
        conObj.getPageRR();
        conObj.getPageNumbersRR();
        conObj.getPageNumbers();
        
        Id rrUnreadId = null;
        for(Intranet_Required_Reading__c rr:[Select User_ID__c,Name,Id,Due_Date__c,ContentVersionID__c,Complete_Date__c,createdDate
                                             From Intranet_Required_Reading__c where User_ID__c =:Userinfo.getUserId()  order by Due_Date__c limit 100]){
            if(rr.Complete_Date__c == null){
               rrUnreadId = rr.Id;
               break;
            }
        }
        
        conObj.setComplete();
        /*
          Test For IntranetRequiredReadingsAcknowledge 
        */
        if(rrUnreadId != null){
            PageReference pageRefRRAck = Page.IntranetRequiredReadingsAcknowledge;
            Test.setCurrentPage(pageRefRRAck);
              //Pass parameteres to current page
            ApexPages.currentPage().getParameters().put('rrId', rrUnreadId);
            IntranetRequiredReadingsAcknowledge conRRAcObj = new IntranetRequiredReadingsAcknowledge();
            conRRAcObj.markComplete();
            conRRAcObj.isMarkComplete = true;
            conRRAcObj.markComplete();
            conRRAcObj.cancelAction();
        }
        
       Apexpages.currentPage().getParameters().put('resourceIdParam', testContent.Id);
       conObj.processContent();
       
       System.assert(conObj.versionDataforUI <> null);
       Test.stopTest(); 
    }
    
    
    public  static testMethod void TestRRWithAllGroup() {  
        Set<String> libraries = new Set<String>();
           
        for(ContentWorkSpace cws:[Select Id,Name from ContentWorkSpace where Name  != '*VX Master' limit 2]){
           libraries.add(cws.Name);
        }
        ContentVersion testContent = [SELECT ContentDocumentId,Start_Date__c,End_Date__c,Team__c FROM ContentVersion where Title like '%Content for Production Deploy']; 
        ContentWorkspace testWorkspace = [Select Id from ContentWorkSpace where Name like '%VX Master'];
            Test.startTest();
        testContent.Start_Date__c = System.now().addMinutes(-10);
        testContent.End_Date__c = System.now().addMinutes(60);
            update testContent;
          Test.stopTest();
    }
    
    
}