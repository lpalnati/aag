/**********************************************************************************
  Apex Class: IntranetMapCalendarController
  CreatedBy : Harshit Jain
  CreatedDate : march 15, 2012
  Description: This class is used to show calender amd google map on related team pages.
****************************************************************************************/
public with sharing class IntranetMapCalendarController {
    public String calendarText{get;set;}//google calendar script code 
    public String searchLocationText{get;set;}
    public List<AddressWrapper> addressWrapperList{get;set;}
    public Intranet_Config__c defaultGmapAddress{get;set;}
    public String allAddressString{get;set;}//* sapareted string of addresssess 
    public String allNotesString{get;set;}
    public String allPhone {get;set;}
    public String allURL {get;set;}
    public Intranet_CMS_Page__c CMSPage{get;set;}
    public String selectedType {get;set;}
    
    /*******************************************************************
    * Initialization of public member
    * Populate google map default address form custom setting
    *******************************************************************/
    public IntranetMapCalendarController() {
    	for(Intranet_CMS_Page__c page : [Select i.Show_Google_Map__c, Cal_3__c, Cal_3_Label__c,
    																	 Cal_2__c, Cal_2_Label__c, Cal_1__c, Cal_1_Label__c 
    																	 From Intranet_CMS_Page__c i 
    																	 where Name =:ApexPages.currentPage().getParameters().get('name')]) {
    		CMSPage = page;
    	}
	    addressWrapperList = new List<AddressWrapper>();
	    if(Intranet_Config__c.getInstance('Google_Map_Default_Address') != null) {
	    	defaultGmapAddress = Intranet_Config__c.getInstance('Google_Map_Default_Address');
	    }
    }
    
   /******************************************************************	
		*Populate location type list so end user can select location type  	
		******************************************************************/ 
		public List<selectOption> locationTypeOptions {
			get {
				
				List<selectOption> locationTypes = new List<selectOption>();
				if(CMSPage.Show_Google_Map__c != null) {
					selectedType = (CMSPage.Show_Google_Map__c == 'Intranet_Location__c'? 'Hotel' :'');	
					//describe the sobject
          Schema.DescribeSObjectResult sobject_describe = Schema.getGlobalDescribe().get(CMSPage.Show_Google_Map__c).getDescribe(); 
					//grab the list of picklist values for the passed field on the sobject
         	List<Schema.PicklistEntry> pick_list_values = sobject_describe.fields.getMap().get('Type__c').getDescribe().getPickListValues(); 
          for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
	            //add the value and label to our final list
	            locationTypes.add(new selectOption(a.getLabel(), a.getValue()));
	        }
				}
				return locationTypes;
			 }	
		 }
		 
    /********************************************************************************
    * Search search string against object specified in CMS page for Google map.
    * if any address found then return list of all addressess to google map script
    * to display addressess on Map. 
    ********************************************************************************/
    public void searchLocation(){
	    addressWrapperList.clear();
	    allAddressString = '';
	    allNotesString = '';
	    allPhone = '';
   		allURL = '';
	    for(SObject obj : getLocationData(CMSPage.Show_Google_Map__c,selectedType,searchLocationText)){
	      allAddressString += obj.get('Street__c') + ' ' + obj.get('City__c') + ' ' + obj.get('State__c') + ' ' + obj.get('Zip__c') + '**';
	      allNotesString  += obj.get('Notes__c')  + '**';
	      allPhone += obj.get('Phone__c')  + '**';
   		  allURL += obj.get('URL__c')  + '**';
	      addressWrapperList.add(new AddressWrapper(obj));
	    }
	    allNotesString = allNotesString.substringBeforeLast('**');
	    allAddressString = allAddressString.substringBeforeLast('**');
	 }
	 
	 public class AddressWrapper {
	 	 public String name{get;set;}
	   public String street{get;set;}
	   public String city{get;set;}
	   public String state{get;set;}
	   public String zip{get;set;}
	   public String notes{get;set;}
	   public String phone{get;set;}
	   public String url{get;set;}
	   public AddressWrapper(SObject obj) {
	   	 this.name = String.ValueOf(obj.get('Name'));
	     this.street = String.ValueOf(obj.get('Street__c')); 
	   	 this.city = String.ValueOf(obj.get('City__c'));
	     this.state = String.ValueOf(obj.get('State__c'));
	   	 this.zip = String.ValueOf(obj.get('Zip__c'));
	   	 this.notes	= String.ValueOf(obj.get('Notes__c'));
	   	 this.url = String.valueOf(obj.get('URL__c'));
	   	 this.phone = String.valueOf(obj.get('Phone__c'));		
	   }
	 }
	 
	/**************************************************************
  * Create dynamic SOQL for selected google map object. 
  **************************************************************/
  private List<SObject> getLocationData(String objectName,String locationType,String keyword) {
    String query = 'Select Zip__c, URL__c, Type__c, Street__c, Status__c, State__c, Phone__c, Notes__c, Name, City__c';
    query += ' From '+ objectName  +' where Type__c = \''+locationType+ '\' AND Status__c = '+true+' AND Name like \'%'+keyword+'%\' limit 10';
    return Database.query(query);
  }
	 
}