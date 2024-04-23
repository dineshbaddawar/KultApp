trigger TriggerOnCallLogs on Call_Logs_Custom__c (After insert) {
    if(trigger.isAfter && trigger.isInsert){
       // CallLogTriggerHelper.collectEmailOrPhoneOfCallLogs(trigger.new);
         CallLogHelper.CallLogGenerate(trigger.new);
    }
}