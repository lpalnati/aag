public abstract class PwCCAPGeoAbstract implements PwCCAPIGeo{
    public Map_GEO_Configuration__c geoConfig;
    public SObject obj;

    public PwCCAPGeoAbstract() {}

    public PwCCAPGeoAbstract(String className) {
        geoConfig = [SELECT Id,Name,Object_Display_Name__c,Mapping_API_Status_Field__c,Mapping_City_Field__c,Mapping_Latitude_Field__c,Mapping_Longitude_Field__c,Mapping_Postal_Code_Field__c,Mapping_State_Field__c,Mapping_Street_Field__c FROM Map_GEO_Configuration__c WHERE Object_Class_Name__c =: className AND Active__c = true]; 
    }

   public virtual String getDisplayName() {
        if(geoConfig != null) {
           return  String.valueOf(geoConfig.get('Object_Display_Name__c'));
        } else {
            return '';
        }
    }

    public virtual String getAPIName() {
        if(geoConfig != null) {
           return  String.valueOf(geoConfig.get('Name'));
        } else {
            return '';
        }
    }
        
    public virtual String getLongitudeField(){
        if(geoConfig != null) {
           return  String.valueOf(geoConfig.get('Mapping_Longitude_Field__c'));
        } else {
            return '';
        }
    }
    
    public virtual String getLatitudeField(){
        if(geoConfig != null) {
           return  String.valueOf(geoConfig.get('Mapping_Latitude_Field__c'));
        } else {
            return '';
        }
    }
    
    public virtual String getStreetField(){
        if(geoConfig != null) {
           return  String.valueOf(geoConfig.get('Mapping_Street_Field__c'));
        } else {
            return '';
        }
    }
    
    public virtual String getCityField(){
        if(geoConfig != null) {
           return  String.valueOf(geoConfig.get('Mapping_City_Field__c'));
        } else {
            return '';
        }
    }
    
    public virtual String getStateField(){
        if(geoConfig != null) {
           return  String.valueOf(geoConfig.get('Mapping_State_Field__c'));
        } else {
            return '';
        }
    }
    
    public virtual String getPostalCodeField(){
        if(geoConfig != null) {
           return  String.valueOf(geoConfig.get('Mapping_Postal_Code_Field__c'));
        } else {
            return '';
        }
    }

    public virtual String getServiceStatusField(){
        if(geoConfig != null) {
           return  String.valueOf(geoConfig.get('Mapping_API_Status_Field__c'));
        } else {
            return '';
        }
    }
        
    public virtual String getGeoAddress() {
        System.debug(obj);
        String address = '';
        try{
            if(obj != null){
                address += (obj.get(getStreetField())== null ? '' : obj.get(getStreetField())) + ',';            
                address += (obj.get(getCityField()) == null ? '' : obj.get(getCityField())) + ',';
                address += (obj.get(getStateField()) == null ? '' : obj.get(getStateField())) + ',';
                address += (obj.get(getPostalCodeField()) == null ? '' : obj.get(getPostalCodeField()));
            } 
        }catch(Exception ex) {
            System.debug('**********Error: ' + ex.getMessage());
        }
        return address;
    }
}