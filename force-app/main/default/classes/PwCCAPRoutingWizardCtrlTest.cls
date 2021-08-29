/**
 * Created by naticmac on 2017/2/22.
 */

@IsTest
private class PwCCAPRoutingWizardCtrlTest {

    @TestSetup
    public static void setup() {
        List<Routing_Wizard__c> rws = new List<Routing_Wizard__c>();
        Routing_Wizard__c rw1 = new Routing_Wizard__c();
        rw1.Name = 'Default Size';
        rw1.Value__c = '5';
        rws.add(rw1);

        Routing_Wizard__c rw2 = new Routing_Wizard__c();
        rw2.Name = 'Max Size';
        rw2.Value__c = '50';
        rws.add(rw2);

        Routing_Wizard__c rw3 = new Routing_Wizard__c();
        rw3.Name = 'Min Size';
        rw3.Value__c = '5';
        rws.add(rw3);

        Routing_Wizard__c rw4 = new Routing_Wizard__c();
        rw4.Name = 'Step Size';
        rw4.Value__c = '5';
        rws.add(rw4);

        Routing_Wizard__c rw5 = new Routing_Wizard__c();
        rw5.Name = 'Unit';
        rw5.Value__c = 'mi';
        rws.add(rw5);

        insert rws;

        Map_GEO_Configuration__c geo = new Map_GEO_Configuration__c();
        geo.Name                         = 'Account';
        geo.Object_Class_Name__c         = 'PwCCAPGeoAccount';
        geo.Object_Display_Name__c       = 'Customer';
        geo.Active__c                    = true;
        geo.Icon__c                      = '/PwCCAP/icon/map7_2x.png';
        geo.Search__c                    = true;
        geo.Icon_Selected__c             = '/PwCCAP/icon/map4_2x.png';
        geo.Order__c                     = 2;
        geo.Mapping_Street_Field__c      = 'ShippingStreet';
        geo.Mapping_City_Field__c        = 'ShippingCity';
        geo.Mapping_State_Field__c       = 'ShippingState';
        geo.Mapping_Postal_Code_Field__c = 'ShippingPostalCode';
        geo.Mapping_Longitude_Field__c   = 'Geo_Location__Longitude__s';
        geo.Mapping_Latitude_Field__c    = 'Geo_Location__Latitude__s';
        geo.Mapping_API_Status_Field__c  = 'Geo_Call_Status__c';
        geo.Null_Last__c                 = true;
        geo.Result_Size__c               = 100;
        insert geo;

        List<Map_Search_Configuration__c> searchConfs = new List<Map_Search_Configuration__c>();

        Map_Search_Configuration__c searchConf1 = new Map_Search_Configuration__c();
        searchConf1.Search_Object__c = geo.Id;
        searchConf1.Name = 'High Value';
        searchConf1.Search_Field__c = 'Is_High_Value_Customer__c';
        searchConf1.Reflect__c = true;
        searchConf1.Sequence__c = 1;
        searchConf1.Active__c = true;
        searchConfs.add(searchConf1);

        Map_Search_Configuration__c searchConf2 = new Map_Search_Configuration__c();
        searchConf2.Search_Object__c = geo.Id;
        searchConf2.Name = 'Low Profit';
        searchConf2.Search_Field__c = 'Is_Low_Profitability__c';
        searchConf2.Reflect__c = true;
        searchConf2.Sequence__c = 2;
        searchConf2.Active__c = true;
        searchConf2.Default_Search_Select__c = 'true';
        searchConfs.add(searchConf2);

        Map_Search_Configuration__c searchConf3 = new Map_Search_Configuration__c();
        searchConf3.Search_Object__c = geo.Id;
        searchConf3.Name = 'Declining';
        searchConf3.Search_Field__c = 'Is_Declining__c';
        searchConf3.Reflect__c = true;
        searchConf3.Sequence__c = 3;
        searchConf3.Active__c = true;
        searchConfs.add(searchConf3);

        Map_Search_Configuration__c searchConf4 = new Map_Search_Configuration__c();
        searchConf4.Search_Object__c = geo.Id;
        searchConf4.Name = 'Owner';
        searchConf4.Search_Field__c = 'Geo_Owner_Group__c';
        searchConf4.Search_Type__c = 'Picklist';
        searchConf4.Search_Select__c = 'My Accounts;My Store Accounts';
        searchConf4.Sequence__c = 5;
        searchConf4.Active__c = true;
        searchConfs.add(searchConf4);

        insert searchConfs;

        List<Map_Details_Configuration__c> detailConfs = new List<Map_Details_Configuration__c>();

        Map_Details_Configuration__c detailConf1 = new Map_Details_Configuration__c();
        detailConf1.Detail_Field_Display_Name__c = 'Account Name';
        detailConf1.Name = 'Name';
        detailConf1.GEO_Configuration__c = geo.Id;
        detailConf1.Active__c = true;
        detailConf1.Field_Display_Area__c = 'Info Window; Table View';
        detailConf1.Display_Sequence__c = 1;
        detailConf1.Display__c = true;
        detailConf1.Searchable__c = true;
        detailConf1.Order__c = true;
        detailConf1.Order_Sequence__c = 1;
        detailConfs.add(detailConf1);

        insert detailConfs;

    }

    static testMethod void testBehavior() {
        PwCCAPRoutingWizardCtrl ctrl = new PwCCAPRoutingWizardCtrl();
        PwCCAPRoutingWizardCtrl.getInitialResultWhenPageLoad();
        My_Location__c location = new My_Location__c();
        location.Name = 'Test_Location';
        PwCCAPRoutingWizardCtrl.CommonResult result = PwCCAPRoutingWizardCtrl.addToMyLocation(location);
        PwCCAPRoutingWizardCtrl.deleteMyLocation(location);
        Event event = new Event();
        PwCCAPRoutingWizardCtrl.insertEvent(event);
        Task task = new Task();
        PwCCAPRoutingWizardCtrl.insertTask(task);

        PwCCAPRoutingWizardCtrl.Location loc = new PwCCAPRoutingWizardCtrl.Location();
        loc.Longitude = -79.23532590000002;
        loc.Latitude = 42.0970023;

        List<PwCCAPRoutingWizardCtrl.SearchConfiguration> searchConfs = new List<PwCCAPRoutingWizardCtrl.SearchConfiguration>();
        PwCCAPRoutingWizardCtrl.SearchConfiguration       searchConf  = new PwCCAPRoutingWizardCtrl.SearchConfiguration();
        searchConf.DisplayName = 'Owner';
        searchConf.InputType = 'Picklist';
        searchConf.OutPut1 = 'My Accounts';
        searchConf.IsRange = false;
        searchConfs.add(searchConf);

        List<PwCCAPRoutingWizardCtrl.SearchFilter> searchFilters = new List<PwCCAPRoutingWizardCtrl.SearchFilter>();
        PwCCAPRoutingWizardCtrl.SearchFilter       searchFilter  = new PwCCAPRoutingWizardCtrl.SearchFilter();
        searchFilter.SearchObj = 'Customer';
        searchFilter.SearchConfigs = searchConfs;
        searchFilters.add(searchFilter);

        PwCCAPRoutingWizardCtrl.SearchResult sResult = PwCCAPRoutingWizardCtrl.queryData(searchFilters, loc);

    }
}