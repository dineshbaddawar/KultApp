public class createCaseInNonWHFromChatbot {
    
    public class nonWorkingHoursInput{
        @InvocableVariable
        public String phoneNumber;
        @InvocableVariable
        public String emailId;
        @InvocableVariable
        public String description;
        @InvocableVariable
        public String OrderNumberInChatTranscript;
        @InvocableVariable
        public String chatKey;
    }
    
    @InvocableMethod(label='Create Case in Non-Working Hours')
    public static void createCase(List<nonWorkingHoursInput> nwhInputs){
        try{
            
            List<Group> nonWorkingHoursGroupList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId, OwnerId, DoesSendEmailToMembers, DoesIncludeBosses, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM Group WHERE DeveloperName = 'non_business_hours' LIMIT 1];
            Group nonWorkingHoursGroup;
            if(!nonWorkingHoursGroupList.isEmpty()){
                nonWorkingHoursGroup=nonWorkingHoursGroupList[0];
            }
            String emailId = nwhInputs[0].emailId;
            String Phone = nwhInputs[0].phoneNumber;
            String description = nwhInputs[0].description;
            String orderNumberInChatTranscript;
            String chatKey = nwhInputs[0].chatKey;
            if(nwhInputs[0].OrderNumberInChatTranscript != null && nwhInputs[0].OrderNumberInChatTranscript != ''){
                orderNumberInChatTranscript = nwhInputs[0].OrderNumberInChatTranscript;
            }
            
            List<LiveChatTranscript> chatTranscriptList = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, 
                                                           LiveChatVisitorId, Body, ContactId, LeadId, CaseId, AccountId, LiveChatDeploymentId, 
                                                           LiveChatButtonId, SkillId, IpAddress, Location, UserAgent, Browser, Platform, BrowserLanguage, 
                                                           ScreenResolution, ReferrerUri, Status, RequestTime, StartTime, EndTime, EndedBy, AverageResponseTimeVisitor, 
                                                           AverageResponseTimeOperator, OperatorMessageCount, VisitorMessageCount, MaxResponseTimeOperator, 
                                                           ChatKey, SupervisorTranscriptBody, MaxResponseTimeVisitor, VisitorNetwork, ChatDuration, WaitTime, 
                                                           Abandoned, IsChatbotSession, Order_Number__c FROM LiveChatTranscript WHERE ChatKey =: chatKey];
            LiveChatTranscript chatTranscriptRec = new LiveChatTranscript();
            
            List<Order> orderList = new List<Order>();
            Order orderRec = new Order();
            
            if(orderNumberInChatTranscript != null){
                orderList = [SELECT Id, OwnerId, ContractId, AccountId, Pricebook2Id, OriginalOrderId, OpportunityId, QuoteId, EffectiveDate, EndDate, IsReductionOrder, 
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
                                 Refunded_Price__c, SKU__c, Status__c, Product_Name__c, Product2.Name FROM OrderItems) FROM Order WHERE OrderNumber=: orderNumberInChatTranscript OR Name =: orderNumberInChatTranscript LIMIT 1];
            }else if(!chatTranscriptList.isEmpty()){
                chatTranscriptRec = chatTranscriptList[0];
                if(chatTranscriptRec.Order_Number__c != null){
                    orderList = [SELECT Id, OwnerId, ContractId, AccountId, Pricebook2Id, OriginalOrderId, OpportunityId, QuoteId, EffectiveDate, EndDate, IsReductionOrder, 
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
                                 Refunded_Price__c, SKU__c, Status__c, Product_Name__c, Product2.Name FROM OrderItems) FROM Order WHERE OrderNumber=: chatTranscriptRec.Order_Number__c OR Name =: chatTranscriptRec.Order_Number__c LIMIT 1];
                }
            }
            
            Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Chatbot Case').getRecordTypeId();
            System.debug('devRecordTypeId==> ' + devRecordTypeId);
            
            Case caseRec = new Case();
            if(!orderList.isEmpty()){
                orderRec = orderList[0];
                caseRec.OrderId__c = orderRec.Id;
            }
            caseRec.Origin = 'Web';
            caseRec.Contact_Number__c = Phone;
            caseRec.Email_Id__c = emailId;
            caseRec.Description = description;
            caseRec.RecordTypeId = devRecordTypeId;
            if(nonWorkingHoursGroup != null){
                caseRec.OwnerId = nonWorkingHoursGroup.Id;
            }
            
            List<Account> accRec = [SELECT Id, Name, Email__c, Phone FROM Account WHERE Email__c =: emailId OR Phone =: Phone LIMIT 1];
            if(accRec.Size()>0){
                caseRec.AccountId = accRec[0].Id;
                
                List<Contact> conRec = [SELECT Id, Name, Email, Phone FROM Contact WHERE (Email =: emailId OR Phone =: Phone) AND AccountId =: accRec[0].Id LIMIT 1];
                if(conRec.Size()>0){
                    caseRec.ContactId = conRec[0].Id;
                }
            }
            else{
                Account accRecord = new Account();
                accRecord.Name = '[Unknown]-' + Phone;
                accRecord.Phone = Phone;
                accRecord.Email__c = emailId;
                insert accRecord;
                
                List<Contact> conRecord = [SELECT Id, Name FROM Contact WHERE AccountId =: accRecord.Id AND Email =: accRecord.Email__c LIMIT 1]; 
                
                caseRec.AccountId = accRecord.Id;
                if(conRecord.Size()>0){
                caseRec.ContactId = conRecord[0].Id;
                }
            }
            insert caseRec;
            if(!chatTranscriptList.isEmpty()){
                chatTranscriptRec = chatTranscriptList[0];
                chatTranscriptRec.CaseId = caseRec.Id;
                update chatTranscriptRec;
                System.debug('chatTranscriptRec==> ' + chatTranscriptRec);
            }
            System.debug('caseRec==> ' + caseRec);
        }catch(exception e){
            System.debug('Error Message:: ' + e.getMessage() + ' at line number:: ' + e.getLineNumber());
        }
    }
}