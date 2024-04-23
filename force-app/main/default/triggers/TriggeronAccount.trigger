trigger TriggeronAccount on Account (after insert) {
    if(trigger.isAfter && trigger.isInsert){
    referBackToCsTeamController.AccountCreatedConCreated(Trigger.New);
    }
}