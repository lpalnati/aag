/**
  * Apex Class: IntranetPerformanceControllerTest
  * Description: test class for IntranetPerformanceController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
  * LastModifiedBy   : June 21,2013         Harshit Jain        Test Functionality (Show latest data for categories comes from custom setting)
*/
@isTest
private class IntranetPerformanceControllerTest {
    
    private static testmethod void PerformanceControllerTest(){
        createDummyData();
        IntranetPerformanceController intranetPerformanceCon = new IntranetPerformanceController();
        //assert month to Date data
        system.assertNotEquals(null, intranetPerformanceCon.monthlyPerformanceMap.get('Operations'));
        system.assertEquals(91.0, intranetPerformanceCon.monthlyPerformanceMap.get('Operations').get(0).fieldValue);
        
        //assert month to Date data for 'safety' category contian latest record summary 
        system.assertNotEquals(null, intranetPerformanceCon.monthlyPerformanceMap.get('Safety'));
        system.assertEquals(11.0, intranetPerformanceCon.monthlyPerformanceMap.get('Safety').get(0).fieldValue);
        
        //assert Quarter to Date data
        //system.assertNotEquals(null, intranetPerformanceCon.quarterlyPerformanceMap.get('Operations'));
        //assert Year to Date data
        system.assertNotEquals(null, intranetPerformanceCon.monthlyPerformanceMap.get('Operations'));
        //assert Year to Date data
        system.assertNotEquals(null, intranetPerformanceCon.monthlyPerformanceMap.get('Operations'));
        
    }
    
    private static void createDummyData() {
        
        //Insert 'Intranet_Config__c' custom setting 
        Intranet_Config__c config = new Intranet_Config__c(Name = 'Latest_Record_Category_For_Performance', value__c = 'Safety;');
        insert config;
        
        List<Intranet_Performance_Config__c> perConfigList = new List<Intranet_Performance_Config__c>();
        Intranet_Performance_Config__c perConfig1 = TestUtil.createIntranetPerformanceConfig();
        perConfig1.Name = 'Home Opertaion Month';
        perConfig1.Field_API_Names__c = 'Load_Factor__c';
        perConfig1.TemplatePage__c = 'Home';
        perConfig1.Time_Frame__c = 'Month To Date';
        perConfig1.Category_Label__c = 'Operations';
        perConfigList.add(perConfig1);
        
        Intranet_Performance_Config__c perConfig2 = TestUtil.createIntranetPerformanceConfig();
        perConfig2.Name = 'Home Opertaion Quarter';
        perConfig2.Field_API_Names__c = 'Load_Factor__c';
        perConfig2.TemplatePage__c = 'Home';
        perConfig2.Time_Frame__c = 'Quarter To Date';
        perConfig2.Category_Label__c = 'Operations';
        perConfigList.add(perConfig2);
        
        Intranet_Performance_Config__c perConfig3 = TestUtil.createIntranetPerformanceConfig();
        perConfig3.Name = 'Home Opertaion year';
        perConfig3.Field_API_Names__c = 'Load_Factor__c';
        perConfig3.TemplatePage__c = 'Home';
        perConfig3.Time_Frame__c = 'Year To Date';
        perConfig3.Category_Label__c = 'Operations';
        perConfigList.add(perConfig3);
        
        Intranet_Performance_Config__c perConfig4 = TestUtil.createIntranetPerformanceConfig();
        perConfig4.Name = 'Home Safety Month';
        perConfig4.Field_API_Names__c = 'Days_since_aircraft_damage__c';
        perConfig4.TemplatePage__c = 'Home';
        perConfig4.Time_Frame__c = 'Month To Date';
        perConfig4.Category_Label__c = 'Safety';
        perConfigList.add(perConfig4);
        
        Intranet_Performance_Config__c perConfig5 = TestUtil.createIntranetPerformanceConfig();
        perConfig5.Name = 'Home Safety Quarter';
        perConfig5.Field_API_Names__c = 'Days_since_aircraft_damage__c';
        perConfig5.TemplatePage__c = 'Home';
        perConfig5.Time_Frame__c = 'Quarter To Date';
        perConfig5.Category_Label__c = 'Safety';
        perConfigList.add(perConfig5);
        
        Intranet_Performance_Config__c perConfig6 = TestUtil.createIntranetPerformanceConfig();
        perConfig6.Name = 'Home Safety Year';
        perConfig6.Field_API_Names__c = 'Days_since_aircraft_damage__c';
        perConfig6.TemplatePage__c = 'Home';
        perConfig6.Time_Frame__c = 'Year To Date';
        perConfig6.Category_Label__c = 'Safety';
        perConfigList.add(perConfig6);
        
        insert perConfigList;

        
        List<Intranet_Performance__c> performanceList = new List<Intranet_Performance__c>();
        for(Integer i=1; i<5; i++){
            Intranet_Performance__c intranetPerformance = TestUtil.createIntranetPerformance(false);
            intranetPerformance.Name = intranetPerformance.Name + i;
            intranetPerformance.Load_Factor__c = 90 + i;
            intranetPerformance.Cost_per_gallon_weekly__c = 1.44 + i;
            intranetPerformance.Days_since_aircraft_damage__c = 10 + i;
            intranetPerformance.YTD_injuries__c = 12 + i;
            intranetPerformance.Date__c = ((i == 1) ? Date.today() :((i==2)? Date.today():((i==3) ? Date.today().addMonths(-1): Date.today().addMonths(-5))));
            performanceList.add(intranetPerformance);   
        }
        
        insert performanceList;
    }
}