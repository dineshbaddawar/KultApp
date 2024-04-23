public class OOSHelper {
    @AuraEnabled
    public static oosWrapper getCaseAndOrderDetails(String caseId){
        try{
            if(String.isNotBlank(caseId)){
                oosWrapper oosWr = new oosWrapper();
                Case caseRec = [SELECT Id, Sub_Type__c, Sub_Sub_Type__c, CaseNumber, OrderId__r.OrderNumber,OrderId__r.Status, OrderId__c, Order_Date__c, Status, ContactId, Contact.Email FROM Case WHERE Id =: caseId LIMIT 1];
                oosWr.caseRec = caseRec;
                if(caseRec.OrderId__c != null){
                    List<OrderItem> oliList = [SELECT Id, Product2.Name, Quantity, TotalPrice, OrderID, OriginalOrderItemId, Is_Duplicate_Order__c, PricebookEntryId,
                                               Product2Id, ListPrice, UnitPrice, Refund_Quantity__c FROM OrderItem WHERE OrderID =: caseRec.OrderId__c];
                    if(oliList.size()>0){
                        oosWr.oliList = oliList;
                    }
                }
                return oosWr;
            }
            return null;
        }catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static void createDupOrder(List<OrderItem> oliList, String caseId, Case caseRec){
        try{
            update caseRec;
            System.debug('caseRec==> ' + caseRec);
            String orderId = oliList[0].OrderID;
            Order orderRec = [SELECT Id, OwnerId, ContractId, AccountId, Pricebook2Id, OriginalOrderId, OpportunityId, QuoteId, EffectiveDate, EndDate, IsReductionOrder, Status, Description,
                              CustomerAuthorizedById, CustomerAuthorizedDate, CompanyAuthorizedById, CompanyAuthorizedDate, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                              BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, 
                              ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Name, PoDate, PoNumber, OrderReferenceNumber, BillToContactId, 
                              ShipToContactId, ActivatedDate, ActivatedById, StatusCode, OrderNumber, TotalAmount, Refund_Amount__c, Case__c, Refund_Type__c, Refund_Reason__c, Coupon__c, 
                              Mobile_No__c, UTR_Number__c FROM Order WHERE Id =: orderId LIMIT 1];
            Order orderRecNew = new Order();
            orderRecNew = orderRec;
            orderRecNew.Id = null;
            orderRecNew.Case__c = caseId;
            orderRecNew.Is_Duplicate_Order__c = true;
            orderRecNew.ParentOrder__c = orderId;
            insert orderRecNew;
            System.debug('orderRecNew==> ' + orderRecNew);
            for(OrderItem oliRec : oliList){
                oliRec.OrderId = orderRecNew.Id;
            }
            insert oliList;
            System.debug('oliList==> ' + oliList);
            // EmailTemplate et = [SELECT Id, Name, DeveloperName, NamespacePrefix, OwnerId, FolderId, FolderName, BrandTemplateId, EnhancedLetterheadId, TemplateStyle, IsActive, 
            //                     TemplateType, Encoding, Description, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Duplicate_Order_Creation_OOS'];
            // Messaging.SingleEmailMessage message = new        Messaging.SingleEmailMessage();
            // message.setTargetObjectId(caseRec.Id); 
            // message.setSenderDisplayName('Kult Kare Support'); 
            // message.setReplyTo('no-reply@company.com');
            // message.setUseSignature(false); 
            // message.setBccSender(false); 
            // message.setSaveAsActivity(true); 
            // message.setTemplateID(et.Id); 
            // message.setWhatId(CaseRec.ContactId);
            // message.toAddresses = new String[] { CaseRec.contact.email};
            //     Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            //         Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            // if (results[0].success) 
            // {
            //     System.debug('The email was sent successfully.');
            // } else {
            //     System.debug('The email failed to send: ' +  results[0].errors[0].message);
            // }
        }catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
        }
    }
    
    public class oosWrapper{
        @AuraEnabled
        public case caseRec;
        @AuraEnabled
        public List<OrderItem> oliList;
    }
}