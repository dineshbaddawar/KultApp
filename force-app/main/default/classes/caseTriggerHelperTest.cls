@isTest(seeAllData = true)
public class caseTriggerHelperTest {
    @isTest
    static void testClass(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='WareHouse Team']; 
        
      
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
        
        Order ord = new order();
        ord.AccountId = acc.Id;
        ord.EffectiveDate = system.today();
        ord.Status = 'Draft';
        ord.Pricebook2Id = pb.id;
        ord.UTR_Number__c = '123456';
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
        
        Insert cse;
        
        
        
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id; 
        
        insert newTask;
        
    }
    @isTest
    static void testClass2(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Refund Team']; 
        
          Map<Id,user> usermap = new         Map<Id,user>();
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='stan12345654dardVarsha@testorg.com');
        insert userInstant;
        usermap.put(userInstant.id,userInstant);
        
        User userInstant1 = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                     IsActive=true,Division='Rainmakers',
                                     LocaleSidKey='en_US', ProfileId = pro.Id,
                                     TimeZoneSidKey='America/Los_Angeles', UserName='standardV098765432wertarsha@testorg.com');
        insert userInstant1;
        
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
        
        List<OrderItem> orItmList = new List<OrderItem>();        
        OrderItem ordItm = new OrderItem();
        ordItm.OrderId = ord.Id;
        ordItm.UnitPrice = 200;
        ordItm.PricebookEntryId = pbe.Id;
        ordItm.Quantity = 1;
        ordItm.SKU__c = 'qwer';
        orItmList.add(ordItm);
        Insert orItmList;
        
        
        Map<Id,case> oldcase = new Map<Id,case>();
        Case cse = new Case();
        cse.Origin = 'Bulk Upload';
        cse.Status = 'New';
        cse.OrderId__c = ord.Id;
        cse.ContactId = con.Id;
        cse.Inital_Commented_Date__c = system.today();
        cse.subject = 'Testing';
        cse.Refund_Type__c = 'Full';
        cse.Refund_Reasons__c = 'Customer Changed Mind';   
        cse.Refund_Reason__c = 'Testing'; 
        cse.Marketing_Team__c = userInstant.Id;
        cse.SKU_Details__c = 'testingqwerty';
        cse.OwnerId = userInstant.Id;
        cse.Remarks_mentioned__c = 'testing';
        cse.Refer_Back_Reason__c = 'Refund Processed';
        cse.Approval_Remarks__c = 'asdfghfds';
        cse.Rejection_Reason__c = 'qwertyui';
        cse.Describe_Information_Needed__c = 'qwertyui';
        Insert cse;
        cse.OwnerId = userInstant1.Id;
        update cse;
        oldcase.put(cse.Id,cse);
        
        
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id; 
        
        insert newTask;
        caseTriggerHelper.resetTypeAndSubtypeOnRecordTypeChange(new List<Case>{cse}, oldcase);
        caseTriggerHelper.updateUserFieldsOnReassignment(new List<Case>{cse}, oldcase);
        caseTriggerHelper.SendEmailTemplateWithTemplate(new List<Case>{cse},usermap);
        caseTriggerHelper.sendingCustomNotification(userInstant.Id,cse.Id,'testing qwerty','teting qwerty body');
    }
      @isTest
    static void testClass3(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Refund Team']; 
        
          Map<Id,user> usermap = new         Map<Id,user>();
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='stan12345654dardVarsha@testorg.com');
        insert userInstant;
        usermap.put(userInstant.id,userInstant);
        
        User userInstant1 = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                     IsActive=true,Division='Rainmakers',
                                     LocaleSidKey='en_US', ProfileId = pro.Id,
                                     TimeZoneSidKey='America/Los_Angeles', UserName='standardV098765432wertarsha@testorg.com');
        insert userInstant1;
        
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
        
        List<OrderItem> orItmList = new List<OrderItem>();        
        OrderItem ordItm = new OrderItem();
        ordItm.OrderId = ord.Id;
        ordItm.UnitPrice = 200;
        ordItm.PricebookEntryId = pbe.Id;
        ordItm.Quantity = 1;
        ordItm.SKU__c = 'qwer';
        orItmList.add(ordItm);
        Insert orItmList;
        
        
        Map<Id,case> oldcase = new Map<Id,case>();
        Case cse = new Case();
        cse.Origin = 'Bulk Upload';
        cse.Status = 'New';
        cse.OrderId__c = ord.Id;
        cse.ContactId = con.Id;
        cse.Inital_Commented_Date__c = system.today();
        cse.subject = 'Testing';
        cse.Refund_Type__c = 'Full';
        cse.Refund_Reasons__c = 'Customer Changed Mind';   
        cse.Refund_Reason__c = 'Testing'; 
        cse.SKU_Details__c = 'testingqwerty';
        cse.OwnerId = userInstant.Id;
        cse.Remarks_mentioned__c = 'testing';
        cse.Refer_Back_Reason__c = 'Refund Processed';
        cse.Approval_Remarks__c = 'asdfghfds';
        cse.Rejection_Reason__c = 'qwertyui';
        cse.Describe_Information_Needed__c = 'qwertyui';
        Insert cse;
        cse.OwnerId = userInstant1.Id;
        update cse;
        oldcase.put(cse.Id,cse);
        
        
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id; 
        
        insert newTask;
        caseTriggerHelper.resetTypeAndSubtypeOnRecordTypeChange(new List<Case>{cse}, oldcase);
        caseTriggerHelper.updateUserFieldsOnReassignment(new List<Case>{cse}, oldcase);
        caseTriggerHelper.SendEmailTemplateWithTemplate(new List<Case>{cse},usermap);
        caseTriggerHelper.sendingCustomNotification(userInstant.Id,cse.Id,'testing qwerty','teting qwerty body');
    }
}