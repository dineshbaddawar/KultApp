@isTest(seeAllData = true)
public class OrderTriggerHelperTest {
    @isTest
    static void testClass(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Marketing Team']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
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
        
         Order ord1 = new order();
        ord1.AccountId = acc.Id;
        ord1.EffectiveDate = system.today();
        ord1.Status = 'Draft';
        ord1.Pricebook2Id = pb.id;
        ord1.UTR_Number__c = '123456';
        Insert ord1;
        
        Order ord = new order();
        ord.AccountId = acc.Id;
        ord.EffectiveDate = system.today();
        ord.Status = 'Draft';
        ord.Pricebook2Id = pb.id;
        ord.UTR_Number__c = '123456';
        ord.ParentOrder__c = ord1.Id;
        Insert ord;
        
        List<OrderItem> orItmList = new List<OrderItem>();        
        OrderItem ordItm = new OrderItem();
        ordItm.OrderId = ord.Id;
        ordItm.UnitPrice = 200;
        ordItm.PricebookEntryId = pbe.Id;
        ordItm.Quantity = 1;
        orItmList.add(ordItm);
        Insert orItmList;
        
        
        
        Case cse = new Case();
        cse.Origin = 'Bulk Upload';
        cse.Status = 'New';
        cse.AccountId = acc.Id;
        cse.OrderId__c = ord.Id;
        cse.ContactId = con.Id;
        cse.Inital_Commented_Date__c = system.today();
        cse.subject = 'Testing';
        cse.Refund_Type__c = 'Full';
        cse.Refund_Reasons__c = 'Customer Changed Mind';   
        cse.Refund_Reason__c = 'Testing';
        cse.Sub_Type__c = 'Order Related';
        cse.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse.Marketing_Team__c = userInstant.Id;
        cse.SKU_Details__c = 'testingqwerty';
        cse.MT_Assignment_Reason__c = 'qwertyuiop';
        
        Insert cse;
        
        
        
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id; 
        
        insert newTask;
     
        OrderTriggerHelper.UpdateOrderLineItemOnOrder(orItmList);
    }
}