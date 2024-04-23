public class viewOrderDetailsOnChatController {
	@AuraEnabled
    public static orderDetailsWrapper getTranscriptAndOrderDetails(String recId){
        try{
            orderDetailsWrapper odwWrap = new orderDetailsWrapper();
            List<LiveChatTranscript> chatTranscriptList = [SELECT Id, OwnerId, IsDeleted, Name,LiveChatVisitorId, Body, ContactId, LeadId, CaseId, Case.OrderId__c, AccountId, 
                                                       LiveChatDeploymentId, LiveChatButtonId, SkillId, IpAddress, Location, UserAgent, Browser, Platform, 
                                                       BrowserLanguage, ScreenResolution, ReferrerUri, Status, RequestTime, StartTime, EndTime, EndedBy, AverageResponseTimeVisitor, 
                                                       AverageResponseTimeOperator, OperatorMessageCount, VisitorMessageCount, MaxResponseTimeOperator, ChatKey, 
                                                       SupervisorTranscriptBody, MaxResponseTimeVisitor, VisitorNetwork, ChatDuration, WaitTime, Abandoned, IsChatbotSession, 
                                                       Order_Number__c FROM LiveChatTranscript WHERE Id=: recId];
            
            LiveChatTranscript chatTranscriptRec = new LiveChatTranscript();
            
            Order orderRec = new Order();
            
            if(!chatTranscriptList.isEmpty()){
                chatTranscriptRec = chatTranscriptList[0];
                if(chatTranscriptRec.Case.OrderId__c != null){
                    String orderId = chatTranscriptRec.Case.OrderId__c;
                    orderRec = [SELECT Id, OwnerId, ContractId, AccountId, Pricebook2Id, OriginalOrderId, OpportunityId, QuoteId, EffectiveDate, EndDate, IsReductionOrder, 
                                Status, Description, CustomerAuthorizedById, CustomerAuthorizedDate, CompanyAuthorizedById, CompanyAuthorizedDate, 
                                Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, 
                                BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, 
                                ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Name, PoDate, PoNumber, OrderReferenceNumber, 
                                BillToContactId, ShipToContactId, ActivatedDate, ActivatedById, StatusCode, OrderNumber, TotalAmount, 
                                Refund_Amount__c, Case__c, Refund_Type__c, Refund_Reason__c, Coupon__c, Mobile_No__c, UTR_Number__c, Is_Duplicate_Order__c, 
                                Payment_Id__c, Payment_Status__c, Payment_Type__c, Coupon_Code__c, Coupon_Discount__c, Account.Name,
                                Amount_from_OMS__c, Delivery_Mobile_Number__c, ParentOrder__c, Total_Amount__c, Paid_Amount__c,
                                (SELECT Id, Product2Id, IsDeleted, OrderId, PricebookEntryId, OriginalOrderItemId, AvailableQuantity, Quantity, UnitPrice, ListPrice, 
                                 TotalPrice, ServiceDate, EndDate, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                                 OrderItemNumber, Refund_Quantity__c, Is_Duplicate_Order__c, Refund_Reason__c, Refund_Type__c, Refund_Price__c, Brand__c, Selling_Price__c, 
                                 Refunded_Price__c, SKU__c, Status__c, Product_Name__c, Product2.Name FROM OrderItems) FROM Order WHERE Id=: orderId LIMIT 1];
                    odwWrap.orderRec = orderRec;
                    odwWrap.orderLineItems = orderRec.OrderItems;
                    return odwWrap;
                }
                else if(chatTranscriptRec.Order_Number__c != null){
                    String orderNo = chatTranscriptRec.Order_Number__c;
                    orderRec = [SELECT Id, OwnerId, ContractId, AccountId, Pricebook2Id, OriginalOrderId, OpportunityId, QuoteId, EffectiveDate, EndDate, IsReductionOrder, 
                                Status, Description, CustomerAuthorizedById, CustomerAuthorizedDate, CompanyAuthorizedById, CompanyAuthorizedDate, 
                                Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, 
                                BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, 
                                ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Name, PoDate, PoNumber, OrderReferenceNumber, 
                                BillToContactId, ShipToContactId, ActivatedDate, ActivatedById, StatusCode, OrderNumber, TotalAmount, 
                                Refund_Amount__c, Case__c, Refund_Type__c, Refund_Reason__c, Coupon__c, Mobile_No__c, UTR_Number__c, Is_Duplicate_Order__c, 
                                Payment_Id__c, Payment_Status__c, Payment_Type__c, Coupon_Code__c, Coupon_Discount__c, Account.Name,
                                Amount_from_OMS__c, Delivery_Mobile_Number__c, ParentOrder__c, Total_Amount__c, Paid_Amount__c,
                                (SELECT Id, Product2Id, IsDeleted, OrderId, PricebookEntryId, OriginalOrderItemId, AvailableQuantity, Quantity, UnitPrice, ListPrice, 
                                 TotalPrice, ServiceDate, EndDate, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                                 OrderItemNumber, Refund_Quantity__c, Is_Duplicate_Order__c, Refund_Reason__c, Refund_Type__c, Refund_Price__c, Brand__c, Selling_Price__c, 
                                 Refunded_Price__c, SKU__c, Status__c, Product_Name__c, Product2.Name FROM OrderItems) FROM Order WHERE OrderNumber=: orderNo OR Name =: orderNo LIMIT 1];
                    odwWrap.orderRec = orderRec;
                    odwWrap.orderLineItems = orderRec.OrderItems;
                    return odwWrap;
                }
            }
            return null;
        }catch(exception e){
            System.debug('Error Message ==> ' + e.getMessage() + ' at Line Number ==> ' + e.getLineNumber());
            return null;
        }
    }
    
    public class orderDetailsWrapper{
        @AuraEnabled
        public LiveChatTranscript chatTranscriptRec;
        @AuraEnabled
        public Order orderRec;
        @AuraEnabled
        public List<OrderItem> orderLineItems;
        
    }
}