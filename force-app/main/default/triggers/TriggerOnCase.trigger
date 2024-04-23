trigger TriggerOnCase on Case (before insert, before update, after update, after insert) {   
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        caseTriggerHelper.updateUserFieldsOnReassignment(Trigger.new, Trigger.oldMap);   
        
        if(trigger.isUpdate && trigger.isAfter){
            //CaseHelperControllers.sendEmailToUserAndNotificationToUserPincodeNotServiceable(Trigger.new,Trigger.oldMap);
            //CaseHelperControllers.sendEmailToUserAndNotificationToUserDelayInDelivery(Trigger.new,Trigger.oldMap);
            //referBackToCsTeamController.sendEmailToUserAndNotificationToUserReasonForLostInTransit(Trigger.new,Trigger.oldMap);
            //CaseHelperControllers.sendEmailToContactOwnerAndSendNotificationToOMSTeam(Trigger.new,Trigger.oldMap); 
           caseTriggerHelper.resetTypeAndSubtypeOnRecordTypeChange(Trigger.new, Trigger.oldMap);  
            
        }     
    }
    if(trigger.isInsert && trigger.isBefore){
        caseTriggerHelper.modifyEmailCases(trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){
        caseTriggerHelper.createdAffectedSKUs(trigger.new);
    }
}