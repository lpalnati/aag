/**
 * Created by naticmac on 2017/2/24.
 */

@IsTest
private class PwCCAPGeoServiceCtrlTest {
    @TestSetup
    public static void setup() {
        Map_GEO_Configuration__c geo = new Map_GEO_Configuration__c();
        geo.Name                         = 'Account';
        geo.Object_Display_Name__c       = 'Account1';
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

        Map_Search_Configuration__c mapSearch = new Map_Search_Configuration__c();
        mapSearch.Name                     = 'Low Profit';
        mapSearch.Search_Field__c          = 'Is_Low_Profitability__c';
        mapSearch.Reflect__c               = true;
        mapSearch.Search_Object__c         = geo.Id;
        mapSearch.Default_Search_Select__c = 'TRUE';
        mapSearch.Sequence__c              = 2;
        mapSearch.Active__c                = true;
        insert  mapSearch;

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
        System.debug(acc);
    }

    static testMethod void testBehavior() {
        PwCCAPGeoServiceCtrl ctrl = new PwCCAPGeoServiceCtrl();
       PwCCAPGeoServiceCtrl.CommonResult result1 = PwCCAPGeoServiceCtrl.getObjects();
       //PwCCAPGeoServiceCtrl.CommonResult result1 = [SELECT Id, Name,Geo__Latitude__s,Geo__Longitude__s FROM Account WHERE Name='Test Caasdaampany']; 
        PwCCAPGeoServiceCtrl.runBatchJob();
        PwCCAPGeoServiceCtrl.getGeoRecordCount('PwCCAPGeoAccount', false);
        PwCCAPGeoServiceCtrl.GeoInput input = new PwCCAPGeoServiceCtrl.GeoInput();
        input.Message = 'SUCCESS';
        Account acc = [SELECT Id FROM Account LIMIT 1];
        input.Obj = acc;
        PwCCAPGeoServiceCtrl.GeoOutput output = PwCCAPGeoServiceCtrl.getGeoRecord('PwCCAPGeoAccount', false, input);
        PwCCAPGeoServiceCtrl.GeoOutput output2= PwCCAPGeoServiceCtrl.getGeoRecord('PwCCAPGeoAccount', true, input);
        //PwCCAPGeoServiceCtrl.GeoOutput output3= PwCCAPGeoServiceCtrl.getGeoRecord('PwCCAPGeoAccount', False, input);
        PwCCAPGeoGeneral abs = new PwCCAPGeoGeneral('PwCCAPGeoAccount');
        abs.getdisplayname();

        PwCCAPGeoServiceUtil.geoSingleSobject('Account', acc.Id, 'PwCCAPGeoAccount');
    }
}