/**
  * Apex Class: IntranetResourcesComponentController
  * Description: This class is used to get Intranet chatter information. (T-97451) 
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 26th Nov 2012.
*/
public with sharing class IntranetResourcesComponentController {
    
    private static final list<String> NOT_INCLUDED_LIBRARIES = new List<String>{'*VX Master'};
    public static final string NAME_PRAM = 'name';
    public User currentUser {get; set;}
    public String lib{get;set;}
    public string selectedLib {
        get{
            if(ApexPages.currentPage().getParameters().get(NAME_PRAM) != null)
                return  ApexPages.currentPage().getParameters().get(NAME_PRAM);
            else    
                return lib; 
        }
        set;
    }
    /*
    * This will fetch the library contents that will
    * we used in pages which use resource component.
    */
    public map<String,List<ContentVersion>> libraries{
        get{
         map<String,List<ContentVersion>> libraryMap = new map<String,List<ContentVersion>>();          
         Set<Id> contentDocIds = new Set<Id>();
       //selectedLib = ApexPages.currentPage().getParameters().get(NAME_PRAM);  
       //Fetch current user   
       for(User u :[Select Id, UserPermissionsSFContentUser From User 
                    where Id  =:UserInfo.getUserId()]){
         currentUser = u;               
       }
       //Return if current user has no permission for access of contents
       if(currentUser.UserPermissionsSFContentUser == false){
         return null;
       }     
       
       for(ContentWorkspaceDoc cWDoc :[Select ContentDocumentId 
                                                                   From ContentWorkspaceDoc
                                                                 Where ContentWorkspace.Name =: selectedLib]){
           contentDocIds.add(cWDoc.ContentDocumentId);
            }    
            
          // Fetch library contents.
        for(ContentVersion content : [Select OwnerId, ContentUrl, Title ,IsLatest, ContentDocument.ParentId, 
                                             End_Date__c, ContentDocumentId, Id, Team_Category__c,FileType
                                                        From ContentVersion 
                                                     Where ContentDocument.Id IN :contentDocIds 
                                                     And IsLatest = true
                                                     AND Team__c =: selectedLib 
                                                     
                                            ORDER BY Title]) {
                //manage document by team category                                              
         if(content.Team_Category__c != null){
             if(libraryMap.containsKey(content.Team_Category__c)){
                libraryMap.get(content.Team_Category__c).add(content);
             }else{
                List<ContentVersion> conVersions = new List<ContentVersion>(); 
                conVersions.add(content);
                libraryMap.put(content.Team_Category__c,conVersions);
             }
         }      
        } 
        return libraryMap;
        }
    }
}