@istest(seeAllData = true)
public class CallLogTriggerHelperTest {
    @istest
    public static void collectEmailOrPhoneOfCallLogs(){
        
       /* Account acc = new Account();
        acc.Name = 'Testing';
        acc.Phone = '098765432123456';
        Insert acc;
        
        Contact con = new Contact();
        con.accountId = acc.Id;
        con.Email = 'new@contact.com';
        con.FirstName = 'Test';
        con.LastName = 'contact';
        Insert Con;
        
        
        Case cse = new Case();
        cse.Origin = 'Bulk Upload';
        cse.Status = 'New';
        cse.AccountId = acc.Id;
        cse.ContactId = con.Id;
        Insert cse;
 
        Call_Logs_Custom__c clg = new Call_Logs_Custom__c();
        clg.Phone__c = '9025244424';
        clg.Email__c = 'anwar@anwar.com';
        Insert clg;
        clg.Contact__c = con.Id;
        clg.Case__c = cse.Id;
        update clg; */
        
        List<Call_Logs_Custom__c> clgList = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, 
                                             LastModifiedDate, LastModifiedById, 
                                             SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Case__c, 
                                             Contact__c, Phone__c, Email__c, Status__c FROM Call_Logs_Custom__c Limit 1];
        
       CallLogTriggerHelper.collectEmailOrPhoneOfCallLogs(clgList);  
    }
}