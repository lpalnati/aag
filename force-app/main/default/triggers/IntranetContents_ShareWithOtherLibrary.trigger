/*********************************************************************************************************************
Created By     :   Virendra(Appirio)
Date           :   29 Nov 2012
Reason         :   This trigger fires when contentversion update. 
                   To Share  the contents from VX Master and VX Master Secure to other libraries
*********************************************************************************************************************/
trigger IntranetContents_ShareWithOtherLibrary on ContentVersion (after update,before update) {
              
        set<ID> contentDocuments = new Set<ID>();
        Set<ID> documentIds = new Set<ID>();
        map<Id, ContentVersion> createReadingRecordsNewMap;
        map<Id, ContentVersion> createReadingRecordsOldMap;
        set<String> teams = new set<String>();
        static final list<String> masterLibrariesNames = new list<String>{'*VX Master','*VX Master Secure'};
        //get *VX Master and *VX Master Secure libraries
        map<Id,ContentWorkspace> contentsDir = new map<Id,ContentWorkspace>([Select ID from ContentWorkspace Where Name in:masterLibrariesNames]);
              
        if(contentsDir.size() > 0){
            for(ContentVersion ver : trigger.new){
                documentIds.add(ver.ContentDocumentId);
            }           
            for(ContentWorkspaceDoc workspace : [Select Id,ContentDocumentId From ContentWorkspaceDoc
                                                 Where ContentDocumentId IN :documentIds AND ContentWorkspaceId in: contentsDir.keySet()]){
                contentDocuments.add(workspace.ContentDocumentId);  
            }
        }
        
    if(trigger.IsBefore){
    	 
        //Set shared  checkbox depends if record is to be shared 
        for(ContentVersion ver : trigger.new){
          
        	if(ver.End_Date__c <= ver.Start_Date__c ){
        		ver.addError('End date should be greater than Start date');        		
        	}
                 
          // If content is loaded to "VX Master" library, Then validate for share
           if(contentDocuments.contains(ver.ContentDocumentId) && ver.Published__c == false){
                 boolean proceed =true;
                 if(ver.Start_Date__c >datetime.now()){
                        proceed =false;
                 }
                 if(proceed && !trigger.OldMap.get(ver.Id).Published__c){
                     ver.Published__c= proceed;  
                 }
            }else if(contentDocuments.contains(ver.ContentDocumentId) && ver.Published__c == true){
            	if(ver.Start_Date__c >datetime.now()){
                        ver.Published__c= false;
                 }
            }
        }
    }else{
        List<ContentVersion> vxMasterContents = new List<ContentVersion>(); 
        List<Id> lstToDeleteShare = new List<Id>();
        List<Id> existingContentShared = new List<Id> (); 
        List<Id> deleteRRUserRecords = new  List<Id>();  
        for(ContentVersion ver : trigger.new){
            /*
              Check if only the Contents  from VX Master Library
            */
            if(contentDocuments.contains(ver.ContentDocumentId)){
                /*
                  Check if Contents was shared and not Expired to be validate that
                  it should be shared with other libraries or not
                  if Valid record then add to be share 
                  Else
                  if was previously shared and Expired now then add to the delete List 
                */
                if(ver.Published__c && ver.End_Date__c >datetime.now() ){
                    if(trigger.OldMap.get(ver.Id).Published__c){
                        existingContentShared.add(ver.ContentDocumentId);
                    }
                  vxMasterContents.add(ver);
                }else if(trigger.OldMap.get(ver.Id).Published__c && ver.End_Date__c <= datetime.now()){
                  lstToDeleteShare.add(ver.ContentDocumentId);  
                }
                
                // If StartDate changed to future Date/time delete the other shared 
                if((trigger.OldMap.get(ver.Id).Published__c && !ver.Published__c) || (trigger.OldMap.get(ver.Id).Team__c != ver.Team__c)){
                  lstToDeleteShare.add(ver.ContentDocumentId);
                    /*
                      Delete RR records only if start date is in future 
                    */
                    if(ver.start_Date__c > Datetime.now()){
                  		deleteRRUserRecords.add(ver.Id);  
                    } 
                }
                   
            }
        }
        
        //Create map for the contents  shared with other libraries 
        Map<Id,Set<Id>> conentWorkspaceSharedMap = new Map<Id,Set<Id>>();
        if(!existingContentShared.isEmpty()){
            for(ContentWorkspaceDoc wSpace :[select ContentDocumentId,ContentWorkspaceId,id from ContentWorkspaceDoc where ContentDocumentId in :existingContentShared
                                             and  ContentWorkspaceId  not in:contentsDir.keySet()]){
                if(conentWorkspaceSharedMap.containsKey(wSpace.ContentDocumentId)){
                    conentWorkspaceSharedMap.get(wSpace.ContentDocumentId).add(wSpace.ContentWorkspaceId);
                }else{
                    Set<Id> workspaceShared = new Set<Id>();
                    workspaceShared.add(wSpace.ContentWorkspaceId);
                    conentWorkspaceSharedMap.put(wSpace.ContentDocumentId,workspaceShared);
                }                                               
            }
                                     
        }
        if(!lstToDeleteShare.isEmpty()){
            /*
              Delete the Content Share which has been expired 
            */
             for(List<ContentWorkspaceDoc> lstdel:[Select id from ContentWorkspaceDoc where ContentDocumentId in:lstToDeleteShare And ISOwner = false])
                delete lstdel;
                
           /*
             Delete Intranet Required Reading records if Content unshared from team  
           */     
           if(!deleteRRUserRecords.isEmpty()){
           	 for(List<Intranet_Required_Reading__c> lstdelRR:[Select id from Intranet_Required_Reading__c where ContentVersionID__c in:deleteRRUserRecords])
                delete lstdelRR;
           }
        }
        Set<String> setLibId = new Set<String>();
        List<string> conditionList = new List<string> ();
            for(ContentVersion ver : vxMasterContents){
               if(ver.Team__c!=null){
                 setLibId.add(ver.Team__c);
               }
            }
            list<ContentWorkspaceDoc> listContentWorkspaceDoc = new list<ContentWorkspaceDoc >();
            if(vxMasterContents.size()>0){
               map<String,String> mapWorkSpaceIdName = new map<String,String>();
               for(ContentWorkspace content :[Select Name, Id From ContentWorkspace where Name in :setLibId]){
                    string cId = content.Id;
                    mapWorkSpaceIdName.put(content.Name.toLowerCase(),cId);
               }
               createReadingRecordsNewMap = new map<Id, ContentVersion>();
               createReadingRecordsOldMap = new map<Id, ContentVersion>(); 
               for(ContentVersion ver : vxMasterContents){
                    if(ver.Team__c!=null){
                        string lib = ver.Team__c;
                        if(mapWorkSpaceIdName.get(lib.toLowerCase())!=null){
                              if(!(conentWorkspaceSharedMap.containsKey(ver.ContentDocumentId) && 
                                   conentWorkspaceSharedMap.get(ver.ContentDocumentId).contains(mapWorkSpaceIdName.get(lib.toLowerCase())))){
                                   /* 
                      	             Creat new content sharing record as per selected Libraries 
                                   */
                                   ContentWorkspaceDoc wSpace = new ContentWorkspaceDoc();
                                   wSpace.ContentDocumentId = ver.ContentDocumentId;
                                   wSpace.ContentWorkspaceId = mapWorkSpaceIdName.get(lib.toLowerCase());
                                   listContentWorkspaceDoc.add(wSpace);
																}		
                               }
                               /*
                               Check if library share to be remove 
                               */
                               if(conentWorkspaceSharedMap.containsKey(ver.ContentDocumentId)){
                                   conentWorkspaceSharedMap.get(ver.ContentDocumentId).remove(mapWorkSpaceIdName.get(lib.toLowerCase()));
                                }
                                /*
                                 populated new and old map of valid contents to be used to create/update RR records
                                */
															 	createReadingRecordsNewMap.put(ver.Id,ver);
																createReadingRecordsOldMap.put(ver.Id,trigger.oldMap.get(ver.Id));
                                
                        }
                    }
                }            
            
            List<Id> delLibrariesSharedRecord = new List<Id>(); 
            List<ContentWorkspaceDoc> delRecrods = new List<ContentWorkspaceDoc>();
            /* Findout the workspace id (Libraries to be removed )
            * from sharing record 
            */
            for(Id key:conentWorkspaceSharedMap.keySet()){
                for(Id libId:conentWorkspaceSharedMap.get(key)){
                    delLibrariesSharedRecord.add(libId);
                }
            }
            
            if(!delLibrariesSharedRecord.isEmpty()){
                List<Id> delWorkSpaceDocs = new List<Id> (); 
                /*
                * retrive the Content Workspace Docs to be delete on updates 
                * using ContentDocumentIds and Library Ids
                */
                for(ContentWorkspaceDoc lstdel:[Select id , ContentDocumentId,ContentWorkspaceId from ContentWorkspaceDoc where ContentDocumentId in:conentWorkspaceSharedMap.keySet()
                                                      And ISOwner = false and ContentWorkspaceId in:delLibrariesSharedRecord]){
                   if(conentWorkspaceSharedMap.containsKey(lstdel.ContentDocumentId) &&
                        conentWorkspaceSharedMap.get(lstdel.ContentDocumentId).contains(lstdel.ContentWorkspaceId)){
                            delRecrods.add(lstdel);
                   }       
                }
            }
           
            if(!delRecrods.isEmpty()){
                delete delRecrods;
            }
            if(!listContentWorkspaceDoc.isEmpty()) {
                insert listContentWorkspaceDoc;
            }
            if(createReadingRecordsNewMap != null && !createReadingRecordsNewMap.isEmpty()){
               	Content_Sharing_Required_Readings.createRequiredReadingSharRecords(createReadingRecordsOldMap,createReadingRecordsNewMap);
            }   
    }
}