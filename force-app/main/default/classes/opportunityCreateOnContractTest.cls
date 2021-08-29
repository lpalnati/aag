/**
  * Apex Class: IntranetContentControllerTest
  * Description: test class for IntranetContentController
  * Created By: Lakshmi Palnati
  * Created Date: 6 Feb,2018
*/
@isTest
private class opportunityCreateOnContractTest {
  
  //Insert contract record
  @isTest static void createContractDataTest() {
  
    //String a = [select Id from Account where Name='10mm below LLC' limit 1].id;
    //if (a != null) {
  
    //Contract c = new Contract( Name = 'lTest1', Accountid= a, AAG_Account_Manager__c='Contact 1', 
                                 //AAG_Contract_End_Date__c=Date.Today());
    //insert c;
    
    Account a1 = new Account();
    a1.name= 'test account';
    insert a1;
    Account a= [SELECT Id, name FROM Account where name ='test account' limit 1];
    // Create the contract
    if (a != null) {
    Contract c = new Contract();
    c.accountid = a.id;
    c.ContractTerm = 12;
    c.name='lTest1';
    c.StartDate = system.today();
    c.AAG_Contract_End_Date__c= system.today()+90;
    c.AAG_Contract_Expiring_in_90_Days__c = False;
    c.Status = 'Draft';
   // c.OwnerExpirationNotice = '30';
   // c.Importe__c = opp.Amount;
   // c.Amount__c = opp.Amount;
    insert c;
    // Activate the contract
    

    //update c;
    
    
    
    //}
    
    
    
   Contract c1 = [select Id, Ownerid, name, AAG_Contract_End_Date__c, AAG_Contract_Expiring_in_90_Days__c from Contract where Name='lTest1'];
    
    c1.AAG_Contract_Expiring_in_90_Days__c= True;
    update c1;
    
   // c = [select Id, Ownerid, name, AAG_Contract_End_Date__c, AAG_Contract_Expiring_in_90_Days__c from Contract where Name='lTestU1'];

  //  c.AAG_Contract_Expiring_in_90_Days__c = True;
   // update c;
    
    //system.assertEquals(c.AAG_Contract_Expiring_in_90_Days__c, False);
  
    /*if (c1.AAG_Contract_Expiring_in_90_Days__c == True) {
         Opportunity op = new Opportunity();
            
         op.Ownerid = c1.Ownerid;
         op.name = 'SRenewal Opportunity-' + c1.name;
         //op.Accountid = c.id;
         op.Closedate = c1.AAG_Contract_End_Date__c;
         op.StageName = 'New';
         insert op;
            
    }*/
    }
        //Assert attachment list has some data
        //system.assertEquals(conObj.galleryAttachmentList.size(),1);
  }
}