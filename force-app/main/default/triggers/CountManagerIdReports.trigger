trigger CountManagerIdReports on User (after insert, after update) {    
    Id oldMgrId, newMgrId;
    Set<Id> supvGrpAssignList = new Set<Id>();
    Set<Id> supvGrpRemoveList = new Set<Id>();

    Set<Id> mgrIds = new Set<Id>();

    // Loop through each record Id
    for (User u : Trigger.new) {
        // Check if there is a manager change
        newMgrId = Trigger.newMap.get(u.Id).ManagerId;
        if (newMgrId != null) {
            mgrIds.add(newMgrId);
        }

        if (Trigger.isUpdate) {
            oldMgrId = Trigger.oldMap.get(u.Id).ManagerId;
            if (oldMgrId != null && oldMgrId != newMgrId) {
                mgrIds.add(oldMgrId);
            }
            
            if (IntranetManagersGroup.isUserSupervisor(Trigger.oldMap.get(u.Id).Title) &&
                !IntranetManagersGroup.isUserSupervisor(Trigger.newMap.get(u.Id).Title)) {
                supvGrpRemoveList.add(u.Id);
            }
        }

        // Also, add/remove in the Managers/Supervisors group list
        if (IntranetManagersGroup.isSupvToBeInTheGroup(Trigger.newMap.get(u.Id))) {
            supvGrpAssignList.add(u.Id);
        }
    }
    
    IntranetManagersGroup.updateMgrOrSupvInfo(mgrIds, supvGrpAssignList, supvGrpRemoveList);
}