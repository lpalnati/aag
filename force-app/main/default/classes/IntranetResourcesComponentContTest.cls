/*******************************************************************************
Created By     :   Suraj Rajoria(Appirio Offshore)
Date           :   15 Dec 2012
Description    :   To test resource component page
Class Name     :   IntranetResourcesComponentContTest
*******************************************************************************/
@isTest(seeAllData = true)
private class IntranetResourcesComponentContTest {

   static testMethod void testContentLibAsCMSPageObj() {  
        // TO DO: implement unit test
        ContentWorkSpace cwMaster = [Select Id from ContentWorkSpace where Name like '%VX Master'];
        ContentWorkspace lib = [Select c.Id,c.Name From ContentWorkspace c where NOT(Name like '%VX Master') limit 1];
        
        //create ContentVersion instance
        ContentVersion doc = new ContentVersion(); 
        Blob beforeblob = Blob.valueOf('Testing base 64 encode');
        doc.VersionData = beforeblob;       
        doc.Title = 'title1';
        doc.PathOnClient = 'xyz';        
        doc.FirstPublishLocationId = cwMaster.id; 
        doc.Start_Date__c = System.now();
        doc.Team__c = lib.name;
        doc.Team_Category__c = 'Hotel discount';
        doc.End_Date__c = System.now().addMinutes(60);
        insert doc;
        
        //Share document with one available library.
        ContentWorkspaceDoc shareDoc = new ContentWorkspaceDoc ();
        shareDoc.ContentDocumentId = [Select c.ContentDocumentId From ContentVersion c where Id =: doc.id].ContentDocumentId;
        shareDoc.ContentWorkspaceId = lib.Id;
        
        try{
        	insert shareDoc;  
        
        }catch(Exception e){
        	System.debug(e.getMessage());
        }
        //Check the content inserted
        System.assert(doc.Id != null);
	       
	       Test.setCurrentPage(Page.IntranetTeam);
	       ApexPages.currentPage().getParameters().put('name',lib.name);     
	       IntranetResourcesComponentController intraResource = new IntranetResourcesComponentController();
	       system.assert(intraResource.libraries.size() >= 1);
	       system.assertEquals(intraResource.selectedLib,lib.name); 
	            
    }
}