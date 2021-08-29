/*********************************************************************************************************************
Created By     :   Virendra(Appirio)
Date           :    29 Nov 2012
Reason         :    This batchable class used in scheduler  if time is a future value then we will let the batch scheduler pick up the docs and share
                    To Share  the contents from VX Master to other libraries
*********************************************************************************************************************/
global class IntranetPublishOnEffectiveDateBatchable implements Database.Batchable<sObject>{

   global Database.QueryLocator start(Database.BatchableContext BC){
      DateTime currentDateTime = DateTime.now();
      return Database.getQueryLocator('Select Id, Published__c from ContentVersion Where Start_Date__c  <=:currentDateTime'+
                                      '  AND Published__c=False  AND IsLatest = TRUE and End_Date__c >:currentDateTime');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
     for(sobject s : scope){
         s.put('Published__c',true); 
     }
     update scope;
   }

   global void finish(Database.BatchableContext BC){

   }
}