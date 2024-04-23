@isTest
public class kultBotApexTest {
    @isTest
    static void testIsInWorkHours() {
        
        Task t = new Task(Subject='Donni',Status='New',Priority='Normal',CallType='Outbound');
        Insert t;
        
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.Phone = '098765432123456';
        Insert acc;
        
        Contact con = new Contact();
        con.accountId = acc.Id;
        con.Email = 'new@contact.com';
        con.FirstName = 'Test';
        con.LastName = 'contact';
        Insert Con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'qwrtu';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Qualification';
        Insert Opp;
        
         Opportunity opp1 = new Opportunity();
        opp1.Name = 'qwrtu';
        opp1.AccountId = acc.Id;
        opp1.CloseDate = system.today();
        opp1.StageName = 'Proposal';
        Insert Opp1;
        
        kultBotApex.isInWorkHours();
        
    }
}