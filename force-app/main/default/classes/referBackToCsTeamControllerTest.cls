@isTest(seeAllData = true)
public class referBackToCsTeamControllerTest {
    @istest 
    static void testClass(){
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='WareHouse Team']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
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
        
        
        Map<Id,Case> mapOfCase = new Map<Id,Case>();
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
        cse.Reason_For_Dealy__c = 'Customer Unreachable';
        Insert cse;
        cse.Reason_For_Dealy__c = 'Lost in Transit';
        update cse;
        mapOfCase.put(cse.Id,cse);
        
        Map<Id,Case> mapOfCase1 = new Map<Id,Case>();
        Case cse1 = new Case();
        cse1.Origin = 'Bulk Upload';
        cse1.Status = 'New';
        cse1.AccountId = acc.Id;
        cse1.OrderId__c = ord.Id;
        cse1.ContactId = con.Id;
        cse1.Inital_Commented_Date__c = system.today();
        cse1.subject = 'Testing';
        cse1.Refund_Type__c = 'Full';
        cse1.Refund_Reasons__c = 'Customer Changed Mind';   
        cse1.Refund_Reason__c = 'Testing';
        cse1.Sub_Type__c = 'Order Related';
        cse1.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse1.Reason_For_Dealy__c = 'Lost in Transit';
        Insert cse1;
        cse1.Reason_For_Dealy__c = 'Incorrect Addresses';
        update cse1;
        mapOfCase1.put(cse1.Id,cse1);
        
        Map<Id,Case> mapOfCase2 = new Map<Id,Case>();
        Case cse2 = new Case();
        cse2.Origin = 'Bulk Upload';
        cse2.Status = 'New';
        cse2.AccountId = acc.Id;
        cse2.OrderId__c = ord.Id;
        cse2.ContactId = con.Id;
        cse2.Inital_Commented_Date__c = system.today();
        cse2.subject = 'Testing';
        cse2.Refund_Type__c = 'Full';
        cse2.Refund_Reasons__c = 'Customer Changed Mind';   
        cse2.Refund_Reason__c = 'Testing';
        cse2.Sub_Type__c = 'Order Related';
        cse2.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse2.Reason_For_Dealy__c = 'Lost in Transit';
        cse2.Refer_Back_Reason__c = 'Refund Processed';
        cse2.Approval_Remarks__c = 'qwetyu';
        cse2.Rejection_Reason__c = 'qwtuirdx';
        cse2.Describe_Information_Needed__c = 'qwertyu';
        Insert cse2;
        cse2.Reason_For_Dealy__c = 'Customer Unreachable';
        update cse2;
        mapOfCase2.put(cse2.Id,cse2);
        
        
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id; 
        
        insert newTask;
        
        
        referBackToCsTeamController.getCaseById(cse.Id);
        referBackToCsTeamController.getCaseAndOrderDetails(cse.Id,cse2.Refer_Back_Reason__c,cse2.Approval_Remarks__c,cse2.Rejection_Reason__c,cse2.Describe_Information_Needed__c,200);
        referBackToCsTeamController.deletecaseShares(cse.Id);
        referBackToCsTeamController.sendingCustomNotification(userInstant.Id,cse.Id,'Test Class Title','Test Class Body',new List<String>{'anwarchikle2000@gmail.com'});
        
        
        
    } 
}