@isTest(seeAllData = true)
public class CaseHelperControllersTest {
    @isTest
    static void testClass(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Marketing Team']; 
        
        Map<Id,User> userMap = new Map<Id,User>();
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        userMap.put(userInstant.Id,userInstant);
        
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
        
        Map<Id,Case> oldMapOfCase = new Map<Id,Case>();
        
        Case cse = new Case();
        cse.Status = 'New';
        
        cse.OrderId__c = ord.Id;
        cse.ContactId = con.Id;
        cse.subject = 'Testing';
        cse.Sub_Type__c = 'Order Related';
        cse.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse.Re_Opening_Reason__c = 'qwertyuioi';
        cse.Contact_Number__c = '1245678765';
        cse.OutBound_PinCode_not_Serviceable__c = false;
        cse.InBound_PinCode_not_Serviceable__c = false;
        cse.OutBound_Dealy_In_Delivery__c = false;
        cse.Inbound_Dealy_In_Delivery__c = false;
        cse.Reason_for_RTO__c = 'Code verified cancellation';
        cse.Category__c = 'Query';
        cse.RTO_Reso__c = 'Initiate Refund';
        Insert cse;
        cse.OutBound_PinCode_not_Serviceable__c = true;
        cse.InBound_PinCode_not_Serviceable__c = true;
        cse.OutBound_Dealy_In_Delivery__c = true;
        cse.Inbound_Dealy_In_Delivery__c =  true;
        cse.Reason_for_RTO__c = 'WhatsApp verified cancellation';
        update cse;
        oldMapOfCase.put(cse.Id,cse);
        
        
        List<Case> cseList = new List<Case>();
        Case cse1 = new Case();
        
        cse1.Status = 'New';
        cse1.AccountId = acc.Id;
        cse1.OrderId__c = ord.Id;
        cse1.ContactId = con.Id;
        cse1.subject = 'Testing';
        cse1.Sub_Type__c = 'Order Related';
        cse1.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse1.Re_Opening_Reason__c = 'qwertyuioi';
        cse1.Contact_Number__c = '1245678765';
        Insert cse1;
        cseList.add(cse1);
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id; 
        
        insert newTask;
        
        
        CaseHelperControllers.dependentFields();
        CaseHelperControllers.reOpenCase(cse.Id,cse.Re_Opening_Reason__c);
        CaseHelperControllers.fetchDependentPicklist();
        CaseHelperControllers.getRelatedCases(cse.Id);
        CaseHelperControllers.mergeSelectedCases(cse.Id,cseList);
        // CaseHelperControllers.sendEmailToUserAndNotificationToUserPincodeNotServiceable(new List<Case>{cse},oldMapOfCase);
        // CaseHelperControllers.sendEmailToUserAndNotificationToUserDelayInDelivery(new List<Case>{cse},oldMapOfCase);
        //CaseHelperControllers.sendEmailToContactOwnerAndSendNotificationToOMSTeam(new List<Case>{cse},oldMapOfCase);
        CaseHelperControllers.courierRelatedCase(cse.Id);
        CaseHelperControllers.updateCaseAndOrder(cse.Id);
        CaseHelperControllers.sendNotificationToOrderManagementTeam(cse.Id);
        CaseHelperControllers.getProfileBasedUserList();
        CaseHelperControllers.showAllCaseData(cse.Id);
        CaseHelperControllers.UpdateCaseRecord(cse.Id,cse.OrderId__c);
        CaseHelperControllers.getAllRelatedOrderItems(cse.OrderId__c);
        CaseHelperControllers.getOrderItems(cse.OrderId__c); 
        CaseHelperControllers.getCaseFieldSetListForCourierIssue();
        CaseHelperControllers.createChildCase('Tech',cse.Sub_Type__c,cse.Sub_Sub_Type__c,acc.Id,con.id,newTask.Subject,cse.Contact_Number__c,cse.Id,userInstant.Id);
        CaseHelperControllers.createCaseUnderAccount(cse.Id,'Tech',cse.Sub_Type__c,cse.Sub_Sub_Type__c,newTask.Subject,cse.Describe_Information_Needed__c,cse.OrderId__c,cse.Category__c);
        
        
    }
    
    
    @isTest
    static void testClass1(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Marketing Team']; 
        
        Map<Id,User> userMap = new Map<Id,User>();
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        userMap.put(userInstant.Id,userInstant);
        
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
        
        Map<Id,Case> oldMapOfCase = new Map<Id,Case>();
        
        Case cse = new Case();
        cse.Status = 'New';
        
        cse.OrderId__c = ord.Id;
        cse.ContactId = con.Id;
        cse.subject = 'Testing';
        cse.Sub_Type__c = 'Order Related';
        cse.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse.Re_Opening_Reason__c = 'qwertyuioi';
        cse.Contact_Number__c = '1245678765';
        cse.OutBound_PinCode_not_Serviceable__c = false;
        cse.InBound_PinCode_not_Serviceable__c = false;
        cse.OutBound_Dealy_In_Delivery__c = false;
        cse.Inbound_Dealy_In_Delivery__c = false;
        cse.Reason_for_RTO__c = 'Code verified cancellation';
        cse.Category__c = 'Query';
        cse.RTO_Reso__c = 'Initiate Refund';
        Insert cse;
        cse.OutBound_PinCode_not_Serviceable__c = true;
        cse.InBound_PinCode_not_Serviceable__c = true;
        cse.OutBound_Dealy_In_Delivery__c = true;
        cse.Inbound_Dealy_In_Delivery__c =  true;
        cse.Reason_for_RTO__c = 'WhatsApp verified cancellation';
        update cse;
        oldMapOfCase.put(cse.Id,cse);
        
        
        List<Case> cseList = new List<Case>();
        Case cse1 = new Case();
        
        cse1.Status = 'New';
        cse1.AccountId = acc.Id;
        cse1.OrderId__c = ord.Id;
        cse1.ContactId = con.Id;
        cse1.subject = 'Testing';
        cse1.Sub_Type__c = 'Order Related';
        cse1.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse1.Re_Opening_Reason__c = 'qwertyuioi';
        cse1.Contact_Number__c = '1245678765';
        Insert cse1;
        cseList.add(cse1);
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id; 
        
        insert newTask;
        
        CaseHelperControllers.getAllProfileNames();
        CaseHelperControllers.manualCaseShare(cse.Id,userInstant.Id);
        CaseHelperControllers.getCaseRec(cse.Id);
        CaseHelperControllers.getCaseRecordTypes();
        CaseHelperControllers.getCaseFieldSetListss();
        CaseHelperControllers.getCaseFieldSetList();
        CaseHelperControllers.getAllCaseFields();
        CaseHelperControllers.getRecrdTypeId(cse.Id);
        CaseHelperControllers.getRecrdTypeIdChat();
        CaseHelperControllers.caseRecord(cse.Id);
        CaseHelperControllers.getCaseRecord(cse.Id);
        CaseHelperControllers.getCaseRecords();
        CaseHelperControllers.getAllRT();
        CaseHelperControllers.createCaseInLiveChatTranscript('Tech',cse.Sub_Type__c,cse.Sub_Sub_Type__c,cse.AccountId,cse.ContactId,newTask.Subject,cse.Contact_Number__c,cse.Id,userInstant.Id); 
        CaseHelperControllers.returnToOrigin(cse.Id,cse.Reason_for_RTO__c,cse.RTO_Reso__c);
    }
}