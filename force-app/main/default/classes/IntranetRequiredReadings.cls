/*******************************************************************
* Author        :  Virendra 
* Name          :  IntranetRequiredReadings
* Date          :  January 09,2013
* Description   :  Controller for  IntranetRequiredReadings page     
* Modified By   :  Ashish Sharma
* Modified Date :  27th October, 2014
* Ref.          :  T-328420  
* Modified By   :  Ashish Sharma
* Modified Date :  30th October, 2014
* Ref.          :  T-329191              
*******************************************************************/
public with sharing class IntranetRequiredReadings {
	//String hold page name selected by current user on Intranet. 
	public String pageName {get;set;}
	
	public List<Intranet_Required_Reading__c> unreadIntranetRequiredReadings {get;set;}
	public List<Intranet_Required_Reading__c> readIntranetRequiredReadings {get;set;}
	
	public Integer numRows {get; set;} // Number of rows to be outputted
	public Integer pageSize {get; set;} // Number of rows per page
	
	public Integer numRowsReadRR {get; set;} // Number of rows to be outputted
	public Integer pageSizeReadRR {get; set;} // Number of rows per page
	

	public List<Row> rows {get;set;} // Holds all of the Rows
	public Integer currentPage {get; set;} // Holds which page is currently being displayed
	
	public List<Row> rowsReadRR {get;set;} // Holds all of the Rows
	public Integer currentPageReadRR {get; set;} // Holds which page is currently being displayed
	public Boolean isMenuAndSearchBarShow {get;set;} // 
	
	public String completeRRId{get;set;}
	public ContentVersion versionDataforUI{get;set;}
	public String currentRowId{get;set;}
	
	public IntranetRequiredReadings() {
		isMenuAndSearchBarShow = true;
		//Default selected page would be home page
		pageName = 'Home';
		//Populate selected page name.
		//Based on selected page name other information will be populated on intranet page like Banners,Articles,Links etc.
		if(ApexPages.currentPage().getParameters().get('tabName') != null) {
			pageName = ApexPages.currentPage().getParameters().get('tabName');
		}
		unreadIntranetRequiredReadings = new List<Intranet_Required_Reading__c>();
		readIntranetRequiredReadings = new List<Intranet_Required_Reading__c>();
		currentPage = 1;
		currentPageReadRR = 1;
    	pageSize = 10;
    	pageSizeReadRR = 10;
		
		go();
		
		numRows = unreadIntranetRequiredReadings.size();
		numRowsReadRR = readIntranetRequiredReadings.size();
		//hide menu and serch bar on page for selected profiles mentioned in custom setting
		if(Intranet_Config__c.getInstance('Profile_Ids_For_Hide_MenuBar') != null)		                        
	   	isMenuAndSearchBarShow = (Intranet_Config__c.getInstance('Profile_Ids_For_Hide_MenuBar').Value__c).containsIgnoreCase(Userinfo.getProfileId()) ? false:true;
	}
	
	// Method populates all of the rows. What is displayed on each page will be a subset of this List
    public void setAllRows(){
    	rows = new List<Row>();
    	rowsReadRR = new List<Row>();
    	Set<Id> converdionIds = new Set<id>();
    	for(Intranet_Required_Reading__c rr:[Select User_ID__c,Name,Id,Due_Date__c,ContentVersionID__c,Complete_Date__c,createdDate
		                                     From Intranet_Required_Reading__c where User_ID__c =:Userinfo.getUserId()  order by Due_Date__c limit 100]){
			if(rr.Complete_Date__c == null){
			   unreadIntranetRequiredReadings.add(rr);
			}else{
			   readIntranetRequiredReadings.add(rr);	
			}			
			converdionIds.add(rr.ContentVersionID__c);
		}
		Map<Id,ContentVersion> converMap = new Map<Id,ContentVersion>(); 
		for(ContentVersion content : [Select ContentUrl, ContentDocumentId, Id,FileType From ContentVersion 
		  								 Where IsLatest = true  and id in : converdionIds]) {
	           converMap.put(content.Id,content);           				
	      }
		
    	Row row = new Row();
    	Row rowRR = new Row();
    	
    	Integer counter = 1;
    	for(Intranet_Required_Reading__c rr:unreadIntranetRequiredReadings){
    		row = new Row();
    		row.recordNumber = counter;
    		row.name = rr.name;
    		row.dueDate = rr.Due_Date__c;
    		row.isOverDue = (rr.Due_Date__c < Date.today() ? true: false );
			  row.contentVersion = rr.ContentVersionID__c;
		    row.completeDate = String.valueOf(rr.Complete_Date__c);
		    row.userId = rr.User_ID__c;
		    row.publishDate = String.valueOf(rr.CreatedDate.format('yyyy-MMM-d hh:mm:ss a', 'PST'));
		    row.Id= rr.id;
		    if(converMap.containsKey(rr.ContentVersionID__c)){
		    	ContentVersion conver= converMap.get(rr.ContentVersionID__c);
		    	if(conver.FileType == 'Link'){
		    		row.url = conver.ContentUrl;
		    		row.FileType = conver.FileType;
		    	}else{
		    		row.url = '/'+conver.ContentDocumentId;
		    		row.FileType = conver.FileType;
		    	}
		    }
    		rows.add(row);
    		counter++;
    	}
    	
    	counter = 1;
    	sortList(readIntranetRequiredReadings, 'CreatedDate', 'desc'); 
    	for(Intranet_Required_Reading__c rr:readIntranetRequiredReadings){
    		rowRR = new Row();
    		rowRR.recordNumber = counter;
    		rowRR.name = rr.name;
    		rowRR.dueDate = rr.Due_Date__c;
			  rowRR.contentVersion = rr.ContentVersionID__c;
		    rowRR.completeDate = String.valueOf(rr.Complete_Date__c.format('yyyy-MMM-d hh:mm:ss a', 'PST'));
		    rowRR.userId = rr.User_ID__c;
		    rowRR.publishDate = String.valueOf(rr.CreatedDate.format('yyyy-MMM-d hh:mm:ss a', 'PST'));
		    rowRR.id= rr.id;
		    if(converMap.containsKey(rr.ContentVersionID__c)){
		    	ContentVersion conver= converMap.get(rr.ContentVersionID__c);
		    	if(conver.FileType == 'Link'){
		    		rowRR.url = conver.ContentUrl;
		    		rowRR.FileType = conver.FileType;
		    	}else{
		    		rowRR.url = '/'+conver.ContentDocumentId;
		    		rowRR.FileType = conver.FileType;
		    	}
		    }
    		rowsReadRR.add(rowRR);
    		counter++;
    	}
    	
    }
    
    // Getter for all Rows List
    public List<Row> getAllRows(){
    	return rows;
    }
    
    public static void sortList(List<Sobject> items, String sortField, String order){
     List<Sobject> resultList = new List<Sobject>();
  
     //Create a map that can be used for sorting
     Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();
          
    for(Sobject ob : items){
	    if(objectMap.get(ob.get(sortField)) == null){  // For non Sobject use obj.ProperyName
	        objectMap.put(ob.get(sortField), new List<Sobject>());
	    }
    	objectMap.get(ob.get(sortField)).add(ob);
    }      
    //Sort the keys
    List<object> keys = new List<object>(objectMap.keySet());
    keys.sort();
  
    for(object key : keys){
      resultList.addAll(objectMap.get(key));
    }
  
    //Apply the sorted values to the source list
    items.clear();
    if(order.toLowerCase() == 'asc'){
	    for(Sobject ob : resultList){
	        items.add(ob);
	    }
    }else if(order.toLowerCase() == 'desc'){
	    for(integer i = resultList.size()-1; i >= 0; i--){
	        items.add(resultList[i]); 
	    }
    }
  }
    
    public Pagereference setComplete(){
    	system.debug('::completeRRId::'+completeRRId);
    	return new Pagereference('/apex/IntranetRequiredReadingsAcknowledge?rrId='+currentRowId);
    }
    // Gets all of this pages rows 
    public List<Row> getPage(){
    	List<Row> thisPage = new List<Row>();
    	
    	if(currentPage == null){
    		currentPage = 1;
    	}
    	
    	if(rows.size()<=10){
    		currentPage = 1;
    	}
    	Integer startPoint = ((currentPage - 1) * pageSize);
    	Integer endPoint = (startPoint + pageSize);
        
        if(endPoint>=rows.size()){
        	endPoint = rows.size();
        }
        system.debug(':::Start POint ::'+startPoint+' ::: EndPOint ::'+endPoint);
    	for(Integer i=startPoint;i<endPoint;i++){
    		if(i == rows.size()){
    			break;
    		}else{
    			thisPage.add(rows.get(i));
    		}
    	}
    	system.debug('::thisPage::'+thisPage);
    	return thisPage;	
    }
    
    
     // Gets all of this pages rows 
    public List<Row> getPageRR(){
    	List<Row> thisPageRR = new List<Row>();
    	
    	if(currentPageReadRR == null){
    		currentPageReadRR = 1;
    	}
    	
    	if(rowsReadRR.size()<=10){
    		currentPageReadRR = 1;
    	}
    	
    	Integer startPoint = ((currentPageReadRR - 1) * pageSizeReadRR);
    	Integer endPoint = (startPoint + pageSizeReadRR);
    	
    	if(endPoint>=rowsReadRR.size()){
        	endPoint = rowsReadRR.size();
        }
        
    	for(Integer i=startPoint;i<endPoint;i++){
    		if(i == rowsReadRR.size()){
    			break;
    		}else{
    			thisPageRR.add(rowsReadRR.get(i));
    		}
    	}
    	system.debug('::thisPageRR::'+thisPageRR);
    	return thisPageRR;	
    }
    
    // does nothing other than to give the page link a method to call which will reset the currentPage parameter
    public void setPage(){
    	
    }
    
    public void setNextRR(){
    	 currentPageReadRR++;
    	if(currentPageReadRR*pageSizeReadRR> rowsReadRR.size()){
    		currentPageReadRR--;
    	}   
    }
    
    public void setPrevRR(){
    	if(currentPageReadRR!=1)	
    	currentPageReadRR--;
    }
    
    public void setNext(){
    	currentPage++;
    	if(currentPage*pageSize> rows.size()){
    		currentPage--;
    	}
    }
    
    public void setPrev(){
       if(currentPage!=1)	
    	currentPage--;
    }
    
    // Takes input parameters from user as to what sort of data set and page size to use. 
    public void go(){
    	currentPage = 1;
    	currentPageReadRR = 1;
    	
    	if(numRows == null){
    		numRows = unreadIntranetRequiredReadings.size();
    	}
    	if(pageSize == null){
    		pageSize = 10;
    	}
		
		if(numRowsReadRR == null){
    		numRowsReadRR = readIntranetRequiredReadings.size();
    	}
    	if(pageSizeReadRR == null){
    		pageSizeReadRR = 10;
    	}
		
		setAllRows();
    }
    
    // Get the number of pages based on all of the rows and page size 
    public List<Integer> getPageNumbers(){
    	List<Integer> pageNumbers = new List<Integer>();
    	
    	Integer add = (math.mod(numRows, pageSize) == 0) ? 0 : 1; 
    	Integer numPages = (numRows / pageSize) + add;
    	
    	for(Integer i=1;i<=numPages;i++){
    		pageNumbers.add(i);
    	}
    	return pageNumbers;
    }
    
    // Get the number of pages based on all of the rows and page size 
    public List<Integer> getPageNumbersRR(){
    	List<Integer> pageNumbersRR = new List<Integer>();
    	
    	Integer add = (math.mod(numRowsReadRR, pageSizeReadRR) == 0) ? 0 : 1; 
    	Integer numPages = (numRowsReadRR / pageSizeReadRR) + add;
    	
    	for(Integer i=1;i<=numPages;i++){
    		pageNumbersRR.add(i);
    	}
    	return pageNumbersRR;
    }
    
    //This method will get ContentVersion record of selected record
    public void processContent(){
            try{
                String contentId = '';
                if(apexpages.currentPage().getParameters().get('resourceIdParam') <> null){
                  contentId = apexpages.currentPage().getParameters().get('resourceIdParam');
                }
                versionDataforUI = new ContentVersion();
                if(contentId != null || contentId != ''){
                  versionDataforUI = [SELECT Title, TagCsv, FileType, Id FROM ContentVersion WHERE ID =: contentId];
                }
            }catch(Exception e){
                System.debug('ERROR :: ' + e.getMessage());
            }
  	}

	// Inner class that represents a row
	public class Row {
		public Integer recordNumber {get; set;}
		public String name {get; set;}
		public Date dueDate {get; set;}
		public boolean isOverDue {get;set;}
		public String contentVersion {get; set;}
		public String completeDate {get; set;}
		public String userId {get; set;}
		public String publishDate {get;set;}
		public String id{get;set;}
		public String url{get;set;}
		public String FileType{get;set;}
	}
}