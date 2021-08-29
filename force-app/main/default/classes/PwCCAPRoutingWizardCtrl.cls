/**************************************************************************************************
 * Name: PwCCAPRoutingWizardCtrl
 * Requirement: Routing Wizard Page Controller
 				Generate Dynamic Google Map based on dynamic configuration.
 * Author: Doe Qiu
 * Create Date: 2016-11-08
  ***************************************************************************************************/
public with sharing class PwCCAPRoutingWizardCtrl {
	//Field
	private static List<Map_GEO_Configuration__c> geoLst;
	private static Location location = new Location();
	private static List<My_Location__c> myLocationLst;
    private static Set<String> fieldTypeSet;
    private static Map<String,String> objDisplayAPIMap;
    private static Map<String,String> fieldDisplayAPISearchMap;
    private static Map<String,String> fieldDisplayAPIDetailMap;
    private static List<User> userLst;
    private static String currId;
	//final value
	private static final Integer CONSTANT_MINSIZE = Routing_Wizard__c.getValues('Min Size').Value__c != null ? Integer.valueOf(Routing_Wizard__c.getValues('Min Size').Value__c) : 5;
    private static final Integer CONSTANT_MAXSIZE = Routing_Wizard__c.getValues('Max Size').Value__c != null ? Integer.valueOf(Routing_Wizard__c.getValues('Max Size').Value__c) :50;
    private static final Integer CONSTANT_STEP = Routing_Wizard__c.getValues('Step Size').Value__c != null ? Integer.valueOf(Routing_Wizard__c.getValues('Step Size').Value__c) : 5;
    private static final String CONSTANT_UNIT = Routing_Wizard__c.getValues('Unit').Value__c != null ? String.valueOf(Routing_Wizard__c.getValues('Unit').Value__c) : 'mi';
    private static final Integer CONSTANT_SIZE = Routing_Wizard__c.getValues('Default Size').Value__c != null ? Integer.valueOf(Routing_Wizard__c.getValues('Default Size').Value__c) : 5;
    private static final String CONSTANT_TIMEZONE = String.valueOf(UserInfo.getTimeZone());
    private static final String CONSTANT_USERROLEID = UserInfo.getUserRoleId();
    private static final Integer CONSTANT_LIMIT = 100;

    static {
    	geoLst = [SELECT Id,
    					Name, 
    					Object_Display_Name__c, 
                        Icon__c,
                        Icon_Selected__c,
    					Result_Size__c,
                        Null_Last__c,
                        Mapping_City_Field__c,
                        Mapping_Postal_Code_Field__c,
                        Mapping_State_Field__c,
                        Mapping_Street_Field__c,
                        Mapping_Latitude_Field__c,
                        Mapping_Longitude_Field__c,
    					(SELECT Id,
		    					Name,
		    					Reflect__c,
		    					Search_Field__c,
		    					Search_Object__c,
		    					Search_Select__c,
                                Default_Search_Select__c,
		    					Search_Type__c,
		    					Range__c
		    			FROM Search_Configurations__r
		    			WHERE Active__c = true
                        ORDER BY Sequence__c  NULLS LAST),
		    			(SELECT Id,
		    					Name,
		    					Detail_Field_Display_Name__c,
                                Field_Display_Area__c,
		    					Field_Style__c,
                                Display__c,
                                Display_Sequence__c,
                                Order__c,
                                DESC__c,
                                Sort__c,
                                Searchable__c
		    			FROM Details_Configurations__r
		    			WHERE Active__c = true
                        ORDER BY Order_Sequence__c NULLS LAST)
    			 FROM Map_GEO_Configuration__c
    			 WHERE Active__c = true 
    			 	   AND Search__c = true
                 ORDER BY Order__c];
        objDisplayAPIMap = new Map<String,String>();
        fieldDisplayAPISearchMap = new Map<String,String>();
        fieldDisplayAPIDetailMap = new Map<String,String>();
        for(Map_GEO_Configuration__c geo : geoLst) {
            objDisplayAPIMap.put(geo.Object_Display_Name__c,geo.Name);
            for(Map_Search_Configuration__c search : geo.Search_Configurations__r) {
                fieldDisplayAPISearchMap.put(search.Name,search.Search_Field__c);
            }
            for(Map_Details_Configuration__c detail : geo.Details_Configurations__r) {
                fieldDisplayAPIDetailMap.put(detail.Detail_Field_Display_Name__c,detail.Name);
            }
        }

    	//location = getCurrentUserClubLocation();

    	myLocationLst = [SELECT Id,
    							Location_Name__c,
    							Geo_Location__Latitude__s,
    							Geo_Location__Longitude__s,
    							Address__c
    					FROM My_Location__c 
    					WHERE OwnerId =: UserInfo.getUserId()];

        fieldTypeSet = new Set<String>();
        for(Schema.PicklistEntry f : Map_Search_Configuration__c.Search_Type__c.getDescribe().getPicklistValues()) {
            fieldTypeSet.add(f.getValue().toLowerCase());
        }

        userLst = [SELECT Id,FirstName,LastName FROM User WHERE IsActive = true];

        currId = UserInfo.getUserId();
    }

    //Remote Action
    @RemoteAction
    public static InitialResult getInitialResultWhenPageLoad() {
    	InitialResult result = new InitialResult();
    	try{
    		result.TimeZone = CONSTANT_TIMEZONE;
    		result.CurrentLocation = location;
            result.CurrentLocation.Unit = CONSTANT_UNIT;
            result.CurrentLocation.Size = CONSTANT_SIZE;
    		result.MyLocations = myLocationLst;
            result.Users = userLst;
            result.CurrentUser = currId;
    		for(Integer i = CONSTANT_MINSIZE; i<= CONSTANT_MAXSIZE; i=i+CONSTANT_STEP) {
                result.Sizes.add(i);     
            }
            for(Map_GEO_Configuration__c geo : geoLst) {
            	result.SearchObjects.add(geo.Object_Display_Name__c);
            }
            for(Map_GEO_Configuration__c geo : geoLst) {
            	List<SearchConfiguration> searchLst = new List<SearchConfiguration>();
                Schema.SObjectType targetObj = Schema.getGlobalDescribe().get(geo.Name);
                if(targetObj != null) {//Check Object is valid and accessible
            	    for(Map_Search_Configuration__c search : geo.Search_Configurations__r) {
                        Map<String, Schema.sObjectField> targetFieldMap = targetObj.getDescribe().fields.getMap();
                        Schema.sObjectField targetField = targetFieldMap.get(search.Search_Field__c);
                        if(targetField != null) {//Check Field is valid and accessible
                            SearchConfiguration sc = new SearchConfiguration();
                            sc.DisplayName = search.Name;
                            sc.IsRange = search.Range__c;
                            if(search.Reflect__c) {
                                String targetType = String.valueOf(targetField.getDescribe().getType()).toLowerCase();
                                if(fieldTypeSet.contains(targetType)) {//Check field Type is valid as Picklist
                                    sc.InputType = targetType.toLowerCase();
                                    if(targetType.equalsIgnoreCase(String.valueOf(Schema.DisplayType.PICKList))
                                        || targetType.equalsIgnoreCase(String.valueOf(Schema.DisplayType.MULTIPICKList)) ) {
                                        for(Schema.PicklistEntry f : targetField.getDescribe().getPicklistValues()) {
                                            sc.Options.add(f.getValue());
                                        }
                                    }
                                    searchLst.add(sc);
                                }
                            } else {
                                sc.InputType = search.Search_Type__c.toLowerCase();
                                if(String.isNotEmpty(search.Search_Select__c)) {
                                    sc.Options.addAll(search.Search_Select__c.Split(';'));
                                }
                                searchLst.add(sc);
                            }
                            if(String.isNotEmpty(search.Default_Search_Select__c)) {
                                sc.DefaultOptions.addAll(search.Default_Search_Select__c.Split(';'));
                            }
                        }
                    }
            	}
            	result.SearchConfigs.put(geo.Object_Display_Name__c, searchLst);
            }
    		result.Message = 'Success';
    	}catch(Exception e) {
    		result.Message = e.getMessage();
    	}
    	return result;
    }

    @RemoteAction
    public static CommonResult addToMyLocation(My_Location__c myLocation) {
        CommonResult result = new CommonResult();
        try{
            insert myLocation;
            result.Message = 'Success';
            result.obj = myLocation;
        } catch(Exception e) {
            result.Message = e.getMessage();
        }
        return result;
    }

    @RemoteAction
    public static CommonResult deleteMyLocation(My_Location__c myLocation) {
        CommonResult result = new CommonResult();
        try{
            delete myLocation;
            result.obj = myLocation;
            result.Message = 'Success';
        } catch(Exception e) {
            result.Message = e.getMessage();
        }
        return result;
    }

    @RemoteAction
    public static CommonResult insertTask(Task obj) {
        CommonResult result = new CommonResult();
        try{
            insert obj;
            result.Message = 'Success';
        } catch(Exception e) {
            result.Message = e.getMessage();
        }
        return result;
    }

    @RemoteAction
    public static CommonResult insertEvent(Event obj) {
        CommonResult result = new CommonResult();
        try{
            insert obj;
            result.Message = 'Success';
        } catch(Exception e) {
            result.Message = e.getMessage();
        }
        return result;
    }

    @RemoteAction
    public static SearchResult queryData(List<SearchFilter> filterLst, Location l) {
        System.debug('lllllll' + filterLst);
        SearchResult result = new SearchResult();
        try{
            for(SearchFilter filter : filterLst) {
                System.debug('ggggggggg' + geoLst);
                for(Map_GEO_Configuration__c geo : geoLst) {
                    Set<string> includFieldSet = new Set<String>();
                    includFieldSet.add('Id');
                    includFieldSet.add('Name');
                    includFieldSet.add(geo.Mapping_City_Field__c);
                    includFieldSet.add(geo.Mapping_State_Field__c);
                    includFieldSet.add(geo.Mapping_Street_Field__c);
                    includFieldSet.add(geo.Mapping_Postal_Code_Field__c);
                    includFieldSet.add(geo.Mapping_Latitude_Field__c);
                    includFieldSet.add(geo.Mapping_Longitude_Field__c);

                    if(geo.Object_Display_Name__c.equalsIgnoreCase(filter.SearchObj)) {
                        Schema.SObjectType targetObj = Schema.getGlobalDescribe().get(geo.Name);
                        if(targetObj != null) {//Check Object is valid and accessible
                            Map<String,SObject> objMap = new Map<String,SObject>();
                            List<DetailsConfiguration> detailLst = new List<DetailsConfiguration>();
                            String queryStart = 'SELECT ';
                            for(String field : includFieldSet) {
                                queryStart += field + ',';
                            }
                            String queryFrom = ' FROM ';
                            String geofield = geo.Mapping_Latitude_Field__c.replace('Latitude__s','c');
                            String queryWhere = ' WHERE DISTANCE('+geofield+',GEOLOCATION('+ l.Latitude+','+l.Longitude+'),\''+l.Unit+'\') < '+ l.Size;
                            String queryOrder = '';
                            String queryNullLast = '';
                            String queryLimit = ' LIMIT ';
                            //SELECT PART & Order Part
                            for(Map_Details_Configuration__c detail : geo.Details_Configurations__r) {
                                if(! String.isEmpty(detail.Name) 
                                    && !detail.Name.equalsIgnoreCase('Address')) {//Special  api name need remove
                                    Map<String, Schema.sObjectField> targetFieldMap = targetObj.getDescribe().fields.getMap();
                                    Schema.sObjectField targetField = targetFieldMap.get(detail.Name);
                                    if(targetField != null) {//Check Field is valid and accessible
                                        if(detail.Display__c 
                                            && !includFieldSet.contains(detail.Name)) {
                                            queryStart += detail.Name + ',';
                                        }

                                        if(detail.Order__c) {
                                            if(String.isEmpty(queryOrder)) {
                                                queryOrder = ' ORDER BY ' + detail.Name;
                                            } else {
                                                queryOrder += ' , ' + detail.Name;
                                            }
                                            if(detail.DESC__c) {
                                                queryOrder += ' DESC';
                                            }
                                        }
                                    }
                                }

                                //Build Structure
                                if(detail.Display__c) {
                                    DetailsConfiguration dc = new DetailsConfiguration();
                                    dc.FieldDisplayName = detail.Detail_Field_Display_Name__c;
                                    dc.FieldAPIName = detail.Name;
                                    dc.IsSortable = detail.Sort__c;
                                    dc.IsSearchable = detail.Searchable__c;
                                    dc.Sequence = Integer.valueOf(detail.Display_Sequence__c);
                                    if(String.isNotEmpty(detail.Field_Style__c)) {
                                        dc.FieldStyles.addAll(detail.Field_Style__c.Split(';'));
                                    }
                                    if(String.isNotEmpty(detail.Field_Display_Area__c)) {
                                        dc.FieldDisplayAreas.addAll(detail.Field_Display_Area__c.Split(';'));
                                    }
                                    detailLst.add(dc);
                                }
                            }
                            queryStart = queryStart.substring(0, queryStart.length()-1);

                            //FROM PART
                            queryFrom += geo.Name;

                            //WHERE PART
                            for(SearchConfiguration search : filter.SearchConfigs) {
                                queryWhere += ' AND ' + fieldDisplayAPISearchMap.get(search.DisplayName);
                                if(search.InputType.equalsIgnoreCase('Boolean')) {
                                    queryWhere += ' = ' + search.OutPut1;
                                } else if(search.InputType.equalsIgnoreCase('Email')
                                        || search.InputType.equalsIgnoreCase('Phone')
                                        || search.InputType.equalsIgnoreCase('String')) {
                                    queryWhere += ' = \'' + search.OutPut1 + '\',';
                                }else if(search.InputType.equalsIgnoreCase('Picklist')
                                        || search.InputTYpe.equalsIgnoreCase('MultiPicklist')) {
                                    if(search.Options!=null&&search.Options.size()>0){
                                        String tmp = '(';
                                        for(String option : search.Options) {
                                            tmp += '\''+ option + '\',';
                                        }
                                        tmp = tmp.substring(0, tmp.length()-1) + ')';
                                        queryWhere += ' IN ' + tmp;
                                    } else{
                                        queryWhere +=  ' IN ' +'('+'\' \''+')';
                                    }
                                } else if(search.InputType.equalsIgnoreCase('Currency')
                                        || search.InputTYpe.equalsIgnoreCase('Double')
                                        || search.InputTYpe.equalsIgnoreCase('Integer')
                                        || search.InputTYpe.equalsIgnoreCase('Percent')) {
                                    if(search.IsRange) {
                                        queryWhere += ' >= ' + search.OutPut1 + ' <= ' + search.OutPut2;
                                    } else {
                                        queryWhere += ' = ' + search.OutPut1;
                                    }
                                } else if (search.InputType.equalsIgnoreCase('Date')) {
                                    if(search.IsRange) {
                                        Date d1 = Date.valueOf(search.OutPut1);
                                        Date d2 = Date.valueOf(search.OutPut2);
                                        queryWhere += ' >= ' + d1 + ' <= ' + d2;
                                    } else {
                                        Date d1 = Date.valueOf(search.OutPut1);
                                        queryWhere += ' = ' + d1;
                                    }
                                } else if (search.InputType.equalsIgnoreCase('DateTime')) {
                                    if(search.IsRange) {
                                        DateTime d1 = DateTime.valueOf(search.OutPut1);
                                        DateTime d2 = DateTime.valueOf(search.OutPut2);
                                        queryWhere += ' >= ' + d1 + ' <= ' + d2;
                                    } else {
                                        DateTime d1 = DateTime.valueOf(search.OutPut1);
                                        queryWhere += ' = ' + d1;
                                    }
                                } 
                            }

                            //NULL LAST PART
                            if(geo.Null_Last__c && String.isNotEmpty(queryOrder)) {
                                queryNullLast = ' Nulls Last ';
                            }

                            //LIMIT PART
                            if(geo.Result_Size__c != null && geo.Result_Size__c > 0) {
                                queryLimit += geo.Result_Size__c;
                            } else {
                                queryLimit += CONSTANT_LIMIT;
                            }
                            String query = queryStart + queryFrom + queryWhere + queryOrder + queryNullLast + queryLimit;
                            System.debug('*************** Debug Info Query: ' + query);
                            List<Sobject> objLst = Database.query(query);
                            for(Sobject obj : objLst) {
                                String address = '';
                                if(obj != null){
                                    address += (obj.get(geo.Mapping_Street_Field__c)== null ? '' : obj.get(geo.Mapping_Street_Field__c)) + ',';            
                                    address += (obj.get(geo.Mapping_City_Field__c) == null ? '' : obj.get(geo.Mapping_City_Field__c)) + ',';
                                    address += (obj.get(geo.Mapping_State_Field__c) == null ? '' : obj.get(geo.Mapping_State_Field__c)) + ',';
                                    address += (obj.get(geo.Mapping_Postal_Code_Field__c) == null ? '' : obj.get(geo.Mapping_Postal_Code_Field__c));
                                } 
                                objMap.put(address + '_' + obj.get('Id')+'_'+obj.get(geo.Mapping_Latitude_Field__c)+'_'+obj.get(geo.Mapping_Longitude_Field__c),obj);
                            }

                            result.ObjectMap.put(geo.Object_Display_Name__c,objMap);
                            result.DetailsConfigs.put(geo.Object_Display_Name__c,detailLst);
                            result.Icons.put(geo.Object_Display_Name__c,geo.Icon__c);
                            result.SelectedIcons.put(geo.Object_Display_Name__c,geo.Icon_Selected__c);
                            result.Message = 'Success';
                        }
                    }
                }
            }
        } catch(Exception e) {
            result.Message = e.getMessage();
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            System.debug(e.getTypeName());
            System.debug(e.getStackTraceString());
        }
        return result;
    }

    //Private Method
    /*private static Location getCurrentUserClubLocation(){
        Location result = new Location();
        User user = [SELECT Id,
        					SBA_Store__c  
        			FROM User 
        			WHERE id = :UserInfo.getUserId() 
        			LIMIT 1];
        if(!String.isEmpty(user.SBA_Store__c)){
        	List<SBA_Store__c> storeLst = [SELECT Id,
        										Geo_Location__Longitude__s,
        										Geo_Location__Latitude__s,
        										SBA_Street__c,
        										SBA_State__c,
        										SBA_City__c 
        								FROM SBA_Store__c 
        								WHERE Store_Number__c = :user.SBA_Store__c];
        	if(storeLst.size()>0){
            	result.Longitude = storeLst.get(0).Geo_Location__Longitude__s;
            	result.Latitude = storeLst.get(0).Geo_Location__Latitude__s;
            	result.Address = storeLst.get(0).SBA_Street__c+', '+storeLst.get(0).SBA_City__c+', '+storeLst.get(0).SBA_State__c;
            }
        }
        return result;
    }*/

    //Class
    public class InitialResult {
        public String TimeZone {get;set;}
        public Location CurrentLocation {get;set;}
        public List<Integer> Sizes {get;set;}
        public List<String> SearchObjects {get;set;}
        public List<My_Location__c> MyLocations {get;set;}
        public Map<String,List<SearchConfiguration>> SearchConfigs {get;set;}
        public String Message {get;set;}
        public List<User> Users {get;set;}
        public String CurrentUser {get;set;}

        public InitialResult() {
        	Sizes = new List<Integer>();
        	SearchObjects = new List<String>();
        	MyLocations = new List<My_Location__c>();
        	SearchConfigs = new Map<String,List<SearchConfiguration>>();
            Users = new List<User>();
        }
    }

    public class CommonResult {
        public Object obj {get;set;}
        public String Message {get;set;}
        public List<Object> objLst {get;set;}

        public CommonResult() {
            ObjLst = new List<Object>();
        }
    }

    public class SearchResult {
        public Map<String, Map<String,SObject>> ObjectMap {get;set;}
        public Map<String,String> Icons {get;set;}
        public Map<String, String> SelectedIcons {get;set;}
        public Map<String, List<DetailsConfiguration>> DetailsConfigs {get;set;}
        public String Message {get;set;}

        public SearchResult() {
            ObjectMap= new Map<String, Map<String,SObject>>();
            Icons = new Map<String,String>();
            SelectedIcons = new Map<String,String>();
            DetailsConfigs = new Map<String, List<DetailsConfiguration>>();
        }
    }

    public class SearchFilter {
        public String SearchObj {get;set;}
        public List<SearchConfiguration> SearchConfigs {get;set;}
    }

    public class SearchConfiguration {
    	public String DisplayName {get;set;}
    	public String InputType {get;set;}
    	public Boolean IsRange {get;set;}
    	public List<String> Options {get;set;}
        public List<String> DefaultOptions {get;set;}
        public String OutPut1 {get;set;}
        public String OutPut2 {get;set;}

    	public SearchConfiguration() {
    		Options = new List<String>();
            DefaultOptions = new List<String>();
    	}
    }

    public class DetailsConfiguration implements Comparable {
        public String FieldDisplayName {get;set;}
        public String FieldAPIName {get;set;}
        public Boolean IsSortable {get;set;}
        public Boolean IsSearchable {get;set;}
        public Integer Sequence {get;set;}
        public List<String> FieldDisplayAreas {get;set;}
        public List<String> FieldStyles {get;set;}

        public DetailsConfiguration() {
            FieldDisplayAreas = new List<String>();
            FieldStyles = new List<String>();
        }

        public Integer compareTo(Object ObjToCompare) {
            DetailsConfiguration dc = (DetailsConfiguration) ObjToCompare;
            if(Sequence > dc.Sequence) return -1;
            else if(Sequence < dc.Sequence) return 1;
            else return 0;
        }
    }

    public class Location {
        public Double Longitude {get;set;}
        public Double Latitude {get;set;}
        public String Address {get;set;}
        public String Unit {get;set;}
        public Integer Size {get;set;}
    }
}