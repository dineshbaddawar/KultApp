public without sharing class moveToWarehouseController {
    @AuraEnabled
    public static wareHouseWrapper getCaseDetailsAndPicklistValues(String recId){
        try{
            if(recId != null){
                Case caseRec = new Case();
                List<Case> caseList = [SELECT Id, IsDeleted, MasterRecordId, CaseNumber, ContactId, AccountId, EntitlementId, ParentId, 
                                       SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, RecordTypeId, Status, Reason, Origin, 
                                       Language, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, OwnerId, SlaStartDate, SlaExitDate, 
                                       CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ContactPhone, ContactMobile, ContactEmail, 
                                       ContactFax, Comments, LastViewedDate, LastReferencedDate, MilestoneStatus, Sub_Type__c, Sub_Sub_Type__c, Payment_ID__c, 
                                       Amount_Paid__c, Mobile_Number__c, Screen_Shot__c, Email_Id__c, Refer_Back_Reason__c, Refund_Back_Reason__c, Approval_Remarks__c, 
                                       Version__c, Handset_model__c, App_Version__c, Device_Handset__c, Coupon_Code__c, OS_Version__c, Logging_Mobile_number__c, 
                                       Screen_Shot_Of_The_Issue__c, Required_payment_option__c, Error_message__c, Brand__c, Product_Name__c, Price_Shown__c, Actual_Price__c, 
                                       App_Name__c, Brand_Name__c, Price_Differnece__c, Campaign_Name__c, Discount__c, Previous_order_number__c, User_Id__c, Contact_Number__c, 
                                       Instagram_ID__c, Brand_Details__c, Address_With_Pin_Code__Street__s, Address_With_Pin_Code__City__s, Address_With_Pin_Code__PostalCode__s, 
                                       Address_With_Pin_Code__StateCode__s, Address_With_Pin_Code__CountryCode__s, Address_With_Pin_Code__Latitude__s, 
                                       Address_With_Pin_Code__Longitude__s, Address_With_Pin_Code__GeocodeAccuracy__s, Address_With_Pin_Code__c, Landmark__c,
                                       Receiver_contact_number__c, Remarks_mentioned__c, Actual_Order_Status__c, Expected_Date_Time__c, Receiver_Name__c, Address__Street__s,
                                       Address__City__s, Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s, Address__Latitude__s, Address__Longitude__s, 
                                       Address__GeocodeAccuracy__s, Address__c, Pin_code__Street__s, Pin_code__City__s, Pin_code__PostalCode__s, Pin_code__StateCode__s, 
                                       Pin_code__CountryCode__s, Pin_code__Latitude__s, Pin_code__Longitude__s, Pin_code__GeocodeAccuracy__s, Pin_code__c, 
                                       Receiver_Mobile_Number__c, Reason_for_RTO__c, Availability_Window__c, Website_App__c, Expected_Delivery_By__c, Product__c, SKU_Details__c, 
                                       Order_Image__c, Invoice_Image__c, Order_SKU_details__c, SKU__c, Expiry_Date__c, Expected_RVP_date__c, Customer_s_Availability__c, 
                                       Required_PIN_code__c, CSE_Name__c, Order__c, Product_Image__c, RVP_Date__c, Stage__c, Refund_Reason__c, Refund_Type__c, Coupon__c, OrderId__c, 
                                       Opportunity__c, Date_Of_Order__c, Shipping_Mobile_No__c, Item__c, Courier_Issue__c, Marketing_Team__c, Reason_For_Dealy__c, Courier_Partner__c, 
                                       AWB_Number__c, Disposition__c, Current_PIN_Code__c, City_Name__c, OOS_Quantity__c, Marketing__c, Case_Reason_Description__c, 
                                       Email_Replied__c, Communication_Mode__c, Channel_Case__c, RefundTeamMember__c, Parent_Case__c, Approval_Step__c, Re_Opening_Reason__c, 
                                       Profile_Name__c, UTR_Number__c, Product2_Name__c, UTRNo__c, Refund_Amount__c, Inital_Commented_Date__c, Rejection_Remarks__c, 
                                       Rejection_Reason__c, Describe_Information_Needed__c, Order_Date__c, Post_Attachment_Url__c, Inbound_Dealy_In_Delivery__c, 
                                       OutBound_Dealy_In_Delivery__c, RTO_Reso__c, InBound_PinCode_not_Serviceable__c, OutBound_PinCode_not_Serviceable__c, 
                                       MT_Assignment_Reason__c, MT_Assignment_Remarks__c, Reason_For_Duplicate_Order__c, Category__c, Type_Of_Case__c, Social_Media_Platform__c, 
                                       User_Name__c, Type_of_Post__c, Post_Id__c, Record_changed__c, Created_DateTime__c, Refund_Reasons__c, Order_Source__c, Caption__c, 
                                       Created_Time__c, POST_URL__c, Comments_JSON__c, Mention__c, HashTag__c, Hash_Tag_Id__c, Customer_s_Request__c, Post_Comments__c, 
                                       Post_Case_Comments__c, Case_Communication__c, Warehouse_Team_Member__c, CS_Team_Member__c, RecordType.Name, Case_Sub_Status__c FROM Case WHERE Id=: recId];
                wareHouseWrapper wr = new wareHouseWrapper();
                if(!caseList.isEmpty()){
                    caseRec = caseList[0];
                    if(caseRec.OrderId__c != null){
                        List<OrderItem> oliList = [SELECT Id, Product2.Name, Quantity, TotalPrice, OrderID, OriginalOrderItemId, Is_Duplicate_Order__c, PricebookEntryId,
                                                   Product2Id, ListPrice, UnitPrice, Refund_Quantity__c,SKU__c FROM OrderItem WHERE OrderID =: caseRec.OrderId__c];
                        if(oliList.size()>0){
                            wr.oliList = oliList;
                        }
                    }
                }
                List<String> customerRequestOptions = getPicklistValues('Case', 'Customer_s_Request__c');
                List<String> caseReasonOptions = getPicklistValues('Case', 'Type_Of_Case__c');
                
                wr.customerRequestOptions = customerRequestOptions;
                wr.caseReasonOptions = caseReasonOptions;
                wr.caseRec = caseRec;
                wr.countryList = getCountryPicklistValues('Case', 'Address_With_Pin_Code__CountryCode__s');
                wr.statesByCountry = dependentPicklistValAPEX.getCountryStateDependencies('Case', 'Address_With_Pin_Code__CountryCode__s', 'Address_With_Pin_Code__StateCode__s');
                return wr;
            }
            return null;
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static String moveToWHteams(Case caseRec){
        try{
            List<User> userLists = [SELECT Id, Name FROM User WHERE Profile.Name = 'WareHouse Team' AND ManagerId = null LIMIT 1];
            List<Group> groupList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId, OwnerId, DoesSendEmailToMembers, DoesIncludeBosses, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM Group WHERE DeveloperName = 'Warehouse_Team_Queue'];
            String queueId;
            if(!groupList.isEmpty()){
                queueId = groupList[0].Id;
            }else if(!userLists.isEmpty()){
                queueId = userLists[0].Id;
            }
            if(queueId != null){
                //caseRec.Warehouse_Team_Member__c = userLists[0].Id;
                if(caseRec.CS_Team_Member__c == null){
                    caseRec.CS_Team_Member__c = caseRec.OwnerId;
                }
                caseRec.OwnerId = queueId;
                caseRec.Status = 'In Progress';
                caseRec.Case_Sub_Status__c = 'Assigned to Warehouse Team';
                update caseRec;
                List<CaseShare> existingShares = [SELECT Id FROM CaseShare WHERE CaseId = :caseRec.Id AND UserOrGroupId = :caseRec.CS_Team_Member__c];
                System.debug('existingShares======>'+existingShares);
                
                if(!existingShares.isEmpty()){
                    //delete existingShares;
                    System.debug('existingShares delete records======>'+existingShares);
                }else{
                    CaseShare newCaseShare = new CaseShare();
                    newCaseShare.CaseId =  caseRec.Id;    //caseRecord.Id;
                    newCaseShare.UserOrGroupId = caseRec.CS_Team_Member__c;
                    newCaseShare.CaseAccessLevel = 'Edit';
                    //newCaseShare.RowCause = Schema.CaseShare.RowCause.Manual;
                    insert newCaseShare;
                    System.debug('newCaseShare======>'+newCaseShare);
                    //sendingCustomNotification(caseRec.Warehouse_Team_Member__c, caseRec.Id, 'Case has been assigned', 'A case has been moved to warehouse team bucket, please take relevant action');
                    return 'Successful';
                }
            }
            return 'error';
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
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
    
    public class wareHouseWrapper{
        @AuraEnabled
        public List<String> customerRequestOptions;
        @AuraEnabled
        public List<String> caseReasonOptions;
        @AuraEnabled
        public Case caseRec;
        @AuraEnabled
        public List<OrderItem> oliList;
        @AuraEnabled
        public List<Country> countryList;
        @AuraEnabled
        public Map<String, List<dependentPicklistValAPEX.State>> statesByCountry;
    }
    
    public static List<String> getPicklistValues(String objName, String fieldName){
        List<String> options = new List<String>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            options.add(objPickList.getValue());
        }
        return options;
    }
    
    public static List<Country> getCountryPicklistValues(String objName, String fieldName){
        List<Country> options = new List<Country>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            Country countryRec = new Country();
            countryRec.value = objPickList.getValue();
            countryRec.label = objPickList.getLabel();
            options.add(countryRec);
        }
        System.debug('options==> ' + options);
        return options;
    }
    
    public class Country {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    
}