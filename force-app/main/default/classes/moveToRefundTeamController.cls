public class moveToRefundTeamController {
    
    @AuraEnabled(cacheable=true)
    public static RefundWrapper getOrderLineItem(String caseId) { 
        
        List<Case> caseList = [SELECT Id,Contact_Number__c,RefundTeamMember__c, Sub_Type__c, Sub_Sub_Type__c, OrderId__c, OrderId__r.Name,OrderId__r.Refund_Type__c, OrderId__r.Refund_Reason__c, OrderId__r.Coupon__c,OrderId__r.Refund_Amount__c,OrderId__r.Paid_Amount__c 
                               FROM Case WHERE Id = :caseId];
        System.debug('caseList=====>'+caseList);
        
        if (!caseList.isEmpty()) {
            Case caseRecord = caseList[0];
            System.debug('caseRecord=====>'+caseRecord);
            
            Order orderRecord = caseRecord.OrderId__r;
            
            System.debug('orderRecord=====>'+orderRecord);
            
            List<OrderItem> orderItems = [SELECT Id, Product2.Name,Quantity,Is_Already_Utilized__c, Refund_Quantity__c,TotalPrice,Refund_Price__c,Refund_Reason__c,Refund_Reasons__c,Refund_Type__c,SKU__c, Total_Selling_Price__c, Selling_Price__c  FROM OrderItem WHERE OrderId = :orderRecord.Id];
            System.debug('orderItems=====>'+orderItems);
            return new RefundWrapper(caseRecord, orderRecord, orderItems);
        } else {
            return null;
        }
    } 
    
    @AuraEnabled
    public static String updateOrderAndCaseFields(String caseId, String caseRefund, String refundReason, String coupon,String refundValue,String refundTeamMemberId, integer refundamount,integer paidamount,String type,string subtype,List<OrderItem> orderItemsToUpdate) {
        String result;
        
        system.debug('caseId--->'+caseId);
        System.debug('caseRefund====>'+caseRefund);
        System.debug('refundReason====>'+refundReason);
        System.debug('coupon====>'+coupon);
        System.debug('refundTeamMemberId====>'+refundTeamMemberId);
        System.debug('paidamount=====>'+paidamount);
        System.debug('orderItemsToUpdate=====>'+orderItemsToUpdate);
        //System.debug('contactNumber====>'+contactNumber);
        
        try{
            String CSteamId;
            
            List<Case> caseList = [SELECT Id, OrderId__c, ownerId, AccountId, Status, ContactId, CS_Team_Member__c FROM Case WHERE Id = :caseId LIMIT 1];
            System.debug('caseList=====>'+caseList);
            
            if (!caseList.isEmpty()) {
                Case caseRecord = caseList[0];
                if(caseRecord.CS_Team_Member__c == null && string.valueOf(caseRecord.OwnerId).startsWith('005')){
                    caseRecord.CS_Team_Member__c = caseRecord.OwnerId;
                }
                CSteamId = caseRecord.CS_Team_Member__c;
                caseRecord.OwnerId = refundTeamMemberId;
                //caseRecord.RefundTeamMember__c = refundTeamMemberId;
                //caseRecord.Contact_Number__c = contactNumber;
                caseRecord.Refund_Type__c = caseRefund;
                caseRecord.Refund_Reasons__c = refundValue;
                caseRecord.Refund_Reason__c = refundReason;
                caseRecord.Case_Sub_Status__c = 'Assigned to Refund Team';
                if(caseRecord.Status == 'New'){
                    caseRecord.Status = 'In Progress'; 
                }
                update caseRecord;
                System.debug('caseRecord====>'+caseRecord);
                 System.debug('caseRecord.OrderId__c =======>'+caseRecord.OrderId__c);
                
                if(caseRecord.OrderId__c != null){
                    Order orderRecord = [SELECT Id,Refund_Type__c,Refund_Reason__c, Coupon__c, Refund_Amount__c, Paid_Amount__c FROM Order WHERE Id = :caseRecord.OrderId__c LIMIT 1];
                    orderRecord.Refund_Type__c = caseRefund;
                    orderRecord.Refund_Reason__c = refundReason;
                    orderRecord.Coupon__c = coupon;
                    orderRecord.Refund_Reasons__c = refundValue;
                    orderRecord.Refund_Amount__c = refundamount;
                    orderRecord.Paid_Amount__c = paidamount;
                    system.debug('orderRecord--->'+orderRecord);
                    
                    List<OrderItem> updateAllOrderItems = new List<OrderItem>();
                    List<Affected_SKU__c> affectedSKUsToInsert = new List<Affected_SKU__c>();
                    Decimal totalrefundprice = 0;
                    if (orderItemsToUpdate != null && !orderItemsToUpdate.isEmpty()) {
                        //update orderItemsToUpdate;
                        for(OrderItem ori : orderItemsToUpdate){
                            
                            if(ori.Is_Already_Utilized__c != true){
                                Affected_SKU__c affectedSKUrec = new Affected_SKU__c();
                                affectedSKUrec.Name = ori.SKU__c;
                                affectedSKUrec.Brand_Name__c = ori.Brand__c;
                                affectedSKUrec.MRP__c = ori.UnitPrice;
                                affectedSKUrec.Product_Name__c = ori.Product_Name__c;
                                affectedSKUrec.Case__c = caseRecord.Id;
                                affectedSKUsToInsert.add(affectedSKUrec);
                            }
                            //ori.Refund_Reasons__c = refundValue;
                            ori.Is_Already_Utilized__c = true;
                            updateAllOrderItems.add(ori);
                            if(ori.Refund_Price__c != null){
                                
                                totalrefundprice = totalrefundprice + ori.Refund_Price__c;
                                
                                System.debug('totalrefundprice======>'+totalrefundprice);
                            }
                            
                        }
                        System.debug('affectedSKUsToInsert==> '+ affectedSKUsToInsert);
                        if(!affectedSKUsToInsert.isEmpty()){
                            insert affectedSKUsToInsert;
                        }
                        if(totalrefundprice > 0){
                            orderRecord.Refund_Amount__c = totalrefundprice;
                            
                        }
                        update orderRecord;
                        update updateAllOrderItems;
                    }
                }
                
                
                //creating Task based on the userID(refundTeamMemberId)
                
                Task newTask = new Task();
                newTask.Subject = 'Case has been assigned to Move to Refund Team';
                newTask.Description = 'Please Move To Refund Team case with case ID: ' + caseRecord.Id;
                newTask.WhatId = caseRecord.Id; 
                //newTask.OwnerId = refundTeamMemberId; 
                insert newTask;
                System.debug('newTask====>'+newTask);
                
                // if(caseRecord!= null && caseRecord.AccountId != null){
                //     List<AccountShare> existingAccShareRec = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, 
                //     ContactAccessLevel, RowCause, LastModifiedDate, LastModifiedById, IsDeleted FROM AccountShare WHERE AccountId =: caseRecord.AccountId AND UserOrGroupId =: refundTeamMemberId];
                //     if(!existingAccShareRec.isEmpty()){
                //         delete existingAccShareRec;
                //     }else{
                //         AccountShare newAccShare = new AccountShare();
                //         newAccShare.AccountId = caseRecord.AccountId;
                //         newAccShare.UserOrGroupId = refundTeamMemberId;
                //         newAccShare.AccountAccessLevel = 'Edit';
                //         //newAccShare.ContactAccessLevel = 'Edit';
                //         newAccShare.OpportunityAccessLevel = 'Edit';
                //         newAccShare.CaseAccessLevel = 'Edit';
                //         insert newAccShare;
                //         System.debug('newAccShare======>'+newAccShare);
                //     }
                // }
                
                
                //create a case share record with Edit Access to the Refund team Member
                
                List<CaseShare> existingShares = [SELECT Id FROM CaseShare WHERE CaseId = :caseRecord.Id AND UserOrGroupId = :CSteamId];
                System.debug('existingShares======>'+existingShares);
                
                if(!existingShares.isEmpty()){
                    //delete existingShares;
                    System.debug('existingShares delete records======>'+existingShares);
                }else{
                    CaseShare newCaseShare = new CaseShare();
                    newCaseShare.CaseId =  caseId;    //caseRecord.Id;
                    System.debug('caseId=======>'+caseId);      
                    newCaseShare.UserOrGroupId = CSteamId;
                    System.debug('CSteamId=====>'+CSteamId);
                    newCaseShare.CaseAccessLevel = 'Edit';
                    //newCaseShare.RowCause = Schema.CaseShare.RowCause.Manual;
                    insert newCaseShare;
                    System.debug('newCaseShare======>'+newCaseShare);
                }
                
                
                
                
                //Approval processes to fire
                
                /* Approval.ProcessSubmitRequest req= new Approval.ProcessSubmitRequest();
req.setComments('Submitting record for Approval');
req.setObjectId(caseRecord.id);
req.setNextApproverIds(new Id[] {caseRecord.RefundTeamMember__c});
req.setSubmitterId(caseRecord.ownerId); 
req.setProcessDefinitionNameOrId('When_Case_Is_Moved_to_ReFund_Team_Member');
Approval.ProcessResult approvalresult = Approval.process(req); */
                
                //Custom Notification call from this  (sendingCustomNotification) Method!
                //sendingCustomNotification(refundTeamMemberId, caseId, 'A case has been assigned', 'A case has been assigned to you to process the refund.');
                
                
                
                result = 'success';
            }
            
        }catch(Exception e){
            system.debug('Exception Message--->'+e.getMessage());
            system.debug('Exception Line Number--->'+e.getLineNumber());
            return e.getMessage();
        }
        return result;
        
    }
    
    @AuraEnabled
    public static void sendingCustomNotification(String refundTeamMemberId,String caseId,String notificationTitle, String notificationBody){
        
        System.debug('refundTeamMemberId====>'+refundTeamMemberId);
        System.debug('caseId====>'+caseId);
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName='Refund_Team_Member'];
        
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(notificationTitle);
        notification.setBody(notificationBody);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(caseId);                         
        Set<String> addressee = new Set<String>();
        addressee.add(refundTeamMemberId);                         
        try {
            notification.send(addressee);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
        
    }
    
    public class RefundWrapper {
        
        @AuraEnabled
        public Case caseRecord { get; set; }
        @AuraEnabled
        public Order orderRecord { get; set; }
        @AuraEnabled
        public List<OrderItem> orderItems { get; set; }
        
        public RefundWrapper(Case caseRecord, Order orderRecord, List<OrderItem> orderItems) {
            this.caseRecord = caseRecord;
            this.orderRecord = orderRecord;
            this.orderItems = orderItems;
        }
    }
}