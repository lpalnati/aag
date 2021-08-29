/*********************************************************************************************************************
Created By     :   Virendra(Appirio)
Date           :    29 Nov 2012
Reason         :    This is Scheduler class to run the IntranetPublishOnEffectiveDateBatchable 
                    To Share  the contents from VX Master to other libraries
*********************************************************************************************************************/
global class UnshareOnEffectiveDateSchedulable implements Schedulable
{
   global void execute(SchedulableContext sc){
      IntranetUnShareOnEffectiveDateBatchable b = new IntranetUnShareOnEffectiveDateBatchable(); 
      database.executebatch(b);
   }
}