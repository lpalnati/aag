/*********************************************************************************************************************
Created By     :   Harshit Jain(Appirio off)
Date           :   Jan 22, 2013
description    :   This trigger deletes all related required reading custom records on deletion of content document.
*********************************************************************************************************************/
trigger IntranetRemoveRequiredReadings on ContentDocument (after delete) {
    list<Intranet_Required_Reading__c> deletedRRRecordsList = new list<Intranet_Required_Reading__c>();
    Set<ID> ContentVersionIDs = new Set<ID>();
    
    for(ContentDocument conDoc:trigger.old){
   	    ContentVersionIDs.add(conDoc.LatestPublishedVersionId);
    }
  
    for(Intranet_Required_Reading__c RRRecord : [select Id from Intranet_Required_Reading__c where ContentVersionID__c in:ContentVersionIDs]){
        deletedRRRecordsList.add(RRRecord);
    }   
        
    if(!deletedRRRecordsList.isEmpty()){
        delete deletedRRRecordsList;
    }
}