public without sharing class PwCCAPGeoServiceHelper {
    private static final String googleMapsAPI = 'https://maps.googleapis.com';
    private static final String googleGeocodeService = '/maps/api/geocode/';
    
    public static Boolean useEnterpriseLicense = true;
    //public static String googleEnterpriseKey = 'AIzaSyBYrL7R76biVoDTbeD0X-DfSLL3lFZslOI';
    public static String googleEnterpriseKey = 'AIzaSyAwma0hUsjcCeAtr0ZzpFBBBgeJqZ0Zo4A';
    
    public static GeocodeResult geoCodeAddress(String address){
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(getGeocodeURL(EncodingUtil.urlEncode(address, 'UTF-8')));
            req.setMethod('GET');
            Http http = new Http();

            HTTPResponse res = http.send(req);
            System.debug(res);
            System.debug(res.getBody());
            return parseResponse(res.getBody());
        }catch (Exception e){
            throw e;
        }
    }

     private static String getGeocodeURL(String address){
        String returnURL = '';
        if (useEnterpriseLicense){
            returnURL = googleMapsAPI + googleGeocodeService + 'json?key=' + googleEnterpriseKey+ '&address=' + address + '&sensor=false';
        }else {
            returnURL = googleMapsAPI + googleGeocodeService + '?address=' + Address + '&sensor=false';
        }
        System.debug('******Google Map URL ' + returnURL);
        return returnURL;
    }
    
    /*private static String getGoogleSignatureForURL(String theURL, String key){
        String retval = '';
        String algorithmName = 'HMacSHA1';
        key = key.replace('-', '+');
        key = key.replace('_', '/');
        Blob mac = Crypto.generateMac(algorithmName, Blob.valueOf(theURL), EncodingUtil.base64Decode(key));
        retval = EncodingUtil.base64Encode(mac).replace('+', '-').replace('/', '_');
        return retval;
    }*/

    @TestVisible
    private static GeocodeResult parseResponse(String responseBody){
        GeocodeResult result = new GeocodeResult();
        JSONParser parser = JSON.createParser(responseBody);
        while (parser.nextToken() != null){
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')){                
                parser.nextToken();
                while (parser.nextToken() != JSONToken.END_OBJECT){
                    String txt = parser.getText();
                    parser.nextToken();
                    if(txt == 'lat'){
                        result.addressLat = parser.getText();
                    }else if (txt == 'lng'){
                        result.addressLng = parser.getText();
                    }
                }
            }
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'status')){
                parser.nextToken();             
                result.status = parser.getText();
            }
        }
        return result;
    }

    public class GeocodeResult {
        public String status {
          get;
          set {
                if(String.isNotEmpty(value)) {
                    if(value.equalsIgnoreCase('Ok')) {
                        status = 'Success';
                    } else {
                        status = value;
                    }
                } else {
                    status = 'Empty Response';
                }
            
          }
        }
        public String addressLat;   //latitude
        public String addressLng;   //longitude        
        
        public decimal getLatValue(){
            return addressLat == null? null : decimal.valueOf(addressLat);
        } 
        
        public decimal getLngValue(){
            return addressLng == null? null : decimal.valueOf(addressLng);
        }
    }

}