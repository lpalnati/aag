/*******************************************************************
* Author        :  Harshit Jain 
* Name          :  IntranetMenuController
* Date          :  December 04,2012
* Description   :  Controller for IntranetMenu             
*******************************************************************/
public without sharing class IntranetMenuController {
	
	//map to hold result. The result will have cms page name and their respective parent page name.
  public Map <String, String> parentTabMap {get; set;}
  //map that will hold cms page name and list of all child pages 
  public Map<String, List<IntranetWrapper>> aMap {get; set;}
  //String that will used to create HTML for intranet Menu
  public String ulString {get; set;}
  //String used to create HTML for subMenu
  public Integer ulLabel {get; set;}
  //List that hold IntranetWrapper class list
  public List<IntranetWrapper> finalMenuList {get; set;}
  //String used to select tab on Inranet pages.
  private String tabName {get;set;}
  public String AndroidMarketplaceUrl {get; set;}
  public String IOSMarketplaceUrl {get; set;}
	private Integer menuSequence{get;set;}
	
  public IntranetMenuController() {
  	menuSequence = 1;
  	tabName = '';
    ulString = '';
    ulLabel = 1;
    finalMenuList =  new List<IntranetWrapper>();
    aMap = new Map<String, List<IntranetWrapper>>();
   	parentTabMap = new map<String, String>();
   	AndroidMarketplaceUrl = (Intranet_Config__c.getInstance('Android_Marketplace_URL') != null) ? Intranet_Config__c.getInstance('Android_Marketplace_URL').Value__c : '';
   	IOSMarketplaceUrl = (Intranet_Config__c.getInstance('IOS_Marketplace_URL') != null) ? Intranet_Config__c.getInstance('IOS_Marketplace_URL').Value__c : '';
    getMenuList();
  }
	
	//Method will craete menu list that will be used on Intranet pages to show menu bar.
  public void getMenuList() {
  	//List to hold all top level CMS pages.
    List<IntranetWrapper> intraListWithNull = new List<IntranetWrapper>();
    for(Intranet_CMS_Page__c obj : [Select Id, Parent_page__c,URL__c, Parent_page__r.Name,
                                                   Skip_Menu_Link__c, Name,Template__c, Sequence__c,Target__c
                                              from Intranet_CMS_Page__c 
                                             where Status__c = 'Published'
                                             	 AND Show_In_Header_Menu__c = true 
                                          order by Parent_page__c,Sequence__c ]) {
    	//populate parentTabMap will have cms page name and their respective parent page name
    	parentTabMap.put(obj.Name, obj.Parent_page__r.Name);
      IntranetWrapper intraWrapper = new IntranetWrapper(obj);
      if(obj.Parent_page__c == null) {
        intraListWithNull.add(intraWrapper);
        aMap.put(obj.id, new List<IntranetWrapper> ());
      } else {
        if (!aMap.containsKey(obj.Parent_page__c)) {
          aMap.put(obj.Parent_page__c, new List<IntranetWrapper>());
        }
        aMap.get(obj.Parent_page__c).add(intraWrapper);     
      }
    } 
    aMap.put(null, intraListWithNull);   
    finalMenuList = addNodeToList( aMap, finalMenuList, null); 
    createMenu( finalMenuList );
    ulString = '<ul class="menu">' + ulString + '</ul>';
  }
  
  // Method used to create HTML string for Menu bar that will be used on all Intranet Pages  
  public void createMenu( List<IntranetWrapper> menuList ) {
    String url = '';
    String liClass = '';
    for(IntranetWrapper temp : menuList) {
    	url = '#';  
        if(temp.skipMenuLink != true) {
            if(temp.Url != null) {
                url = '/apex/IntranetRouter?Id='+temp.id+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode(temp.Url, 'UTF-8');
            }else {
			        if(temp.template == 'Home') {
			            url = '/apex/IntranetRouter?Id='+temp.id+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetHome', 'UTF-8');
			        }else if(temp.template == 'Interior Home') {
			            url = '/apex/IntranetRouter?Id='+temp.id+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetHome?tabName='+temp.name, 'UTF-8');
			        }else if(temp.template == 'Team') {
			    				getParentpageName(temp.name);
			            url = '/apex/IntranetRouter?Id='+temp.id+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetTeam?&name='+temp.name+'&tabName='+tabName , 'UTF-8');
			      	}else if(temp.template == 'Content') {
			      			getParentpageName(temp.name);
			            url = '/apex/IntranetRouter?Id='+temp.id+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetContent?Id=' + temp.id + '&category=Content&tabName='+tabName, 'UTF-8');
			      	}else if(temp.template == 'Secure') {
			      			getParentpageName(temp.name);
			            url = '/apex/IntranetRouter?Id='+temp.id+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetSecuredTeam?&name='+temp.name+'&tabName='+tabName , 'UTF-8');
				      }else if(temp.template == 'Contractor') {
				      		getParentpageName(temp.name);
				           url = '/apex/IntranetRouter?Id='+temp.id+'&type=Intranet_CMS_Page__c&path='+EncodingUtil.urlEncode('/apex/IntranetContractor?&name='+temp.name+'&tabName='+tabName , 'UTF-8');
				      }
       		}
        }
        //Crete HTML String with respective linked URL and CSS classes 
        if(temp.subList == null){
        	liClass = ulLabel <= 1 ? ('lv1 ' + temp.name.toLowerCase()) : ('lv2');
        	if(temp.name.equalsIgnoreCase('Home')){
        		liClass = 'lv1 active ' + temp.name.toLowerCase();
        	} 
        	ulString = ulString + '<li class=\"'+ liClass +'\"><a href=\"'+ url +'\" target=\"'+ temp.target +'\">' + temp.name+ '</a>';
        }
        else if( temp.subList.isEmpty() ){
        	liClass = ulLabel <= 1 ? ('lv1 ' + temp.name.toLowerCase()) : ('lv2');
        	if(temp.name.equalsIgnoreCase('Home')){
        		liClass = 'lv1 active ' + temp.name.toLowerCase();
        	}
        	ulString = ulString + '<li class=\"'+ liClass +'\"><a href=\"'+ url +'\" target=\"'+ temp.target +'\">' + temp.name+ '</a>';
        	menuSequence++;
        }
        else{
        	liClass = ulLabel <= 1 ? ('lv1 withSub ' + temp.name.toLowerCase()) : ('lv2 withSub');
        	if( ulLabel <= 1 ){
        		ulString = ulString + '<li class=\"'+ liClass +'\"><a href=\"'+ url +'\" target=\"'+ temp.target +'\">' + temp.name+ '<span class="arrow"></span></a>';	
        	}
        	else{
        		ulString = ulString + '<li class=\"'+ liClass +'\"><a href=\"'+ url +'\" target=\"'+ temp.target +'\">' + temp.name+ '</a>';
        	}
        	ulString = ulString + '<ul class=\"submenu\">';
        	ulLabel++;
            createMenu( temp.subList);
            ulString = ulString + '</ul>';
            menuSequence++;
            ulLabel--;
        }
      	ulString = ulString + '</li>';
    }
  }
  
  //Wrapper class used to create CSM pages list with child parent relationship 
  public class IntranetWrapper {
    public String id {get; set;}
    public String parent {get; set;}
    public Integer flag {get; set;}
    public List <IntranetWrapper> subList {get;set;}
    public String name {get; set;}
    public String Url {get;set;}
    public String template {get;set;}
    public Boolean skipMenuLink {get;set;}
    public String sequence {get;set;}
    public String target {get;set;}
        
    public IntranetWrapper(Intranet_CMS_Page__c intra) {
        this.id = intra.id;
        this.parent = intra.Parent_page__c;
        this.flag = 0;
        this.subList = null;
        this.name = intra.name;
        this.Url = intra.URL__c;
        this.template = intra.Template__c;
        this.skipMenuLink = intra.Skip_Menu_Link__c;
        this.sequence = intra.Sequence__c;
        this.target = intra.Target__c;
    }
        
    public IntranetWrapper(String id, String parent, Integer flag, List<IntranetWrapper> subList, String name,String Url,String template,Boolean skipMenuList,String target) {
        this.id = id; 
        this.parent = parent; 
        this.flag = flag; 
        this.subList = subList; 
        this.name = name;
        this.Url = Url;
        this.template = template;
        this.skipMenuLink = skipMenuList;
        this.target = target;
    }
  }
  
  //Method is used create list of cms Pages with thier related child list.
  //Recursive process is used to create list of CMS page with list of related child 
  public static List<IntranetWrapper> addNodeToList( Map<String, List<IntranetWrapper>> menuMap, List<IntranetWrapper> menuList, String id ){
    for(IntranetWrapper intranetWrapper : menuMap.get(id)){     
      if(menuMap.get(intranetWrapper.id) == null){
        menuList.add(new IntranetWrapper(intranetWrapper.id, id, 0, null, intranetWrapper.name,intranetWrapper.Url,intranetWrapper.template, intranetWrapper.skipMenuLink, intranetWrapper.target));
      }
      else{
        List<IntranetWrapper> subMenuList = new List<IntranetWrapper>();
        menuList.add(new IntranetWrapper(intranetWrapper.id, id, 1, addNodeToList(menuMap, subMenuList, intranetWrapper.id), intranetWrapper.name, intranetWrapper.Url, intranetWrapper.template, intranetWrapper.skipMenuLink, intranetWrapper.target));
      }
    }    
    return menuList;
  }
  
  //Method used resursive process to find top level parent of any CMS Page
  public void getParentpageName(String pageName) {
  	tabName = pageName;
  	if(parentTabMap.get(pageName) != null) {
  		getParentpageName(parentTabMap.get(pageName));
  	}
  }
}