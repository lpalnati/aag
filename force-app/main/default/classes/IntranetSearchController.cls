/* Sherlock Salesforce Gloabl Search Utility Controller
Description: Sherlock is a Salesforce search replacment utility that can perform full text searches against any searchable object, including
             searching the content of uploaded content documents and chatter posts. The interface is provided via a jQuery plugin on a visualforce page.
Author: Daniel Llewellyn/Kenji776 (@Kenji776)
Date: 12/05/2012
*/

global class IntranetSearchController {
    //wrapper object to standardize search results. The search program expects to receivea list of these. 
    //all the data found from the original sObject is included as well in the objectData property
    global class searchResult
    {
        string thumbnail = '';
        string title = '';
        string description = '';
        string link = '';
        integer size = 0;
        string type = '';
        id recordId;
        sObject objectData;
        String startDate = '';
    }
    
        //By this field Tab would be selected on intranetPages 
    global static String tabName {get; set;}
    //This map is used to identified top level parent of CMS pages.
    global static map<String, String> parentTabMap {get;set;}
    //By this field category limit will be decided on each object. 
    global static final Integer categoryLimit {get; set;}
    //By this field no of records will be decided to show on Search page 
    global static final Integer paginationLimit {get; set;}
    //Key prefix of Intranet_Article__c object
    private static final String IntranetArticleKeyPrefix {get; set;}
        
		static {
		        //Initialize final varibles to decide search configuration
		        for(Intranet_Config__c searchConfig : [Select Value__c, Name From Intranet_Config__c]) {
		        if(searchConfig.Name == 'Search Limit') {
		            categoryLimit = Integer.valueOf(searchConfig.value__c);
		        }
		        if(searchConfig.Name == 'Search Pagination') {
		            paginationLimit = Integer.valueOf(searchConfig.value__c);
		        }           
		    }
		    IntranetArticleKeyPrefix = Schema.getGlobalDescribe().get('Intranet_Article__c').getDescribe().getKeyPrefix();
		}
     
    /*remote method to be accessed via javascript for performing a search.
      arguments
          searchTerm: a string at least two characters long (not including wildcards) to search for
          objectList: a list/array of sObject names which to query for
          objectLabels: a map/javascript object of sObject names to a friendly label to use in the result. Multiple sObjects can have the same label and will be returned in the same group.
          typeLimit: a maxmimum amount of each kind of object to find. This is per sObject type, not per label or for the total search.  
    */ 
    @RemoteAction
    global static map<string,list<searchResult>> globalSearch(string searchTerm,boolean isMobile,list<string>objectList,map<string,string> objectLabels, integer typeLimit)
    {
        //map to hold the results. The results will have the objectLabels or names (if no label for that object type is provided) and a list of search results for it.
        map<string,list<searchResult>> results = new  map<string,list<searchResult>>();
        map<String, boolean> isIncludedInSearchMap = new map<String,Boolean>();
        parentTabMap = new map<String,String>();
        try
        { 
            //string to hold the SOSL querystring.
            string customObjectQuery = '';
            objectLabels = new map<string,string>();
            //Custom setting that decide wheather object included in search or not.
            for(Search_Config__c searchConfig : [Select s.Object_API_Name__c, s.Name, s.IsDisplay__c From Search_Config__c s]) {
                isIncludedInSearchMap.put(searchConfig.Object_API_Name__c, searchConfig.IsDisplay__c);
                objectLabels.put(searchConfig.Object_API_Name__c, searchConfig.Name);
            }
            
            //for each object passed in, build a querystring addition that should be safe in all circumstances
            for(string obj : objectList)
            {
                if(obj == 'Intranet_Article__c' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += obj+'(Name,Id,URL__c,Article_Type__c,Summary__c,createdById,CreatedDate,Start_Date__c WHERE Start_Date__c <= '+ System.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'') +' AND End_Date__c >= '+ System.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'') +' order by Start_Date__c LIMIT '+typeLimit+'),';
                }else if(obj == 'Intranet_CMS_Page__c' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += obj+'(Name,Id,Template__c,Skip_Menu_Link__c,URL__c,createdById,CreatedDate WHERE Status__c = \'Published\' order by Name LIMIT '+typeLimit+'),';
                }else if(obj == 'FeedItem' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += obj+'(id, title, body, InsertedBy.Name, InsertedById, CreatedDate, ParentId order by CreatedDate DESC LIMIT '+typeLimit+'),';
                }else if(obj == 'ContentVersion' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += obj+'(ContentDocumentId,ContentSize,ContentUrl,Description,IsLatest,PublishStatus,TagCsv,Title,FileType,Id order by RatingCount DESC LIMIT '+typeLimit+'),';
                }else if(obj == 'User' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += obj+'(id, name, SmallPhotoUrl, email order by Name LIMIT '+typeLimit+'),';
                }else if(isIncludedInSearchMap.get(obj) == true){
                    customObjectQuery += obj+'(Name,Id,createdById,CreatedDate LIMIT '+typeLimit+'),';                
                }
            }
            
            //append the last of the information we need to our querystring, including stuff for finding documents, feed items and users.
            string objectsQuery = 'FIND \''+searchTerm+'\' IN ALL FIELDS RETURNING '+customObjectQuery.subString(0, customObjectQuery.length()-1);
            
            if(objectsQuery.contains('Intranet_CMS_Page__c')) {
                //Populate child parent relationship map if Intranet_Article__c object included in search
                    for(Intranet_CMS_Page__c CMSPage : [Select Id, Parent_page__c,URL__c, Parent_page__r.Name,
                                                   Skip_Menu_Link__c, Name,Template__c, Sequence__c,Target__c
                                              from Intranet_CMS_Page__c 
                                             where Status__c = 'Published' 
                                          order by Parent_page__c,Sequence__c ]) {
                            parentTabMap.put(CMSPage.Name, CMSPage.Parent_page__r.Name);
                        }
            }
            //find all objects where the name matches the search term.
            List<List<SObject>> searchList = search.query(objectsQuery);
            string objType = '';
            string objLabel = '';
            
            //iterate over all the search results so we can build searchResult items from them.
            //the search result is broken in a list of sObjects, each of which contain a list of results. 
            //similar to how we want to evenetually return the data, but we gotta do some formatting to it first.
            for(List<sObject> thisObjList : searchList)
            {
                for(sObject thisObj : thisObjList)
                {
                    //create a new search result object.
                    searchResult thisResult = new searchResult();
                    //find the sObject type of this object.
                    objType = string.valueOf(thisObj.getsObjectType());
                    objLabel = objType;
                    
                    //set some default information that all returned objects should have.
                    thisResult.type = objType;
                    thisResult.recordid = (id) thisObj.get('Id');
                    thisResult.link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + (string) thisObj.get('Id');
                    thisResult.objectData = thisObj;
                    
                    //if a label for this object type was provided set it now. Otherwise the name of the object is also the label.
                    if(objectLabels.containsKey(objType))
                    {
                        objLabel = objectLabels.get(objType);
                    }
                    
                    //if this result is a content version object then set its properties accordingly.            
                    if(objType == 'ContentVersion')
                    {
                        thisResult.title = (string) thisObj.get('Title');
                        thisResult.description = (string) thisObj.get('Description');
                        thisResult.link = ((string) thisObj.get('FileType') == 'LINK') ? (string) thisObj.get('ContentUrl') : (isMobile == true ? '/sfc/servlet.shepherd/version/download/'+(string) thisObj.get('Id')+'?asPdf=false&amp;operationContext=CHATTER' : URL.getSalesforceBaseUrl().toExternalForm() + '/' +(string) thisObj.get('ContentDocumentId'));
                        thisResult.recordid = (id) thisObj.get('ContentDocumentId');
                        thisResult.size = (integer) thisObj.get('ContentSize');
                    }
                    
                    //if this result is a user object then set its properties accordingly, including setting the photo
                    else if(objType == 'User')
                    {
                        thisResult.thumbnail = (string) thisObj.get('SmallPhotoUrl');
                        thisResult.title = (string) thisObj.get('name');  
                        thisResult.link = (isMobile == true)? 'javascript:void(0);' : thisResult.link;                                   
                    }
                    
                    //if this result is a content version object then set its properties accordingly, including getting the posting users name to 
                    //use for the title.  
                    else if(objType == 'FeedItem')
                    {    
                        //do not considered Intranet article feed.
                        if(((String) thisObj.get('ParentId')).startsWith(IntranetArticleKeyPrefix)) {
                            continue;
                        }else {
                            sObject postingUser = thisObj.getsObject('insertedBy'); 
                            thisResult.title = (String) postingUser.get('Name');
                            thisResult.description = (((string) thisObj.get('body')) != null && ((string) thisObj.get('body')).endsWith('.')) ? (string) thisObj.get('body') : (string) thisObj.get('body') + '.';
                            thisResult.startDate =  'Posted on ' + ((DateTime) thisObj.get('CreatedDate')).format('MMMM d, yyyy hh:mm:ss a', 'PST');
                            thisResult.link = (isMobile == true)? 'javascript:void(0);' : thisResult.link;
                        }
                    }
                    
                    //if this result is a Intranet Article object then set its properties accordingly, including getting the link 
                    //where it is landing
                    else if(objType == 'Intranet_Article__c')
                    {    
                        thisResult.title = (string) thisObj.get('Name');
                        thisResult.description = (string) thisObj.get('Summary__c');
                        thisResult.startDate = ((DateTime) thisObj.get('Start_Date__c')).format('MMMM d, yyyy hh:mm:ss a', 'PST');
                        if((string) thisObj.get('Article_Type__c') == 'External') {
                            thisResult.link = '/apex/IntranetRouter?id=' + (string) thisObj.get('Id') + '&type=Intranet_Article__c&path='+Encodingutil.urlEncode((string) thisObj.get('URL__c'),'UTF-8');
                        } else {
                            thisResult.link = '/apex/IntranetRouter?id=' + (string) thisObj.get('Id') + '&type=Intranet_Article__c&path='+Encodingutil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/IntranetContent?id=' + (string) thisObj.get('Id') + '&category=News&tabName=Home', 'UTF-8');
                        }
                    }
                    
                    //if this result is a Intranet CMS Pages object then set its properties accordingly, including getting the link 
                    //where it is landing
                    else if(objType == 'Intranet_CMS_Page__c')
                    {   
                        thisResult.title = (string) thisObj.get('Name');
                        if(thisObj.get('Skip_Menu_Link__c') != true) {
                        	if((string) thisObj.get('URL__c') != null) {
                            thisResult.link = '/apex/IntranetRouter?Id='+(string) thisObj.get('Id')+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode((string) thisObj.get('URL__c'), 'UTF-8');
                            }else {
	                            if((string) thisObj.get('Template__c') == 'Home') {
	                                thisResult.link = '/apex/IntranetRouter?Id='+(string) thisObj.get('Id')+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetHome', 'UTF-8');
	                            }else if((string) thisObj.get('Template__c')  == 'Interior Home') {
	                                thisResult.link = '/apex/IntranetRouter?Id='+(string) thisObj.get('Id')+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetHome?tabName='+(string) thisObj.get('Name'), 'UTF-8');
	                            }else if((string) thisObj.get('Template__c')  == 'Team') {
	                                getParentpageName((string) thisObj.get('Name'));
	                                thisResult.link = '/apex/IntranetRouter?Id='+(string) thisObj.get('Id')+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetTeam?&name='+(string) thisObj.get('Name')+'&tabName='+tabName , 'UTF-8');
	                            }else if((string) thisObj.get('Template__c')  == 'Content') {
	                                    getParentpageName((string) thisObj.get('Name'));
	                                thisResult.link = '/apex/IntranetRouter?Id='+(string) thisObj.get('Id')+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetContent?Id=' + (string) thisObj.get('Id') + '&category=Content&tabName='+tabName, 'UTF-8');
	                            }else if((string) thisObj.get('Template__c')  == 'Secure') {
	                                getParentpageName((string) thisObj.get('Name'));
	                                thisResult.link = '/apex/IntranetRouter?Id='+(string) thisObj.get('Id')+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetSecuredTeam?&name='+(string) thisObj.get('Name')+'&tabName='+tabName , 'UTF-8');
	                            }else if((string) thisObj.get('Template__c')  == 'Contractor') {
	                                getParentpageName((string) thisObj.get('Name'));
	                                thisResult.link = '/apex/IntranetRouter?Id='+(string) thisObj.get('Id')+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetContractor?&name='+(string) thisObj.get('Name')+'&tabName='+tabName , 'UTF-8');
	                            }
                             }
                          }else {
                             thisResult.link = 'javascript:void(0);';    
                          }
                    }
                    
                    //if it is any other object type, then just grab the name and set it as the title. You could also set some kind of description here, maybe
                    //including the created date or something.
                    else
                    {
                        thisResult.title = (string) thisObj.get('Name');             
                    }
                    
                    
                    //append this search result to the proper list using the object label as the key to find the right list.
                    if(!results.containsKey(objLabel))
                    {
                        results.put(objLabel,new list<searchResult>());
                    }
                        results.get(objLabel).add(thisResult);
                }
            }                          
        }
        catch(Exception e)
        {
        }
        return results;
    }
    
    /*  
        method is used to find Top level parent of Selected CMS Page
        Argument:
            PageName : a CMS page name for which top level parent required.
    */
    private static void getParentpageName(String pageName) {
        tabName = pageName;
        if(parentTabMap.get(pageName) != null) {
            getParentpageName(parentTabMap.get(pageName));
        }
    }
    
    //function for finding all the objects in this org that can be searched for. This includes custom objects
    //returns them as a map of the object label to the object name. Meant to be invoked via the interface at runtime.
    @remoteAction
    global static map<string,string> getSearchableObjects()
    {
        //list of object labels and names to return
        map<string,string> searchableObjects = new map<string,string>();
        
        //global describe of all objects in the org.
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        
        //iterate over all objects
        for(string objType : gd.keySet())
        {
            //only add this object type if it is searchable, since this list will be used to create an interface
            //where the user can select which objects to search. No sense in including non searchable objects eh?
            if(gd.get(objType).getDescribe().isSearchable())
            {
                searchableObjects.put(gd.get(objType).getDescribe().getLabel(),objType);
            }
        }
        return searchableObjects;
    }
}