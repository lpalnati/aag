/**
  * Apex Class: IntranetRouterController
  * Created By: Harshit Jain (Appirio Off)
  * Created Date: march 2, 2013
  * Description: This class is used to track total number of views.
***/
public with sharing class IntranetRouterController {
  private String recordId{get;set;}
  private String objectType{get;set;}
  private String redirectPath{get;set;} 
  public boolean isSecurePageHasAccess{get;set;} 
  
  public IntranetRouterController() {
    isSecurePageHasAccess = true;    
    recordId = ApexPages.currentPage().getParameters().get('id');
    objectType = ApexPages.currentPage().getParameters().get('type');
    redirectPath = ApexPages.currentPage().getParameters().get('path');
    //if redirect url contains name parameter then encode it becasue it's contain special characters.
    if(redirectPath.containsIgnoreCase('name') && String.isNotBlank(redirectPath.substringBetween('name=','&tabName'))) {
        redirectPath = redirectPath.replace(redirectPath.substringBetween('name=','&tabName'),EncodingUtil.urlEncode(redirectPath.substringBetween('name=','&tabName'),'UTF-8'));
    }
    //Denied acces to all secure team pages if current user is not a memeber of flight ops public group.
    if(objectType == 'Intranet_CMS_Page__c' && redirectPath.containsIgnoreCase('Secure')) {
       Integer gCount = [Select count() From GroupMember g where Group.Name = 'Flight Ops' and UserOrGroupId =: userInfo.getUserId()];
       isSecurePageHasAccess = (gCount == 1)? true:false;    
    }
  }
  
  /*********************************************************
    Fetch Record from object passed by type parameter in url
    Update total view by 1 and redirect to orignal path.
  *********************************************************/
  public pageReference updateTotalView(){
    Integer totalview;
    String query = 'Select Total_View__c from '+objectType+' where id ='+'\''+recordId+'\'';
    try{
      sObject obj = database.query(query);
      totalview = Integer.valueOf(obj.get('Total_View__c'));
      obj.put('Total_View__c', (totalview == null) ? 1 : (totalview += 1));
      update obj;
      return new pageReference(redirectPath);
    }catch(Exception e){
      return new pageReference(redirectPath);  
    }
  }
}