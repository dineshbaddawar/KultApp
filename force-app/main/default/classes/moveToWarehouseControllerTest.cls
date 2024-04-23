@istest(seeAllData = true)
public class moveToWarehouseControllerTest {
	@isTest
    static void testClass(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='WareHouse Team']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='staWareHouseTeam@testorg.com');
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
        
        
        
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Tesrtt';
        objProduct.Description = 'Tesrt';
        Insert objProduct;
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        // First insert a price for the standard price book
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
        
        Order ord = new order();
        ord.AccountId = acc.Id;
        ord.EffectiveDate = system.today();
        ord.Status = 'Draft';
        ord.Pricebook2Id = pb.id;
        ord.UTR_Number__c = '123456';
        Insert ord;
        
        OrderItem ordItm = new OrderItem();
        ordItm.OrderId = ord.Id;
        ordItm.UnitPrice = 200;
        ordItm.PricebookEntryId = pbe.Id;
        ordItm.Quantity = 1;
        Insert ordItm;
        
        
        Case cse = new Case();
        cse.Origin = 'Bulk Upload';
        cse.Status = 'New';
        cse.AccountId = acc.Id;
        cse.ContactId = con.Id;
        cse.OrderId__c = ord.Id;
        cse.Inital_Commented_Date__c = system.today();
        cse.subject = 'Testing';
        
        
        Insert cse;
        
        
        moveToWarehouseController.getCaseDetailsAndPicklistValues(cse.Id);
        moveToWarehouseController.moveToWHteams(cse);
        moveToWarehouseController.sendingCustomNotification(userInstant.Id, cse.Id,'Testing For Notification Title', 'Testing For Notification Body');
        
    }
}