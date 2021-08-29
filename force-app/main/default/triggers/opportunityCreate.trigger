trigger opportunityCreate on Contract (before update) {
   // List<Opportunity> opList = new List<Opportunity>();

    Opportunity op = new Opportunity();
    
    for (Contract c : Trigger.new) {
        if (c != NULL && c.AAG_Contract_Expiring_in_90_Days__c == True) {
            
            
            op.Ownerid = c.Ownerid;
            op.name = 'Renewal Opportunity-' + c.name;
            op.Accountid = c.Accountid;
            op.Closedate = system.today()+90;
            op.StageName = 'New';
            insert op;
            // Also update the Expiry to False
            c.AAG_Contract_Expiring_in_90_Days__c = False;
            
           
            
        }
        
        
    }

    
}