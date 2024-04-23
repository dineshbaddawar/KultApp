trigger TriggerOnTask on Task (before insert, after insert) {
    if(trigger.isAfter && trigger.isInsert){
        taskTriggerHelper.createCaseOnCall(trigger.new);
    }
}