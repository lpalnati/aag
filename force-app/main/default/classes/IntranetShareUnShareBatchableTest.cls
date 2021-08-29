/*******************************************************************************
Created By     :   Virendra(Appirio Offshore)
Date           :   17 Dec 2012
Description    :   To test contents Share and Unshare Batch Classes With Schedulers for both covering (
                    1.IntranetPublishOnEffectiveDateBatchable
                    2.IntranetUnShareOnEffectiveDateBatchable
                    3.PublishOnEffectiveDateSchedulable
                    4.UnshareOnEffectiveDateSchedulable
                    )
Class Name     :   IntranetUnShareBatchableTest 
*******************************************************************************/
@isTest(seeAllData = true)
private class IntranetShareUnShareBatchableTest {
    
    public static string WSGlobal ='VX Master';
    public static string UserWS ='InFlight';
    static testMethod void shareBatchClassTest() {  
    	try{
	    ContentVersion testContent = [SELECT ContentDocumentId,Start_Date__c,End_Date__c,Team__c FROM ContentVersion where Title like '%Content for Production Deploy']; 
	    ContentWorkspace testWorkspace = [Select Id from ContentWorkSpace where Name like '%VX Master'];
			Test.startTest();
	    DateTime startTime =  System.now().addSeconds(1);
	    testContent.Start_Date__c = startTime;
	    testContent.End_Date__c = System.now().addMinutes(30); 
	        
	    update testContent; 
	    
	    ContentDocument testDoc = [SELECT ID FROM ContentDocument limit 1];
	    delete testDoc;
	        
	    IntranetPublishOnEffectiveDateBatchable shareBc = new IntranetPublishOnEffectiveDateBatchable();
	        //shareBc.query = 'Select Id, Published__c from ContentVersion Where Start_Date__c  =:startTime';
	        
	    
	      //Database.executeBatch(shareBc, 200);
    	}catch(Exception e){
    		System.debug(e.getMessage());
    	}
	    Test.stopTest();
    }
    
    static testMethod void unShareBatchClassTest() {  
        try{
        ContentVersion testContent = [SELECT ContentDocumentId,Start_Date__c,End_Date__c,Team__c FROM ContentVersion where Title like '%Content for Production Deploy']; 
        ContentWorkspace testWorkspace = [Select Id from ContentWorkSpace where Name like '%VX Master'];
				Test.startTest();
        DateTime startTime =  System.now().addMinutes(2);
        testContent.Start_Date__c = startTime;
        testContent.End_Date__c = System.now().addMinutes(30); 
        update testContent; 
        
        testContent = [SELECT ContentDocumentId,Start_Date__c,End_Date__c,Team__c FROM ContentVersion where Id = :testContent.Id];
        testContent.Start_Date__c = System.now().addMinutes(-10);
        DateTime endTime =  System.now().addMinutes(-2);
        testContent.End_Date__c = endTime;
        update testContent;
        
        IntranetUnShareOnEffectiveDateBatchable unShareBc = new IntranetUnShareOnEffectiveDateBatchable();
        //unShareBc.query = 'Select Id, Published__c from ContentVersion Where End_Date__c  =:endTime';
        
        
            //Database.executeBatch(unShareBc, 200);
        }catch(Exception e){
    		System.debug(e.getMessage());
    	}
        Test.stopTest();
    }
    
     static testMethod void shareUnshareSchedulerClassTest() {
     	Test.startTest();	
     		try{
	     		PublishOnEffectiveDateSchedulable	 p = new PublishOnEffectiveDateSchedulable	();
				String sch ='0 0 * * * ?';
				//system.schedule('ShareContentsSchedulerTest', sch, p);
		
				UnshareOnEffectiveDateSchedulable  u = new UnshareOnEffectiveDateSchedulable		();
	
				//system.schedule('UnShareContentsSchedulerTest', sch, u);
			}catch(Exception e){
	    		System.debug(e.getMessage());
	    	}
			Test.stopTest();
     }  

}