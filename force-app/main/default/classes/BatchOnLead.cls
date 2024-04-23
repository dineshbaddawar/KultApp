global class BatchOnLead implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name From UserRole';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> userList) {
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}