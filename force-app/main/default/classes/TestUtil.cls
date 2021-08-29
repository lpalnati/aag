/**
  * Apex Class: TestUtil
  * Description: Utility class for testMethods
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
public without sharing class TestUtil {
	
	//create Intranet_Banner__c
	public static Intranet_Banner__c createIntranetBanner(Boolean isInsert){
		DateTime sDate = DateTime.now().addDays(-5);
		DateTime eDate = DateTime.now().addDays(5);
		Intranet_Banner__c intranetBanner = new Intranet_Banner__c(Name='testBanner',
																   Start_Date__c = sDate,
																   End_Date__c = eDate,
																   Header__c = 'Virgin America',
																   Target__c = '_blank',
																   Pages__c ='Brand',
																   URL__c = 'http://www.virginamerica.com/');
		if(isInsert) insert intranetBanner;
        return intranetBanner;
	}
	
	//create CollaborationGroup
	public static CollaborationGroup createGroup(Boolean isInsert){
		CollaborationGroup collaborationGroup = new CollaborationGroup(Name='testGroup',
																	   CollaborationType = 'public');
		if(isInsert) insert collaborationGroup;
        return collaborationGroup;
	}		
	
	//create Intranet_CMS_Page__c
	public static Intranet_CMS_Page__c createContent(Boolean isInsert){
		Intranet_CMS_Page__c content = new Intranet_CMS_Page__c(Name='testContent',
																Status__c = 'Published',
																Template__c ='Home',
																URL__c='http://www.virginamerica.com/');
		if(isInsert) insert content;
        return content;
	}
	
	//create Intranet_CMS_Page__c
	public static Intranet_CMS_Page__c createContent(String name ,Boolean isInsert ,Id parentPageId ,String template){
		Intranet_CMS_Page__c content = new Intranet_CMS_Page__c(Name=name,
																Status__c = 'Published',
																Parent_page__c = parentPageId,
																Template__c =template);
		if(isInsert) insert content;
        return content;
	}
	
	//create Intranet_Article__c
	public static Intranet_Article__c createArticle(Boolean isInsert){
		DateTime sDate = DateTime.now().addDays(-5);
		DateTime eDate = DateTime.now().addDays(5);
		Intranet_Article__c article = new Intranet_Article__c(Name='testContent',
														      Start_Date__c = sDate,
														      End_Date__c = eDate,
														      Pages__c ='Brand');
		if(isInsert) insert article;
        return article;
	}
	
	//create Attachment
	public static Attachment createAttachment(Boolean isInsert, ID parentId ){
		Blob articleData = Blob.valueof('TestData');
		Attachment article = new Attachment(Name='testAttachment',
											body = articleData,
											ParentId = parentId);
		if(isInsert) insert article;
        return article;
	}
	public static User createUser(boolean isInsert)
    {
        List<Profile> profileList = [select id from Profile where Name='System Administrator' limit 1];
        Id profileId;
        User usr;
        if(profileList.get(0) != null)
        {
            profileId = profileList.get(0).Id;    
        }
        
        usr= new User();
        usr.Email              = 'test'+ Integer.valueOf(Math.random()) +'@virginamerica.com';
        usr.Username           = 'test' + Integer.valueOf(Math.random()) + '@testuser.com';
        usr.LastName           = 'test' ;
        usr.Alias              = 'test' ;
        usr.ProfileId          = profileId ;
        usr.LanguageLocaleKey  = 'en_US';
        usr.LocaleSidKey       = 'en_US';
        usr.TimeZoneSidKey     = 'America/Chicago';
        usr.EmailEncodingKey   = 'UTF-8';
        if(isInsert) insert usr;
        return usr ;
    }
    
    //create Intranet_Banner__c
	public static Intranet_Links__c createIntranetLink(Boolean isInsert){
		DateTime sDate = DateTime.now().addDays(-5);
		DateTime eDate = DateTime.now().addDays(5);
		Intranet_Links__c intranetLink = new Intranet_Links__c(Name='testBanner',
															   Start_Date__c = sDate,
															   End_Date__c = eDate,
															   Target__c = '_blank',
															   Pages__c ='Brand',
															   URL__c = 'http://www.virginamerica.com/');
		if(isInsert) insert intranetLink;
        return intranetLink;
	}
	public static Intranet_Performance__c createIntranetPerformance(Boolean isInsert){
		Intranet_Performance__c intranetPerformance =  new Intranet_Performance__c(Name='Monthly Performance');
		if(isInsert) insert intranetPerformance;
        return intranetPerformance;
	}
	
	public static Search_Config__c createSearchConfig(Boolean isInsert , String name, boolean isDisplay, String ApiName ){
		Search_Config__c searchConfing = new Search_Config__c(Name=name,
        									 				  IsDisplay__c = isDisplay,
        									 				  Object_API_Name__c =ApiName);
        if(isInsert) insert searchConfing;
        return searchConfing;
	}
	//Create intranet_Config__c custom setting
	public static Intranet_Config__c createIntranetConfig(Boolean isInsert , String name, String value){
		Intranet_Config__c intranetConfing = new Intranet_Config__c(Name=name, Value__c = value);		
    if(isInsert) insert intranetConfing;
        return intranetConfing;
	}
	
	//create Intranet_Form__c
	public static Intranet_Form__c createForm(Boolean isInsert){
		Intranet_Form__c form = new Intranet_Form__c();
		if(isInsert) insert form;
        return form;
	}
	
	//Create intranet Performance config setting
	public static Intranet_Performance_Config__c createIntranetPerformanceConfig(){
		Intranet_Performance_Config__c intranetPerformanceConfig =  new Intranet_Performance_Config__c();
    return intranetPerformanceConfig;
	}
	
	//create form list record
	public static IntranetFormList__c createFormList(Boolean isInsert,Id approverId){
		IntranetFormList__c formList = new IntranetFormList__c();
		formList.Active__c = true;
		formList.Select_Approver__c = approverId;
		if(isInsert) insert formList;
        return formList;
	}
	
	//create form list fields record
	public static IntranetFormListFields__c createFormListField(Boolean isInsert,Id formTypeId,Integer SequenceOrder,String fieldAPIName){
		IntranetFormListFields__c formListField = new IntranetFormListFields__c();
		formListField.Related_Form__c = formTypeId;
		formListField.Sequence_Order__c = SequenceOrder;
		formListField.Field_API_Name__c = fieldAPIName;
		if(isInsert) insert formListField;
        return formListField;
	}
	
	//Create intranet_Form_Config__c custom setting
	public static Intranet_Form_Config__c createIntranetFromConfig(Boolean isInsert,String name, String FormFieldAPIName, String RelatedUserFieldAPIName){
		Intranet_Form_Config__c formConfig = new Intranet_Form_Config__c();		
		formConfig.Name = name;
		formConfig.Form_Field_API_Name__c = FormFieldAPIName;
		formConfig.Related_User_Field_API_Name__c = RelatedUserFieldAPIName;
    if(isInsert) insert formConfig;
        return formConfig;
	}
	
	//create intranet location record 
	public static Intranet_Location__c createLocation(Boolean isInsert,String typeOfLocation,String name,String notes) {
		Intranet_Location__c location = new Intranet_Location__c();
		location.Name = name;
		location.Notes__c = notes;
		location.Type__c = typeOfLocation;
		location.City__c = 'NYC';
		location.State__c = 'DC';
		location.Street__c = '300 st';
		location.Zip__c = '132123';
		location.Status__c = true;
		if(isInsert) insert location;
        return location;
	}
	
}