/**
  * Apex Class: IntranetSearchControllerTest
  * Description: test class for IntranetSearchController
  * Created By: kenji
  * Created Date: 12/05/2012
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : 12/24/2012
  * RealetedTo :  T-106113-Test search configuration via intranet config custom setting
*/
@isTest 
private class IntranetSearchControllerTest {

static testMethod void testSearch() {
        Search_Config__c seachConfigAccount = TestUtil.createSearchConfig(false, 'Account', true, 'Account');
        Search_Config__c seachConfigArticle = TestUtil.createSearchConfig(false, 'Article', true, 'Intranet_Article__c');
        Search_Config__c seachConfigUser = TestUtil.createSearchConfig(false, 'ChatterUser', true, 'User');
        Search_Config__c seachConfigPost = TestUtil.createSearchConfig(false, 'ChatterPost', true, 'FeedItem');
        Search_Config__c seachConfigContent = TestUtil.createSearchConfig(false, 'Content', true, 'ContentVersion');
        Search_Config__c seachConfigPage = TestUtil.createSearchConfig(false, 'CMS Pages', true, 'Intranet_CMS_Page__c');
        Intranet_Config__c intranetCategoryLimit = TestUtil.createIntranetConfig(true, 'Search Limit', '100');
        Intranet_Config__c intranetPaginationLimit = TestUtil.createIntranetConfig(true, 'Search Pagination', '10');
        
        list<Search_Config__c> listSearchConfing = new list<Search_Config__c>{seachConfigAccount, seachConfigArticle, seachConfigUser, seachConfigPost, seachConfigContent, seachConfigPage};
        insert listSearchConfing;
        
        system.assertEquals(IntranetSearchController.categoryLimit, 100);
        system.assertEquals(IntranetSearchController.paginationLimit, 10);
        
        //array for holding the Ids of objects that will be returned from the SOSL query
        list<id> fixedSearchResults= new list<id>();
        
        //get a list of searchable objects
        map<string,string> objectsList = IntranetSearchController.getSearchableObjects();

        //create an account
        Account testAccount = new Account();
        testAccount.name = 'Production Test';
        insert testAccount;
        
        fixedSearchResults.add(testAccount.id);    
         
        //create a user
        User createUser;
    
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Profile p = [select id from profile where name = 'System Administrator'];
            createUser = TestUtil.createUser(true);
            fixedSearchResults.add(createUser.id);    
        }
               
        ContentVersion testContentInsert =new ContentVersion(); 
 				testContentInsert.ContentURL='http://www.google.com/'; 
  	    testContentInsert.Title ='Google.com'; 
				insert testContentInsert;
				fixedSearchResults.add(testContentInsert.id);  
				/*
        //create a chatter post
        FeedItem fitem = new FeedItem();
        fitem.type = 'TextPost';
        fitem.ParentId = UserInfo.getUserId();
        fitem.Title = 'Test';  //This is the title that displays for the LinkUrl
        fitem.body = 'Production deploy test';

        insert fitem;     
        
        fixedSearchResults.add(fItem.id); 
        */
        Intranet_Article__c article1 = TestUtil.createArticle(true);
        Intranet_Article__c article2 = TestUtil.createArticle(false); 
        article2.Article_Type__c ='External';
        article2.URL__c='http://www.virginamerica.com/';
        article2.Name = 'Production test';
        insert article2;    
        fixedSearchResults.add(article1.id); 
        fixedSearchResults.add(article2.id); 
        
        Intranet_CMS_Page__c page = TestUtil.createContent(true);
        Intranet_CMS_Page__c page1 = TestUtil.createContent('testContent1', false, page.Id, 'Home');
        Intranet_CMS_Page__c page2 = TestUtil.createContent('testContent2', false, null, 'Interior Home');
        Intranet_CMS_Page__c page3 = TestUtil.createContent('testContent3', false, null, 'Team');
        Intranet_CMS_Page__c page4 = TestUtil.createContent('Production4', false, null, 'Content');
        insert new list<Intranet_CMS_Page__c>{page1,page2,page3,page4};
        fixedSearchResults.add(page.id);
        fixedSearchResults.add(page1.id);
        fixedSearchResults.add(page2.id);
        fixedSearchResults.add(page3.id);
        fixedSearchResults.add(page4.id);
        
        string[] objectsToSearch = new  string[]{'Account','Intranet_Article__c','User','FeedItem','ContentVersion','Intranet_CMS_Page__c'};
        map<string,string> labels = new map<string,string>();
        labels.put('Account','Clients');
        
        //set the results of the SOSL query
        Test.setFixedSearchResults(fixedSearchResults);
        
        map<string,list<IntranetSearchController.searchResult>> searchResults = IntranetSearchController.globalSearch('test*', false, objectsToSearch ,labels, 20);  
           
        system.assertEquals(searchResults.containsKey('Account'),true,'Custom label key for accounts not found!');
        
        system.assertEquals(searchResults.get('Account').size(),1,'Unexpected amount of accounts returned for search');
        
        system.assertEquals(searchResults.get('Content').size(),1,'Unexpected amount of ContentVersion objects (CRM content) returned for search');
        
        system.assertEquals(searchResults.get('ChatterUser').size(),1,'Unexpected amount of User records returned for search'); 
        
        //system.assertEquals(searchResults.get('ChatterPost').size(),1,'Unexpected amount of FeedItem records returned for search'); 
        
        system.assertEquals(searchResults.get('Article').size(),2,'Unexpected amount of article records returned for search');     
        
        system.assertEquals(searchResults.get('CMS Pages').size(),5,'Unexpected amount of page records returned for search');         
    }
}