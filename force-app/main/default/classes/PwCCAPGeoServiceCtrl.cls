public without sharing class PwCCAPGeoServiceCtrl {
    public PwCCAPGeoServiceCtrl() {

    }

    @RemoteAction
    public static CommonResult getObjects(){
        CommonResult result = new CommonResult();
        try {
            result.ObjLst = [SELECT Id,
                        Name, 
                        Object_Display_Name__c,
                        Object_Class_Name__c
                 FROM Map_GEO_Configuration__c
                 WHERE Active__c = true
                 ORDER BY Object_Display_Name__c];
            result.Message = 'Success';
        } catch(Exception e) {
            result.Message = e.getMessage();
        }
        return result;
    }

    @RemoteAction
    public static CommonResult runBatchJob() {
        CommonResult result = new CommonResult();
        try {
            result.Message = 'Success';
        } catch(Exception e) {
            result.Message = e.getMessage();
        }
        return result;
    }

    @RemoteAction
    @ReadOnly
    public static CommonResult getGeoRecordCount(String className,Boolean fullrun){
        CommonResult result = new CommonResult();
        try {
            if(!String.isEmpty(className)){
                //Commemt out by Natic 20170224, for package.
                //Type objClass = Type.forName(className);
                //PwCCAPGeoAbstract geo = (PwCCAPGeoAbstract)objClass.newInstance();
                PwCCAPGeoAbstract geo = new PwCCAPGeoGeneral(className);
                
                String sql = 'SELECT COUNT() FROM ' + geo.getAPIName()
                   + PwCCAPGeoServiceUtil.getQueryWhere(geo,fullrun)
                   + ' LIMIT 50000';
                System.debug('***************' + sql);
                result.Obj = Database.countQuery(sql); 
                result.Message = 'Success';
            } else {
                result.Message = 'Please connect admin set object class name in map geo configurations';
            }
        }catch(Exception e){
            result.Message = e.getMessage();
        }   
        return result;       
    }

    @RemoteAction
    public static GeoOutput getGeoRecord(String className, Boolean fullrun, GeoInput input) {
        GeoOutput result = new GeoOutput();
        try {
            //Type geoAddressType = Type.forName(className);
            //PwCCAPGeoAbstract geo = (PwCCAPGeoAbstract)geoAddressType.newInstance();
            PwCCAPGeoAbstract geo = new PwCCAPGeoGeneral(className);

            try {
                if(input !=null && input.Obj != null){       
                    String apiName =  input.Obj.getSObjectType().getDescribe().getName();
                    SObject tmpObj = (SObject)Type.forName(apiName).newInstance();  
                    tmpObj.put('Id', input.Obj.get('Id'));
                    tmpObj.put(geo.getServiceStatusField(), input.Message);  
                    if(input.Message.equalsIgnoreCase('SUCCESS')) {
                        tmpObj.put(geo.getLatitudeField(), input.lat);
                        tmpObj.put(geo.getLongitudeField(), input.lng); 
                        tmpObj.put(geo.getServiceStatusField(), input.Message);  
                    }
                    update tmpObj;
                }
                result.UpdateMessage = 'Success';
            } catch(Exception ex) {
                result.UpdateMessage = 'Error:'+ex.getMessage();
            }
                
            String sql = PwCCAPGeoServiceUtil.getQueryString(geo)
                   + PwCCAPGeoServiceUtil.getQueryWhere(geo,fullrun)
                   + ((input != null && input.Obj != null) ? (' and Id > \'' + input.Obj.Id + '\'') : '')
                   + ' limit 1';

            List<SObject> sobjs = Database.query(sql); 
            if(sobjs.size() > 0) {
                result.obj = sobjs[0];
                geo.obj = sobjs[0];
                result.Address = geo.getGeoAddress();
            } else {
                result.obj = null;
                result.Address = null;
            }
            result.Message = 'Success';
        } catch (Exception e) {
            result.Message = e.getMessage();
        }
        return result;
    }

    public class CommonResult {
        public Object Obj {get;set;}
        public String Message {get;set;}
        public List<Object> ObjLst {get;set;}

        public CommonResult() {
            ObjLst = new List<Object>();
        }
    }

    public class GeoInput {
        public SObject Obj {get;set;}
        public Decimal Lat;
        public Decimal Lng;
        public String Message {get;set;}
    }

    public class GeoOutput {
        public SObject Obj {get;set;}
        public String Address {get;set;}
        public String Message {get;set;}
        public String UpdateMessage {get;set;}
    }
}