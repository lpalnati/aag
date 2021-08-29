/*********************************************************************************************************************
Created By     :   Virendra(Appirio)
Date           :    29 Nov 2012
Reason         :    This batchable class used in scheduler  if End Date reached will let the batch scheduler pick up the docs and UnShare
                    To Unshare the contents from  other libraries
*********************************************************************************************************************/
global class IntranetUnShareOnEffectiveDateBatchable implements Database.Batchable<sObject>{
   global Database.QueryLocator start(Database.BatchableContext BC){
   	  DateTime currentDateTime = DateTime.now();
      return Database.getQueryLocator('Select Id, Published__c from ContentVersion Where End_Date__c <=:currentDateTime'+
                                      ' AND Published__c=true  AND IsLatest = TRUE');
   }
   global void execute(Database.BatchableContext BC, List<sObject> scope){
     for(sobject s : scope){
         s.put('Published__c',false); 
     }
     update scope;
   }
   global void finish(Database.BatchableContext BC){

   }
}