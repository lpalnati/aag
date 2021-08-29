global class PwCCAPGeoServiceBatch implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global List<String> filterLst;
    global GeoType      t;
    global List<String> classNameLst;
    global List<String> displayNameLst;
    global List<String> apiNameLst;
    global Boolean      fullRun;
    global String       LastRunId;//No used now
    global Integer      index;
    global Integer      successCount = 0;
    global Integer      failedCount = 0;
    
    global PwCCAPGeoServiceBatch(String name, GeoType type){
        this(new List<String>{name}, type, false, 0);
    }

    global PwCCAPGeoServiceBatch(String name, GeoType type, Boolean fullrun){
        this(new List<String>{name}, type, fullrun, 0);
    }

    global PwCCAPGeoServiceBatch(List<String> filterLst, GeoType type) {
        this(filterLst, type, false, 0);
    }

    global PwCCAPGeoServiceBatch(List<String> filterLst,GeoType type, Boolean fullrun, Integer index) {
        this.filterLst = filterLst;
        this.t         = type;
        this.fullRun   = fullrun;
        this.index     = index;

        this.classNameLst   = new List<String>();
        this.displayNameLst = new List<String>();
        this.apiNameLst     = new List<String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        try{
            if(index == 0) {
                String query = 'SELECT Object_Class_Name__c,Object_Display_Name__c,Name FROM Map_GEO_Configuration__c WHERE Active__c = TRUE';
                if(t == GeoType.All) {
                    //nothing
                } else if(t == GeoType.APIName) {
                    query += ' AND Name IN :filterLst';
                } else if(t == GeoType.ClassName) {
                    query += ' AND Object_Class_Name__c IN :filterLst';
                } else if(t == GeoType.DisplayName) {
                    query += ' AND Object_Display_Name__c IN :filterLst';
                }
                List<Map_GEO_Configuration__c> geoConfLst = Database.query(query);
                for(Map_GEO_Configuration__c geoConf : geoConfLst) {
                    classNameLst.add(geoConf.Object_Class_Name__c);
                    displayNameLst.add(geoConf.Object_Display_Name__c);
                    apiNameLst.add(geoConf.Name);
                } 
            }
            if(classNameLst.size() > 0) {
                //Type objClass = Type.forName(classNameLst[index]);
                //PwCCAPGeoAbstract geo = (PwCCAPGeoAbstract)objClass.newInstance();
                PwCCAPGeoAbstract geo = new PwCCAPGeoGeneral(classNameLst[index]);
                String sql = 'select Id'
                   + ' from ' + geo.getAPIName()
                   + PwCCAPGeoServiceUtil.getQueryWhere(geo,fullRun);
                Database.QueryLocator result = Database.getQueryLocator(sql);
                System.debug(result);
                return result;
            } else {
                return null;
            }
        } catch(Exception ex) {
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> sobjs) {
        //the batch size is supposed to set as 1 to avoid any call out limit and increase time span between callouts
        //Google support 50 records max in same time
        List<Sobject> objLst = new List<Sobject>();
        for(Sobject  obj : sobjs) {
            PwCCAPGeoServiceUtil.CommonResult result = PwCCAPGeoServiceUtil.geoSingleSobject(apiNameLst[index], obj.Id,classNameLst[index]);    
            if(result.Message.equalsIgnoreCase('Success')){
                successCount++;
            }else {
                failedCount++;
            }

            if(result.obj != null) {
                objLst.add(result.obj);
            }
        }
        update objLst;
    }

    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();         
        mail.setSaveAsActivity(false);          
        mail.setSubject('Geo Job for '+displayNameLst[index]+' is finished');           
        
        String content = '';
        content += '<p>Success: ' + successCount +  '</p>';
        content += '<p>Failed: ' + failedCount + '</p>';
        content += '<br/>';
                    
        mail.setHtmlBody(content);
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});     
        mail.setBccSender(false);                                       
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail}); 

        index++;
        if(index < classNameLst.size()) {
            PwCCAPGeoServiceBatch job = new PwCCAPGeoServiceBatch(filterLst,t,fullRun,index);
            Database.executeBatch(job,20);
        }
    }

    global Enum GeoType {
        APIName,
        ClassName,
        DisplayName,
        All
    }
}