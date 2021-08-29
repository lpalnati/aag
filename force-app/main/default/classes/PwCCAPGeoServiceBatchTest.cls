/**
 * Created by naticmac on 2017/2/23.
 */
@IsTest
public class PwCCAPGeoServiceBatchTest {
//Static Account accid = new Account();


    @TestSetup
    public static void setup() {
    
  
        Map_GEO_Configuration__c geo = new Map_GEO_Configuration__c();
        geo.Name                         = 'Account';
        geo.Object_Display_Name__c       = 'Account';
        geo.Object_Class_Name__c         = 'PwCCAPGeoAccount';
        geo.Active__c                    = true;
        geo.Search__c                    = true;
        geo.Icon__c                      = '/PwCCAP/icon/map7_2x.png';
        geo.Icon_Selected__c             = '/PwCCAP/icon/map4_2x.png';
        geo.Order__c                     = 2;
        geo.Mapping_Street_Field__c      = 'BillingStreet';
        geo.Mapping_City_Field__c        = 'BillingCity';
        geo.Mapping_State_Field__c       = 'BillingState';
        geo.Mapping_Postal_Code_Field__c = 'BillingPostalCode';
        geo.Mapping_Longitude_Field__c   = 'Main_Office__Longitude__s';
        geo.Mapping_Latitude_Field__c    = 'Main_Office__Latitude__s';
        geo.Mapping_API_Status_Field__c  = 'Geo_Call_Status__c';
        insert geo;
        
        
        /*Map_GEO_Configuration__c geo2 = new Map_GEO_Configuration__c();
        geo2.Name                         = 'Account2';
        geo2.Object_Display_Name__c       = 'Account';
        geo2.Object_Class_Name__c         = 'PwCCAPGeoAccount2';
        geo2.Active__c                    = True;
        geo2.Search__c                    = true;
        geo2.Icon__c                      = '/PwCCAP/icon/map7_2x.png';
        geo2.Icon_Selected__c             = '/PwCCAP/icon/map4_2x.png';
        geo2.Order__c                     = 3;
        geo2.Mapping_Street_Field__c      = 'ShippingStreet';
        geo2.Mapping_City_Field__c        = 'ShippingCity';
        geo2.Mapping_State_Field__c       = 'ShippingState';
        geo2.Mapping_Postal_Code_Field__c = 'ShippingPostalCode';
        geo2.Mapping_Longitude_Field__c   = 'Main_Office__Longitude__s';
        geo2.Mapping_Latitude_Field__c    = 'Main_Office__Latitude__s';
        geo2.Mapping_API_Status_Field__c  = 'Geo_Call_Status__c';
        insert geo2;*/

        Map_Search_Configuration__c mapSearch = new Map_Search_Configuration__c();
        mapSearch.Name                     = 'Low Profit';
        mapSearch.Search_Field__c          = 'Is_Low_Profitability__c';
        mapSearch.Reflect__c               = true;
        mapSearch.Search_Object__c         = geo.Id;
        mapSearch.Default_Search_Select__c = 'TRUE';
        mapSearch.Sequence__c              = 2;
        mapSearch.Active__c                = True;
        insert  mapSearch;


       /* Map_Search_Configuration__c mapSearch2 = new Map_Search_Configuration__c();
        mapSearch2.Name                     = 'Low Profit2';
        mapSearch2.Search_Field__c          = 'Is_Low_Profitability__c';
        mapSearch2.Reflect__c               = true;
        mapSearch2.Search_Object__c         = geo2.Id;
        mapSearch2.Default_Search_Select__c = 'TRUE';
        mapSearch2.Sequence__c              = 3;
        mapSearch2.Active__c                = False;
        insert  mapSearch2;*/
        
        
        Account acc = new Account();
        acc.Name = 'Test Caasdaampany';
        acc.BillingStreet = 'tasdest sasdatreet';
        acc.BillingCity = 'teasst cadaity';
        acc.BillingState = 'tasest state';
        acc.BillingPostalCode = '12312';
        acc.Phone = '2345678567';
        acc.Is_Low_Profitability__c = true;
        acc.Geo_Call_Status__c = 'ZERO_RESULTS';
        //acc.Geo_Location__Latitude__s = 46.7999383;
        //acc.Geo_Location__Longitude__s = -100.7881808;
        insert acc;
        //Account accid=[Select id from Account where name ='Test Caasdaampany'];

    }

    static testMethod void test() {
        //PwCCAPGeoServiceUtil.geoSingleSobject CR = new PwCCAPGeoServiceUtil.geoSingleSobject('Account', accid.id, 'PwCCAPGeoAccount');
        
        PwCCAPGeoServiceBatch bat1 = new PwCCAPGeoServiceBatch('Account', PwCCAPGeoServiceBatch.GeoType.APIName);
        Database.executeBatch(bat1, 5);

        PwCCAPGeoServiceBatch bat2 = new PwCCAPGeoServiceBatch('PwCCAPGeoAccount', PwCCAPGeoServiceBatch.GeoType.ClassName);
        Database.executeBatch(bat2, 5);

        PwCCAPGeoServiceBatch bat3 = new PwCCAPGeoServiceBatch(new List<String>{'Account'}, PwCCAPGeoServiceBatch.GeoType.DisplayName);
        Database.executeBatch(bat3, 5);

        PwCCAPGeoServiceBatch bat4 = new PwCCAPGeoServiceBatch('Account', PwCCAPGeoServiceBatch.GeoType.All);
        Database.executeBatch(bat4, 5);

        PwCCAPGeoServiceBatch bat5 = new PwCCAPGeoServiceBatch(new List<String>{'Account'}, PwCCAPGeoServiceBatch.GeoType.APIName);
        Database.executeBatch(bat5, 5);
        
        PwCCAPGeoGeneral abs = new PwCCAPGeoGeneral('PwCCAPGeoAccount');
        abs.getdisplayname();
        //PwCCAPGeoServiceBatch bat6 = new PwCCAPGeoServiceBatch(new List<String>{'Account'},PwCCAPGeoServiceBatch.GeoType.APIName, true, 0);
        //Database.executeBatch(bat6, 5);
    }

}