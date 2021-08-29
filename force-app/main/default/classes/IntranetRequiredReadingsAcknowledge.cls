/*******************************************************************
* Author        :  Virendra 
* Name          :  IntranetRequiredReadingsAcknowledge
* Date          :  January 10,2013
* Description   :  Controller for  IntranetRequiredReadingsAcknowledge page      
* Modified By   :  Ashish Sharma            
* Modified Date :  28th October, 2014
* Ref.          :  T-328428
*******************************************************************/
public with sharing class IntranetRequiredReadingsAcknowledge {
   
   public Intranet_Required_Reading__c requiredReadingRecord{get;set;}
   public ContentVersion contentVer{get;set;}
   public boolean isMarkComplete{get;set;}
   public Boolean isMenuAndSearchBarShow {get;set;}
    
   public IntranetRequiredReadingsAcknowledge(){
       /*
         Get the Parameter passed by previous page's complete Action to
         be show the details on Page 
       */
        isMarkComplete = false; 
        String rrId = ApexPages.currentPage().getParameters().get('rrId');
        showRRDetails(rrId);
        isMenuAndSearchBarShow = true;
        //hide menu and serch bar on page for selected profiles mentioned in custom setting                             
                if(Intranet_Config__c.getInstance('Profile_Ids_For_Hide_MenuBar') != null)                              
                isMenuAndSearchBarShow = (Intranet_Config__c.getInstance('Profile_Ids_For_Hide_MenuBar').Value__c).containsIgnoreCase(Userinfo.getProfileId()) ? false:true;
   }
   
   public void showRRDetails(String rrId){
      /*
        Get Record as per given Id from Required reading record 
      */
      requiredReadingRecord = [Select Name,Id,Due_Date__c,ContentVersionID__c,Complete_Date__c,User_ID__c,createdDate,Comments__c
                                             From Intranet_Required_Reading__c where  id =:rrId limit 1];
      
      contentVer = [Select id ,description, title,FileType,ContentUrl,ContentDocumentId, Additional_Notes__c from contentVersion where id =:requiredReadingRecord.ContentVersionID__c limit 1];
   }
   
   public Pagereference markComplete(){
      requiredReadingRecord.Complete_Date__c = System.now();
      if(isMarkComplete == true && requiredReadingRecord != null) {
        Intranet_Required_Reading_History__c intranetHistory = new Intranet_Required_Reading_History__c();
        intranetHistory.Name= requiredReadingRecord.name;
                intranetHistory.Due_Date__c = requiredReadingRecord.Due_Date__c; 
                intranetHistory.ContentVersionID__c = requiredReadingRecord.ContentVersionID__c; 
                intranetHistory.Complete_Date__c = System.now();
                intranetHistory.User_ID__c = requiredReadingRecord.User_ID__c;
                intranetHistory.Comments__c = requiredReadingRecord.Comments__c;
                update requiredReadingRecord;
                insert intranetHistory;
        return new Pagereference('/apex/IntranetRequiredReadings');
      }else{
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please mark checkbox before continue.'));
        return null;
      }
   }
   
   public Pagereference cancelAction(){
      return new Pagereference('/apex/IntranetRequiredReadings');
   }
   
}