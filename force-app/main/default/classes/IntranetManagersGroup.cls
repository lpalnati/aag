/*****************************************************************************
* Author        :  LakshmiPalnati(Virgin America)
* Name          :  IntranetManagersGroup
* Date          :  Jan 18,2016
* Description   :  Utility functions for intranet triggers - TO assign manager to Manager Groups
* Modified By   :  Lakshmi Palnati
* Modified Date :  Jan 19th, 2016
* Ref.          :  Recognision Work.com 
******************************************************************************/
public without sharing class IntranetManagersGroup {
    //Assign an User to Manager and Supervisor Public group
    @future
    public static void assignToMgrsGroup(Set<Id> userIds, Id managersGroupId){
        list<GroupMember> allManagersList = new list<GroupMember>();

        //add new user to Manager and Supervisor public group
        for (Id i : userIds) {
            allManagersList.add(new GroupMember(UserOrGroupId = i,GroupId = managersGroupId));
        }

        //insert membership
        if (allManagersList.size() > 0) {
            insert allManagersList;
        }
    }
    
    //Remove an User from Manager and Supervisor Public group
    @future
    public static void removeFromMgrsGroup(Set<Id> userIds, Id managersGroupId){

        List<GroupMember> grpList  = [Select Id from GroupMember where GroupId = :managersGroupId and UserOrGroupId IN :userIds];

        delete grpList;
    }
    
    public static void updateSupervisorsGroup(Set<Id> assignList, Set<Id> removeList) {
        if (assignList.size() > 0 || removeList.size() > 0) {
            //get id of Manager and Supervisor public group
            Id managersGrp = [Select Id From Group where Name = 'Manager and Supervisor'].Id;
            if (managersGrp == null) return;
    
            if (assignList.size() > 0) {
                assignToMgrsGroup(assignList, managersGrp);               
            }
        
            if (removeList.size() > 0) {
                removeFromMgrsGroup(removeList, managersGrp);               
            }
        }
    }
    
    //Tells whether user title is supervisor or supv, returns true
    public static Boolean isUserSupervisor(String title) {
       if (String.isBlank(title)) {
           return false;
       }
       
       if (title.containsIgnoreCase('Supervisor') || title.containsIgnoreCase('Supv')) {
           return true;
       }
       
       return false;
    }

    // Findout whether this manager need to be in the All Managers group or not 
    public static Boolean isSupvToBeInTheGroup(User mgr) {
        if (mgr.IsActive == false) {
            return false;
        }

        if (mgr.No_of_reporting_to__c > 0 || isUserSupervisor(mgr.Title)) {
            return true;
        }

        // No reportees and not a Supervisor/supv, so return false
        return false;
    }
    
    public static Integer getUserCount(List<User> userList, Id mgrId) {
        Integer count = 0;
        for (User u : userList) {
            if (u.ManagerId == mgrId) {
                count++;
            }
        }
       
        return count;
    }
  
    public static void updateMgrOrSupvInfo(Set<Id> mgrIds, Set<Id> addMgrGrpList, Set<Id> remMgrGrpList) {
        if (mgrIds.size() > 0) {
            // Get all Active users reporting to the these managers
            List<User> userList = [SELECT Id, ManagerId FROM User WHERE User.IsActive=TRUE AND User.ManagerId IN :mgrIds];
    
            // Get all manager records (old + new managers)
            List<User> mgrList = [SELECT Id, Title, IsActive, No_of_reporting_to__c FROM User WHERE User.Id IN :mgrIds];
        
            // Correctly update all reportings of each manager
            for (User m : mgrList) {
                m.No_of_reporting_to__c = getUserCount(userList, m.Id);
                
                // Also, add/remove in the Managers/Supervisors group list
                if (isSupvToBeInTheGroup(m)) {
                    addMgrGrpList.add(m.Id);
                } else {
                    remMgrGrpList.add(m.Id);
                }
            }
    
            // Update in the DB
            if (mgrList.size() > 0) {
                update mgrList;
            }
        }

        // At the end update the managers/supervisors group
        updateSupervisorsGroup(addMgrGrpList, remMgrGrpList);
    }
}