global class PwCCAPGeoServiceUtil {
    global static CommonResult geoSingleSobject(String apiName, Id sobjectId, String className){    	
    	CommonResult result = new CommonResult();
    	//Type t = Type.forName(className);
    	//PwCCAPGeoAbstract geo = (PwCCAPGeoAbstract)t.newInstance();
        PwCCAPGeoAbstract geo = new PwCCAPGeoGeneral(className);
    	SObject sobj = fetchSingleSObject(geo, sobjectId,apiName);
    	geo.obj = sobj;
    	if(sobj != null && sobj.get(geo.getPostalCodeField()) != null){
            try {
    			PwCCAPGeoServiceHelper.GeocodeResult gResult = PwCCAPGeoServiceHelper.geoCodeAddress(geo.getGeoAddress());	
            	SObject tmpObj = (SObject)Type.forName(apiName).newInstance();  
                tmpObj.put('Id', sobjectId);
                sobj.put(geo.getServiceStatusField(), gResult.status);
    			if(gResult.status.equalsIgnoreCase('Success')){
                    tmpObj.put(geo.getLongitudeField(), gResult.getLngValue());
                    tmpObj.put(geo.getLatitudeField(), gResult.getLatValue());  
    			}
                result.obj = tmpObj;
                result.Message = gResult.status;
            } catch(Exception ex) {
            	result.Message= ex.getMessage();
            }
    	} else {
    		result.Message = 'Empty object information';
    	}
    	
		return result;						
    }	

    public static SObject fetchSingleSObject(PwCCAPGeoAbstract geo, String sobjectId,String apiName){    	
    	String query = getQueryString(geo);
    	query = query + ' where Id = :sobjectId';
    	//Special logic
        if(apiName.equalsIgnoreCase('Lead')) {//Close lead can not updated
            query = query + ' and IsConverted = false ';
        }
    	List<SObject> sobjs = Database.query(query);
    	if(sobjs.size() > 0){
    		return sobjs[0];	
    	}else{
    		return null;
    	}
    }	
    
    public static String getQueryString(PwCCAPGeoAbstract geo){
        String query = 'SELECT Id, Name' 
                    + ',' + geo.getLongitudeField() 
                    + ',' + geo.getLatitudeField() + ',' 
                    + geo.getStreetField() + ',' 
                    + geo.getCityField() + ',' 
                    + geo.getStateField() + ',' 
                    + geo.getPostalCodeField() 
                    + ' from ' + geo.getAPIName();   
                    
        return query; 
    }

    public static String getQueryWhere(PwCCAPGeoAbstract geo, Boolean fullrun) {
        String queryWhere = ' WHERE ' + geo.getPostalCodeField() + ' <> NULL';
        if(!fullrun) {
           queryWhere  += ' AND ' + '(' + geo.getLongitudeField() + ' = NULL OR ' + geo.getLatitudeField() + ' = NULL)';
        }
        return queryWhere;
    }

    global class CommonResult {
        public SObject obj {get;set;}
        public String Message {get;set;}
    }
}