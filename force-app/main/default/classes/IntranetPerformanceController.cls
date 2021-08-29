/**
  * Apex Class: IntranetPerformanceController
  * Description: This class is used to fetch the Performance data
  * CreatedBy : Harshit Jain
  * LastModifiedDate : Feb 15, 2012
  * LastModifiedBy   : June 21,2013         Harshit Jain        Show latest data for categories comes from custom setting on Performance component.
  * Last Modified 24th Nov, 2014   Ashish Sharma, Move placement of stock ticker information,
                                    move date on Performance box, and add link to Investor relations
                                    (Ref - T-336107)
  * Last Modified 25th Nov, 2014   Ashish Sharma, Change color of font for stock quote text on hover, remove date, fix spelling(Ref - T-336378)
  * Last Modified 2nd Dec, 2014   Rahul Mittal, Dynamic calculation of safety in the Performance section(Ref - T-337044)
*/
public with sharing class IntranetPerformanceController {

  public String defined_date_format {get;set;}
  public Map<String,List<PerformanceWrapper>> monthlyPerformanceMap{get;set;}
  public Map<String,List<PerformanceWrapper>> quarterlyPerformanceMap{get;set;}
  public Map<String,List<PerformanceWrapper>> yearlyPerformanceMap{get;set;}
  public String stockQuote {get; set;}

    private String templateName {get;set;}
    private static final String LATEST_RECORD_CATEGORY ;
    public List<PerformanceWrapper> performanceWrapperList {get;set;}
    //Map store latest record summary detail of categories specified in custom setting
    private Map<String, Map<String,List<PerformanceWrapper>>> LatestSummaryPerformanceMap {get;set;}

    static {
        Intranet_Config__c conObject = Intranet_Config__c.getInstance('Latest_Record_Category_For_Performance');
        LATEST_RECORD_CATEGORY = (conObject != null && conObject.Value__c != null) ? conObject.Value__c : '';
    }

    /*******************************************************************
    * Initializes the public,private member maps
  * To show summaries data on page according to month,quarter and year.
    ********************************************************************/
    public IntranetPerformanceController() {
        monthlyPerformanceMap = new Map<String,List<PerformanceWrapper>>();
        quarterlyPerformanceMap = new Map<String,List<PerformanceWrapper>>();
        yearlyPerformanceMap = new Map<String,List<PerformanceWrapper>>();
        //TimeFrame, Category and their field warapper List
        LatestSummaryPerformanceMap = new Map<String, Map<String,List<PerformanceWrapper>>>();
        defined_date_format = Datetime.now().format('MMMM d, yyyy hh:mm:ss a', 'PST');
        initialization();
        if(String.isNotBlank(LATEST_RECORD_CATEGORY)) {
            PopulateLatestData(performanceWrapperList, LATEST_RECORD_CATEGORY);
        }
        populateMonthData(performanceWrapperList);
        populateQuarterData(performanceWrapperList);
        populateYearData(performanceWrapperList);

        stockQuote = '';

        try{
              // Instantiate a new http object
              Http h = new Http();

              // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
              HttpRequest req = new HttpRequest();
              req.setEndpoint('http://www.google.com/finance/info?q=NASDAQ:%20VA');
              req.setMethod('GET');

              // Send the request, and return a response
              HttpResponse res = h.send(req);

              if(res != null && res.getBody() != null){
                  JSONParser parser = JSON.createParser(res.getBody().replace('//', ''));
                  while (parser.nextToken() != null) {
                    if (parser.getText().equals('l')) {
                        parser.nextToken();
                        stockQuote  = parser.getText();
                    }
                  }
              }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }

    /***********************************************
    * Intialization of public and private members
    ************************************************/
    private void initialization() {
        templateName = 'Home';
        performanceWrapperList = new List<PerformanceWrapper>();
        if(Apexpages.currentPage().getParameters().get('tabName') != null) {
            templateName = Apexpages.currentPage().getParameters().get('tabName');
        }

        for(Intranet_Performance_Config__c performanceConfig : Intranet_Performance_Config__c.getAll().values()) {
            if(performanceConfig.Name.contains(templateName)) {
                for(String fieldAPIName : performanceConfig.Field_API_Names__c.split(',',0)) {
                    performanceWrapperList.add(new PerformanceWrapper(fieldAPIName, 0 ,performanceConfig));
                }
            }
        }
    }

    /***************************************************************
    * Populate LatestSummaryPerformanceMap that have latest record,
    * summary detail of categories specified in custom setting .
    *   Map Format(TimeFrame, Category and their warapper objects List)
    *****************************************************************/
    private void PopulateLatestData(List<PerformanceWrapper> performanceWrapperList, String Category) {
        List<PerformanceWrapper> LatestPerformanceList = new List<PerformanceWrapper>();
        for(PerformanceWrapper config:performanceWrapperList) {
            if(Category.containsIgnoreCase(config.categoryName)) {
                LatestPerformanceList.add(config);
            }
        }

        if(LatestPerformanceList.size() > 0) {
            populateLatestSummaryDetail(LatestPerformanceList);
        }
    }

    /***********************************************************
    * Populate monthlyPerformanceMap that have summary(avarage)
    *   detail of all fields for the current month records
    ************************************************************/
    private void populateMonthData(List<PerformanceWrapper> performanceWrapperList) {
        Set<String> latestRecordCategory = new Set<String>();
        Map<String,PerformanceWrapper> monthPerformanceMap = new map<String,PerformanceWrapper>();
        for(PerformanceWrapper config:performanceWrapperList) {
            if(config.timeFrame == 'Month To Date') {
                if(LATEST_RECORD_CATEGORY.containsIgnoreCase(config.categoryName)) {
                    latestRecordCategory.add(config.categoryName);
                } else {
                    monthPerformanceMap.put(config.fieldAPIName, config);
                }

            }
        }
        //Add Avarage record category in Map
        if(monthPerformanceMap.size()  > 0) {
            monthlyPerformanceMap = populateAvgSummaryDetail(monthPerformanceMap, 'Month To Date');
        }

        //Add Latest record category in Map
        if(LatestSummaryPerformanceMap.containsKey('Month To Date')) {
            for(String performanceCategory : latestRecordCategory) {
                if(LatestSummaryPerformanceMap.get('Month To Date').ContainsKey(performanceCategory)) {
                    monthlyPerformanceMap.put(performanceCategory, LatestSummaryPerformanceMap.get('Month To Date').get(performanceCategory));
                }
            }
        }
    }

    /************************************************************
    * Populate quarterlyPerformanceMap that have summary(avarage)
    * detail of all fields for the current quater records
    ************************************************************/
    private void populateQuarterData(List<PerformanceWrapper> performanceWrapperList) {
        Set<String> latestRecordCategory = new Set<String>();
        Map<String,PerformanceWrapper> quarterPerformanceMap = new map<String,PerformanceWrapper>();
        for(PerformanceWrapper config:performanceWrapperList) {
            if(config.timeFrame == 'Quarter To Date') {
                if(LATEST_RECORD_CATEGORY.containsIgnoreCase(config.categoryName)) {
                    latestRecordCategory.add(config.categoryName);
                } else {
                    quarterPerformanceMap.put(config.fieldAPIName, config);
                }
            }
        }

        //Add Avarage record category in Map
        if(performanceWrapperList.size() > 0) {
            quarterlyPerformanceMap = populateAvgSummaryDetail(quarterPerformanceMap, 'Quarter To Date');
        }

        //Add Latest record category in Map
        if(LatestSummaryPerformanceMap.containsKey('Quarter To Date')) {
            for(String performanceCategory : latestRecordCategory) {
                if(LatestSummaryPerformanceMap.get('Quarter To Date').ContainsKey(performanceCategory)) {
                    quarterlyPerformanceMap.put(performanceCategory, LatestSummaryPerformanceMap.get('Quarter To Date').get(performanceCategory));
                }
            }
        }
    }

    /************************************************************
    * Populate yearlyPerformanceMap that have summary(avarage)
    * detail of all fields for the current year records
    ************************************************************/
    private void populateYearData(List<PerformanceWrapper> performanceWrapperList) {
        Set<String> latestRecordCategory = new Set<String>();
        Map<String,PerformanceWrapper> yearPerformanceMap = new map<String,PerformanceWrapper>();
        for(PerformanceWrapper config:performanceWrapperList) {
            if(config.timeFrame == 'Year To Date') {
                if(LATEST_RECORD_CATEGORY.containsIgnoreCase(config.categoryName)) {
                    latestRecordCategory.add(config.categoryName);
                } else {
                    yearPerformanceMap.put(config.fieldAPIName, config);
                }
            }
        }

        //Add Avarage record category in Map
        if(performanceWrapperList.size() > 0) {
            yearlyPerformanceMap = populateAvgSummaryDetail(yearPerformanceMap, 'Year To Date');
        }

        //Add Latest record category in Map
        if(LatestSummaryPerformanceMap.containsKey('Year To Date')) {
            for(String performanceCategory : latestRecordCategory) {
                if(LatestSummaryPerformanceMap.get('Year To Date').ContainsKey(performanceCategory)) {
                    yearlyPerformanceMap.put(performanceCategory, LatestSummaryPerformanceMap.get('Year To Date').get(performanceCategory));
                }
            }
        }
    }

    /************************************************************************
    * Return summaries/Avarage detail of all records based on time frame
    * @performanceFieldMap : map of field and and Preformance wrapper class
    * @timeFrame : 'Month To date','Quarter To Date','Year To Date'
    *************************************************************************/
    private Map<String,List<PerformanceWrapper>> populateAvgSummaryDetail(Map<String,PerformanceWrapper> performanceFieldMap, String timeFrame) {
        Map<String,List<PerformanceWrapper>> summaryPerformanceMap = new Map<String,List<PerformanceWrapper>>();
        //for(AggregateResult ar : Database.query(createAggregateQuery(performanceFieldMap, timeFrame))){
        for(Intranet_Performance__c performanceObj : Database.query(selectQuery(performanceFieldMap, timeFrame))){          
            for(String key: performanceFieldMap.keySet()) {
                PerformanceWrapper wrapperObj = performanceFieldMap.get(key);
                wrapperObj.fieldValue = Double.valueOf(performanceObj.get(key));
                if(summaryPerformanceMap.containsKey(wrapperObj.categoryName)) {
                    summaryPerformanceMap.get(wrapperObj.categoryName).add(wrapperObj);
                }else {
                    List<PerformanceWrapper> perWrapperList = new List<PerformanceWrapper>();
                    perWrapperList.add(wrapperObj);
                    summaryPerformanceMap.put(wrapperObj.categoryName, perWrapperList);
                }
            }
        }
        return summaryPerformanceMap;
    }


    /************************************************************************
    * Return latest summary detail from latest record based on time frame
    * @LatestPerformanceList : List of Preformance wrapper class objects,which required lateset Summary
    *************************************************************************/
    private void populateLatestSummaryDetail(List<PerformanceWrapper> LatestPerformanceList) {
        for(Intranet_Performance__c performanceObj : Database.query(createQuery(LatestPerformanceList))){
            for(PerformanceWrapper wrapperObj : LatestPerformanceList) {
                wrapperObj.fieldValue = Double.valueOf(performanceObj.get(wrapperObj.fieldAPIName));
                if(LatestSummaryPerformanceMap.containsKey(wrapperObj.timeFrame)) {
                    if(LatestSummaryPerformanceMap.get(wrapperObj.timeFrame).containsKey(wrapperObj.categoryName)) {
                        LatestSummaryPerformanceMap.get(wrapperObj.timeFrame).get(wrapperObj.categoryName).add(wrapperObj);
                    }else {
                        LatestSummaryPerformanceMap.get(wrapperObj.timeFrame).put(wrapperObj.categoryName, new List<PerformanceWrapper>{wrapperObj});
                    }
                }else {
                    Map<String,List<PerformanceWrapper>> categoryPerformanceMap = new Map<String,List<PerformanceWrapper>>();
                    categoryPerformanceMap.put(wrapperObj.categoryName, new List<PerformanceWrapper>{wrapperObj});
                    LatestSummaryPerformanceMap.put(wrapperObj.timeFrame,categoryPerformanceMap);
                }
            }
        }
    }
    
    /********************************************************************************************
    * Create Aggregate soql query for month to date, Quarter to date and Year to date time frame
    *********************************************************************************************/
    private String selectQuery(Map<String,PerformanceWrapper> performanceMap, String timeFrame) {
        String query = 'Select ';
        for(String field : performanceMap.keySet()) {
            query += field + ', ';
        }
        query = query.substringBeforeLast(',');
        query += ' From Intranet_Performance__c where Date__c = ';
        query += (timeFrame == 'Month To Date') ? 'THIS_MONTH' : ((timeFrame == 'Quarter To Date') ? 'THIS_QUARTER' : 'THIS_YEAR');
        query += ' and Name LIKE \'';
        query += (timeFrame == 'Month To Date') ? 'Monthly' : ((timeFrame == 'Quarter To Date') ? 'Quarterly' : 'Yearly');
        query += '%\' Order By Date__c DESC Limit 1';
        
        return query;
    }

    /********************************************************************************************
    * Create Aggregate soql query for month to date, Quarter to date and Year to date time frame
    *********************************************************************************************/
    private String createAggregateQuery(Map<String,PerformanceWrapper> performanceMap, String timeFrame) {
        String query = 'Select';
        for(String field : performanceMap.keySet()) {
            query += ' AVG('+ field +') '+ field.substring(0, ((field.length() < 24) ? field.length() : 24)) +', ';
        }
        query = query.substringBeforeLast(',');
        query += ' From Intranet_Performance__c where Date__c = ';
        query += (timeFrame == 'Month To Date') ? 'THIS_MONTH' : ((timeFrame == 'Quarter To Date') ? 'THIS_QUARTER' : 'THIS_YEAR');
  
        return query;
    }

    /*********************************************************************************
    * Create soql query for latest data.
    **********************************************************************************/
    private String createQuery(List<PerformanceWrapper> performanceList) {
        String query = 'Select ';
        for(PerformanceWrapper performanceObj : performanceList) {
            if(!query.containsIgnoreCase(performanceObj.fieldAPIName)) {
                query += performanceObj.fieldAPIName +', ';
            }
        }
        query = query.substringBeforeLast(',');
        query += ' From Intranet_Performance__c Order By Date__c DESC Limit 1';
        return query;
    }

    /***********************************************************
    * Wrapper class handle all custom setting data.
    ************************************************************/
    public class PerformanceWrapper {
        public String fieldAPIName{get;set;}
        public String fieldDataType{get;set;}
        public Double fieldValue{get;set;}
        public String timeFrame{get;set;}
        public String categoryName{get;set;}
        public String templateName{get;set;}

        public PerformanceWrapper(String fieldAPIName, Integer fieldValue, Intranet_Performance_Config__c performanceConfig){
          this.fieldDataType = String.ValueOf(Schema.sObjectType.Intranet_Performance__c.fields.getMap().get(fieldAPIName).getDescribe().getType());
            this.fieldAPIName = fieldAPIName;
            this.fieldValue = fieldValue;
          this.timeFrame = performanceConfig.Time_Frame__c;
            this.categoryName = performanceConfig.Category_Label__c;
          this.templateName = performanceConfig.TemplatePage__c;
        }
    }
}