@isTest
public class RefundControllerTest {
    @isTest
    static void testClass(){
        
        Profile pro = [SELECT Id FROM Profile WHERE Name='Customer Service Manager']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='sCustomerServExecutivea@testorg.com');
        insert userInstant;
        
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
        
        Order ord = new order();
        ord.AccountId = acc.Id;
        ord.EffectiveDate = system.today();
        ord.Status = 'Draft';
        Insert ord;
        
        Case cse = new Case();
        cse.Origin = 'Bulk Upload';
        cse.Status = 'New';
        cse.AccountId = acc.Id;
        cse.ContactId = con.Id;
        cse.OrderId__c = ord.Id;
        cse.RecordTypeId = '012F30000020IquIAE';
        cse.Subject = 'test classes';
        cse.OwnerId = userInstant.Id;
        Insert cse;
        
        
        
        
        RefundController.getCaseById(cse.Id);
        RefundController.getUsersByProfileName();
        RefundController.userUpdate(cse.Id,userInstant.Id);
        
    }
    
    
}