public class CaseHelperControllers {
    
    @AuraEnabled(cacheable = true)
    public static List<String> getAllProfileNames() {
        List<String> profileNames = new List<String>();
        
        for (Profile prof : [SELECT Name FROM Profile]) {
            profileNames.add(prof.Name);
        }
        
        return profileNames;
    }
    @AuraEnabled(cacheable=true)
    public static boolean manualCaseShare(String recordId, String userOrGroupId){
        CaseShare cshare = new CaseShare();
        cshare.CaseId = recordId;
        cshare.UserOrGroupId = userOrGroupId;
        cshare.CaseAccessLevel = 'Edit';
        cshare.RowCause = 'manual';
        Database.SaveResult sr = Database.insert(cshare,false);
        
        if(sr.isSuccess()){
            return true;
        }else {
            
            Database.Error err = sr.getErrors()[0];
            
            if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  err.getMessage().contains('AccessLevel')){
                return true;
            }
            else{
                return false;
            }
        }
    }
    
    @AuraEnabled
    public static Case getCaseRec(String caseId){
        try{
            if(caseId != null){
                Case caseRec = [SELECT Id, Sub_Type__c, Sub_Sub_Type__c FROM Case WHERE Id =: caseId LIMIT 1];
                return caseRec;
            }
            return null;
        }catch(exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
            return null;
        }
    }
    /**
* Getting Field Sets
* @author Anwar Chikle
* @description Field Sets for LWC Component for Case Disposition.
*
*/
    // getting case field-set 
    @AuraEnabled
    public static List<String> getCaseFieldSetListss(){
        try{
            List<String> caseFieldSetList = new List<String>();
            List<Schema.FieldSetMember> FieldSetListFromCase  = SobjectType.Case.FieldSets.Field_set_For_Order_Related.getFields();
            for(Schema.FieldSetMember fieldsToAdd : FieldSetListFromCase){
                System.debug('Fields === >'+String.valueOf(fieldsToAdd.sobjectfield));
                caseFieldSetList.add(String.valueOf(fieldsToAdd.sobjectfield));
            }
            if(caseFieldSetList.size()>0){
                return caseFieldSetList;
            }
        }catch(Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }
    /**
* Getting Field Sets
* @author Anwar Chikle
* @description Field Sets for LWC Component for Child Case Creation.
*
*/
    // getting case field-set 
    @AuraEnabled
    public static List<String> getCaseFieldSetList(){
        try{
            List<String> caseFieldSetList = new List<String>();
            List<Schema.FieldSetMember> FieldSetListFromCase  = SobjectType.Case.FieldSets.Field_Set_For_Case_Child_Creation.getFields();
            for(Schema.FieldSetMember fieldsToAdd : FieldSetListFromCase){
                System.debug('Fields === >'+String.valueOf(fieldsToAdd.sobjectfield));
                caseFieldSetList.add(String.valueOf(fieldsToAdd.sobjectfield));
            }
            if(caseFieldSetList.size()>0){
                return caseFieldSetList;
            }
        }catch(Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }
    /**
* Getting All Fields of Case Object
* @author Anwar Chikle
* @description To Display Fields Of Case Obj for field sets itself.
*
*/
    
    @AuraEnabled
    public static List<String> getAllCaseFields() {
        
        try{
            List<String> allAPInames = new List<String>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType sobjSchema = schemaMap.get('Case');
            Map<String, Schema.SObjectField> fieldMap = sobjSchema.getDescribe().fields.getMap();            
            for (SObjectField field: fieldMap.values()) {  
                DescribeFieldresult fieldDesc = field.getDescribe();
                String fieldName = fieldDesc.getName();
                allAPInames.add(fieldName);
                //System.debug('fieldName==> ' + fieldName);
            }
            return allAPInames;   
        }
        catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number ==> ' + e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static Id getRecrdTypeId(String recordId){
        
        return [SELECT Id,RecordTypeId FROM Case where Id =: recordId LIMIT 1].RecordTypeId;
    }
    @AuraEnabled
    public static Id getRecrdTypeIdChat(){
        
        return [SELECT Id,RecordTypeId FROM Case LIMIT 1].RecordTypeId;
    }
    
    @AuraEnabled
    public static Case caseRecord(String caseId){
        system.debug('recordId::::::::>'+caseId);
        case cs =  [SELECT Id,RecordTypeId,Parent_Case__c FROM Case where Id =: caseId];
        system.debug('cs::::::::>'+cs);
        return cs;
        
    }
    @AuraEnabled
    public static Case getCaseRecord(String caseId){
        system.debug('recordId::::::::>'+caseId);
        case cs =  [SELECT Id,RecordTypeId,Parent_Case__c,Sub_Type__c,Sub_Sub_Type__c,OwnerId,Subject,Status,Origin,AccountId,Contact_Number__c,ContactId,Owner.Name FROM Case where Id =: caseId];
        system.debug('cs::::::::>'+cs);
        return cs;
        
    }
    
    @AuraEnabled
    public static Case getCaseRecords(){
        case cs =  [SELECT Id,RecordTypeId,Parent_Case__c,Sub_Type__c,Sub_Sub_Type__c,OwnerId,Subject,Status,Origin,AccountId,Contact_Number__c,ContactId,Owner.Name FROM Case LIMIT 1];
        system.debug('cs::::::::>'+cs);
        return cs;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ObjectType> getCaseRecordTypes() {
        List<ObjectType> recordTypes = new List<ObjectType>();
        
        try {
            Schema.SObjectType caseType = Schema.getGlobalDescribe().get('Case');
            Map<String, Schema.RecordTypeInfo> rtInfos = caseType.getDescribe().getRecordTypeInfosByName();
            
            for (String rtName : rtInfos.keySet()) {
                Schema.RecordTypeInfo rtInfo = rtInfos.get(rtName);
                ObjectType objType = new ObjectType(rtInfo.getRecordTypeId(), rtInfo.getName());
                recordTypes.add(objType);
            }
        } catch (Exception e) {
            // Handle exception if necessary
            System.debug('Exception: ' + e.getMessage());
        }
        
        return recordTypes;
    }
    
    @AuraEnabled(cacheable=true)
    public Static Map<Id, String> getAllRT(){
        String objectAPIName = 'Case' ;
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<Id,String> mapOfRecordTypeIdWithName = new Map<Id, String>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapOfRecordTypeIdWithName.put(info.getRecordTypeId(), info.getName());
        }
        System.debug('Record Type Id With Name' + mapOfRecordTypeIdWithName);
        return mapOfRecordTypeIdWithName;
        
    }
    
    // Inner class to represent record types
    public class ObjectType {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        
        public ObjectType(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> dependentFields(){
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Case');
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get('Sub_Type__c').getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get('Sub_Sub_Type__c').getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
            
            Integer baseCount = 0;
            
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
                
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }
                
                if((val & 8) == 8)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        }
        
        System.debug('ControllingInfo: ' + controllingInfo);
        
        return controllingInfo;
    }
    class MyPickListInfo {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }
    
    @AuraEnabled
    public static string reOpenCase(String RecId, String Reason){
        system.debug('RecId:::::::::>'+RecId);
        system.debug('Reason:::::::::>'+Reason);
        try {
            Case Cs = new Case();
            set<Id> setOfOwnerId = new set<Id>();
            if(Reason != null){                   
                cs.Id = RecId;
                cs.Status = 'Re-Opened';
                cs.Re_Opening_Reason__c = Reason;  
            }
            update cs;
            system.debug('cs:::::>'+cs);
            Case cseList = [SELECT Id,ContactId,Contact.Email,OwnerId,Owner.email From Case Where Id =: cs.Id];
            String CaseOwnId = cseList.Owner.email;
            
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
            // notification to user
            notification.setBody('An Old Case Has been Re-Opened. Please check the details.');
            notification.setTitle('Dear User, An Old Case Has been Re-Opened.');
            notification.setSenderId(UserInfo.getUserId());
            notification.setNotificationTypeId(customNotiList.Id); 
            notification.setTargetId(cs.Id);
            System.debug('notification:::::::::::>' + notification);
            if(cseList.OwnerId != null){
                notification.send(new set<String>{cseList.OwnerId});
            }
            
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate temp = [SELECT Id,Subject, Body FROM EmailTemplate WHERE Name ='child case creation'];
            List<String> setToAdresses = new List<String>();
            setToAdresses.add(CaseOwnId);
            String body = temp.body;
            if(CaseOwnId != null){
                Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage(); 
                body = body.replace('{!Case.Id}',cseList.Id);
                mailTemp.setPlainTextBody(body);
                mailTemp.setTemplateId(temp.id);
                mailTemp.setTargetObjectId(cseList.ContactId);
                mailTemp.setToAddresses(setToAdresses);
                mailTemp.setSaveAsActivity(false);
                mailTemp.setWhatId(cseList.Id);
                mails.add(mailTemp);
            }
            
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());  
            throw new AuraHandledException(e.getMessage());
            
            
        }
    }
    // handle data in 3 types
    // @AuraEnabled(cacheable=true)
    // public static String fetchDependentPicklistValues(){
    //     List<recordTypeCustomMetaData__mdt> StateCityAreaList = [SELECT Id,RecordType__c,Type__c,Sub_Type__c FROM recordTypeCustomMetaData__mdt];
    //     Map<String,List<Map<String,List<String>>>> MapOfStateCityAreaList = new Map<String,List<Map<String,List<String>>>>();
    //     Map<String,List<String>> mapOfCityArea = new  Map<String,List<String>>();
    //     for(recordTypeCustomMetaData__mdt data : StateCityAreaList){
    //         mapOfCityArea = new Map<String,List<String>>();
    //         List<String> areaList = data.Sub_Type__c.split(','); 
    //         mapOfCityArea.put(data.Type__c,areaList);
    //         if(MapOfStateCityAreaList.containsKey(data.RecordType__c)){
    //             MapOfStateCityAreaList.get(data.RecordType__c).add(mapOfCityArea);
    //         }
    //         else{
    //             MapOfStateCityAreaList.put(data.RecordType__c,new List<Map<String,List<String>>>{mapOfCityArea});
    //         }
    //     }
    //     system.debug('MapOfStateCityAreaList == >'+MapOfStateCityAreaList);
    //     return JSON.serialize(MapOfStateCityAreaList);
    // }
    
    // handle data in 2 types
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> fetchDependentPicklist() {
        try {
            Map<String, List<String>> mapOfPicklist = new Map<String, List<String>>();
            List<recordTypeCustomData__mdt> recTypAndTypList = [SELECT Id, RecordType__c, Types__c FROM recordTypeCustomData__mdt];
            
            for (recordTypeCustomData__mdt data : recTypAndTypList) {
                List<String> listOfString = data.Types__c.split(',');
                
                if (!mapOfPicklist.containsKey(data.RecordType__c)) {
                    mapOfPicklist.put(data.RecordType__c, listOfString);
                } else {
                    mapOfPicklist.get(data.RecordType__c).addAll(listOfString);
                }
            }
            system.debug('mapOfPicklist:::::::>'+mapOfPicklist);
            
            return mapOfPicklist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String createChildCase(String RecordTypeName, String Type, String SubType, String AccId, String conId, String Subjt, String conNumber, String recId, Id ownId) {
        system.debug('RecordTypeName ==> '+RecordTypeName + 'Type===>'+Type + 'SubType===>'+SubType+ 'AccId===>'+AccId+ 'conId===>'+conId+ 'Subjt===>'+Subjt +'conNumber===>'+conNumber+ 'recId===>'+recId+ 'ownId===>'+ownId);
        try {
            Case newCase = new Case();
            if (RecordTypeName != null && Type != null && SubType != null) {
                Set<Id> setOfOwnerId = new Set<Id>();
                List<Case> cseList = new List<Case>();
                RecordType rt = [SELECT Id FROM RecordType WHERE Name = :RecordTypeName LIMIT 1];
                
                newCase.RecordTypeId = rt.Id;
                newCase.Sub_Type__c = Type;
                newCase.Sub_Sub_Type__c = SubType;
                
                if(AccId != null){
                    newCase.AccountId = AccId;
                }
                if(conId != null){
                    newCase.ContactId = conId;
                }
                if(Subjt != null){
                    newCase.Subject = Subjt;
                }
                if(AccId != null){
                    newCase.Contact_Number__c = conNumber;
                }
                
                newCase.Status = 'New';
                newCase.OwnerId = ownId;
                newCase.ParentId = recId;
                
                insert newCase;
                setOfOwnerId.add(newCase.OwnerId);
                cseList.add(newCase);
                System.debug('newCase:::::::::::>' + newCase);
                
                // Case caseRec = new Case(Id = recId, Parent_Case__c = newCase.Id);
                // update caseRec;
                // System.debug('caseRec:::::::::::>' + caseRec);
                
                Set<String> setOfUserId = new Set<String>();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
                List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :setOfOwnerId];
                EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='child case creation'];
                Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                System.debug('userList:::::::::::>' + userList);
                for (User us : userList) {
                    setOfUserId.add(us.Id);
                }
                System.debug('setOfUserId:::::::::::>' + setOfUserId);
                
                // notification to user
                notification.setBody('A New Case Has been created. Please check the details.');
                notification.setTitle('Hi, A New Case Has been created.');
                notification.setSenderId(UserInfo.getUserId());
                notification.setNotificationTypeId(customNotiList.Id); 
                notification.setTargetId(newCase.Id);
                // email to user
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                String body = temp.body;
                body = body.replace('{!Case.Id}',newCase.Id);
                mail.setPlainTextBody(body);
                mail.setTemplateId(temp.id);
                //mail.setTargetObjectId(newCase.Id);
                mail.setToAddresses(new List<String> { UserInfo.getUserId() });
                mailList.add(mail);
                
                System.debug('notification:::::::::::>' + notification);
                notification.send(new Set<String> { newCase.OwnerId });
                // Messaging.sendEmail(mailList);
                
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }
    
    
    @AuraEnabled
    public static List<Case> getRelatedCases(String recId) {
        Case cse = [SELECT Id, CaseNumber, Subject, OrderId__r.OrderNumber,OrderId__c,Sub_Type__c,Sub_Sub_Type__c FROM Case WHERE Id = :recId];
        System.debug('cse:::::::::::>' + cse);
        Set<Id> caseOrderIds = new Set<Id>();
        set<String> TypeString = new set<String>();
        set<String> SubTypeString = new set<String>();
        if (cse.OrderId__c != null || cse.Sub_Type__c != null) {
            caseOrderIds.add(cse.OrderId__c);
            TypeString.add(cse.Sub_Type__c);
            SubTypeString.add(cse.Sub_Sub_Type__c);
        }
        System.debug('caseOrderIds:::::::::::>' + caseOrderIds);
        List<Case> caseList = [SELECT Id, Subject, Origin, Status, OrderId__r.OrderNumber,CaseNumber,Sub_Type__c,Sub_Sub_Type__c FROM Case WHERE OrderId__c IN :caseOrderIds AND Sub_Type__c IN: TypeString  AND  Sub_Sub_Type__c IN: SubTypeString AND ParentId = null Order By CreatedDate];
        System.debug('caseList:::::::::::>' + caseList);
        return caseList;
    }
    
    
    @AuraEnabled
    public static List<Case> mergeSelectedCases(String caseId, List<Case> cases) {
        System.debug('CaseId:::::::::::>' + caseId);
        System.debug('cases:::::::::::>' + cases);
        
        Set<Id> setOfCaseId = new Set<Id>();
        List<String> caseIdList = caseId.split(',');
        for (String cs : caseIdList) {
            setOfCaseId.add(cs);
        }
        System.debug('setOfCaseId:::::::::::>' + setOfCaseId);
        
        Set<Id> caseIdsToMerge = new Set<Id>();
        for (Case cs : cases) {
            caseIdsToMerge.add(cs.Id);
        }
        System.debug('caseIdsToMerge:::::::::::>' + caseIdsToMerge);
        
        caseIdsToMerge.removeAll(setOfCaseId);
        System.debug('caseIdsToMerge:::::::::::>' + caseIdsToMerge);
        
        List<Case> casesToMerge = [SELECT Id, CaseNumber, Subject, Origin, Status, OrderId__r.OrderNumber, ParentId FROM Case WHERE Id IN :caseIdsToMerge];
        System.debug('casesToMerge:::::::::::>' + casesToMerge);
        List<Case> casesToUpdate = new List<Case>();
        
        for (Case c : casesToMerge) {
            c.ParentId = setOfCaseId.isEmpty() ? null : setOfCaseId.iterator().next();
            System.debug('c.ParentId:::::::::::>' + c.ParentId);
            casesToUpdate.add(c);
        }
        
        update casesToUpdate;
        return casesToUpdate;
    }
    
  
    //this method is not used anywhere
  /*  public static void sendEmailToUserAndNotificationToUserPincodeNotServiceable(List<Case> caseList,  map<Id,Case> oldMapCase) {
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Order_Issue_Pin_Code_Unserviceable_Refund_Initiated'];
        List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='custom_notification_to_refund_team_on_pincode_not_serviceable'];
        Map<Id, List<String>> mapOfEmails = new Map<Id, List<String>>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
        
        String str = temp.HTMLValue;
        String body = temp.body;
        
        set<Id> setOfId = new set<Id>();
        set<Id> setOfOrderId = new set<Id>();
        for(case cs : caseList){
            setOfId.add(cs.contactId);
            setOfOrderId.add(cs.OrderId__c);
        }
        List<User> userList = [SELECT Id,Name,Profile.Name From User Where Profile.Name =:'Refund Team'];
        set<String> refundTeamUsers = new set<String>();
        List<Id> refundTeamTaskUsers = new List<Id>();
        for(User usr : userList){
            refundTeamUsers.add(usr.Id);
            refundTeamTaskUsers.add(usr.Id);
        }
        
        List<User> userListForWareHouse = [SELECT Id,Name,Profile.Name From User Where Profile.Name =:'WareHouse Team'];
        set<String> WareHouseUsers = new set<String>();
        for(User usr : userListForWareHouse){
            WareHouseUsers.add(usr.Id);
            
        }
        
        
        List<String> emailString1 = new List<String>();
        List<decimal> ordNumber = new List<decimal>();
        Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
        
        List<Contact> conList =[SELECT Id,Name,Email From Contact Where Id IN:setOfId];
        
        Map<Id,Order> mapOfOrd = new Map<Id,Order>();
        List<Order> orderList = [SELECT Id,CreatedDate,OrderNumber From Order Where Id IN:setOfOrderId];
        for(Order ord : orderList){
            if(!mapOfOrd.containsKey(ord.Id)){
                mapOfOrd.put(Ord.Id,Ord);
            }
        }
        
        for(Contact con : conList){
            mapOfContact.put(con.Id, con);
        }
        
        List<String> emailString = new List<String>();
        
        List<task> taskList = new List<task>();
        for (Case cse : caseList) {
            
            if(cse.OutBound_PinCode_not_Serviceable__c != oldMapCase.get(cse.Id).OutBound_PinCode_not_Serviceable__c){
                // if (cse.OutBound_PinCode_not_Serviceable__c == true) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                Messaging.CustomNotification WareHouseNotification = new Messaging.CustomNotification();
                
                if (cse.ContactId != null) {
                    Body = Body.replace('{!Case.Contact}', mapOfContact.get(cse.ContactId).Name);
                }
                if (cse.OrderId__c != null) {
                    Body = Body.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                }
                if (cse.CreatedDate != null) {
                    Body = Body.replace('{!Case.CreatedDate}', String.ValueOf(cse.CreatedDate));
                }
                if (cse.Address_With_Pin_Code__PostalCode__s != null) {
                    Body = Body.replace('{!Case.Address_With_Pin_Code__c}', cse.Address_With_Pin_Code__PostalCode__s);
                }
                if (cse.Amount_Paid__c != null) {
                    Body = Body.replace('{!Case.Amount_Paid__c}', String.valueOf(cse.Amount_Paid__c));
                }if(mapOfContact.get(cse.ContactId).Email != null){
                    emailString.add(mapOfContact.get(cse.ContactId).Email);
                }
                mail.setSubject(temp != null ? temp.Subject : '');
                mail.setPlainTextBody(Body);
                mail.setTemplateId(temp != null ? temp.Id : null);
                mail.setSaveAsActivity(true);
                mail.setWhatId(cse.Id);
                mail.setToAddresses(emailString);
                mailList.add(mail);
                
                notification.setBody('Dear Refund teams, Please take a look of this Order as pincode is not serviceable, Please Do the Refund as early as Possible'); 
                notification.setTitle('Pincode Not ServiceAble'); 
                notification.setSenderId(Userinfo.getUserId()); 
                notification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                notification.setTargetId(cse.id);
                notification.send(refundTeamUsers);
                
                WareHouseNotification.setBody('Dear WareHouse, Please take a look of this Order as pincode is not serviceable, Please Do not delivery the Order'); 
                WareHouseNotification.setTitle('Pincode Not ServiceAble'); 
                WareHouseNotification.setSenderId(Userinfo.getUserId()); 
                WareHouseNotification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                WareHouseNotification.setTargetId(cse.id);
                WareHouseNotification.send(WareHouseUsers);
                
                task tsk = new task();
                tsk.subject ='Refund the Money To Customer';
                tsk.Priority = 'High';
                tsk.ActivityDate = System.today().addDays(2);
                tsk.whatId =   cse.Id;
                tsk.OwnerId = refundTeamTaskUsers[0];
                taskList.add(tsk);
                
            } 
            if(cse.InBound_PinCode_not_Serviceable__c != oldMapCase.get(cse.Id).InBound_PinCode_not_Serviceable__c) {   
                //  else if (cse.InBound_PinCode_not_Serviceable__c == true) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                Messaging.CustomNotification WareHouseNotification = new Messaging.CustomNotification();
                
                if (cse.ContactId != null) {
                    Body = Body.replace('{!Case.Contact}', mapOfContact.get(cse.ContactId).Name);
                }
                if (cse.OrderId__c != null) {
                    Body = Body.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                }
                if (cse.CreatedDate != null) {
                    Body = Body.replace('{!Case.CreatedDate}', String.ValueOf(cse.CreatedDate));
                }
                if (cse.Address_With_Pin_Code__PostalCode__s != null) {
                    Body = Body.replace('{!Case.Address_With_Pin_Code__c}', cse.Address_With_Pin_Code__PostalCode__s);
                }
                if (cse.Amount_Paid__c != null) {
                    Body = Body.replace('{!Case.Amount_Paid__c}', String.valueOf(cse.Amount_Paid__c));
                }
                if(mapOfContact.get(cse.ContactId).Email != null){
                    emailString.add(mapOfContact.get(cse.ContactId).Email);
                }
                mail.setPlainTextBody(Body);
                mail.setTemplateId(temp != null ? temp.Id : null);
                mail.setSaveAsActivity(true);
                mail.setWhatId(cse.Id);
                mail.setToAddresses(emailString);
                mailList.add(mail);
                system.debug('mailList:::::::::>' + mailList);
                
                notification.setBody('Dear Refund teams, Please take a look of this Order as pincode is not serviceable, Please Do the Refund as early as Possible'); 
                notification.setTitle('Pincode Not ServiceAble'); 
                notification.setSenderId(Userinfo.getUserId()); 
                notification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                notification.setTargetId(cse.id);
                notification.send(refundTeamUsers); 
                system.debug('notification:::::::::>' + notification);
                
                
                WareHouseNotification.setBody('Dear WareHouse, Please take a look of this Order as pincode is not serviceable, Please Do not delivery the Order'); 
                WareHouseNotification.setTitle('Pincode Not ServiceAble'); 
                WareHouseNotification.setSenderId(Userinfo.getUserId()); 
                WareHouseNotification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                WareHouseNotification.setTargetId(cse.id);
                WareHouseNotification.send(WareHouseUsers);
                
                task tsk = new task();
                tsk.subject ='Refund the Money To Customer';
                tsk.Priority = 'High';
                tsk.ActivityDate = System.today().addDays(2);
                tsk.whatId =   cse.Id;
                tsk.OwnerId = refundTeamTaskUsers[0];
                taskList.add(tsk);
            }
        }
        
        if (!mailList.isEmpty()) {
            //Messaging.sendEmail(mailList);
        }
        Insert taskList;
        system.debug('taskList:::::::::>' + taskList);
        
    } */
    
    
   
    
    //this method is not used anywhere
  /*  public static void sendEmailToUserAndNotificationToUserDelayInDelivery(List<Case> caseList, map<Id,Case> oldMapCase) {
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Urgent_Customer_Unresponsive_After_3_Attempted_Calls_Regarding_Delayed_Order'];
        List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='custom_notification_to_refund_team_on_dealy_delivery'];
        Map<Id, List<String>> mapOfEmails = new Map<Id, List<String>>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
        
        String str = temp.HTMLValue;
        String body = temp.body;
        
        set<Id> setOfId = new set<Id>();
        set<Id> setOfOrderId = new set<Id>();
        for(case cs : caseList){
            setOfId.add(cs.contactId);
            setOfOrderId.add(cs.OrderId__c);
        }
        List<User> userList = [SELECT Id,Name,Profile.Name From User Where Profile.Name =:'Refund Team'];
        set<String> refundTeamUsers = new set<String>();
        List<Id> refundTeamTaskUsers = new List<Id>();
        for(User usr : userList){
            refundTeamUsers.add(usr.Id);
            refundTeamTaskUsers.add(usr.Id);
        }
        
        
        List<User> userListForWareHouse = [SELECT Id,Name,Profile.Name From User Where Profile.Name =:'WareHouse Team'];
        set<String> WareHouseUsers = new set<String>();
        for(User usr : userListForWareHouse){
            WareHouseUsers.add(usr.Id);
        }
        
        List<User> usersListForOwner = [SELECT Id,Name,Email From User];
        Map<Id,User> mapOfUser = new Map<Id,User>();
        for(User usr : usersListForOwner){
            mapOfUser.put(usr.Id,usr);
        }
        List<String> emailString1 = new List<String>();
        List<decimal> ordNumber = new List<decimal>();
        Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
        
        List<Contact> conList =[SELECT Id,Name,Email From Contact Where Id IN:setOfId];
        
        Map<Id,Order> mapOfOrd = new Map<Id,Order>();
        List<Order> orderList = [SELECT Id,CreatedDate,OrderNumber From Order Where Id IN:setOfOrderId];
        for(Order ord : orderList){
            if(!mapOfOrd.containsKey(ord.Id)){
                mapOfOrd.put(Ord.Id,Ord);
            }
        }
        
        for(Contact con : conList){
            mapOfContact.put(con.Id, con);
        }
        List<String> emailString = new List<String>();
        
        List<task> taskList = new List<task>();
        for (Case cse : caseList) {
            
            if(cse.OutBound_Dealy_In_Delivery__c != oldMapCase.get(cse.Id).OutBound_Dealy_In_Delivery__c){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                Messaging.CustomNotification WareHouseNotification = new Messaging.CustomNotification();
                
                if (cse.ContactId != null) {
                    Body = Body.replace('{!Case.Contact}', mapOfContact.get(cse.ContactId).Name);
                } 
                if (cse.OrderId__c != null) {
                    Body = Body.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                }
                if (cse.CreatedDate != null) {
                    Body = Body.replace('{!Case.CreatedDate}', String.ValueOf(cse.CreatedDate));
                }
                if (cse.OwnerId != null) {
                    Body = Body.replace('{!Case.OwnerFullName}', mapOfUser.get(cse.OwnerId).Name);
                }
                
                
                if(mapOfContact.get(cse.ContactId).Email != null){
                    emailString.add(mapOfContact.get(cse.ContactId).Email);
                }
                mail.setSubject(temp != null ? temp.Subject : '');
                mail.setPlainTextBody(Body);
                mail.setTemplateId(temp != null ? temp.Id : null);
                mail.setSaveAsActivity(true);
                mail.setWhatId(cse.Id);
                mail.setToAddresses(emailString);
                mailList.add(mail);
                
                notification.setBody('Dear Warehouse and Refund teams,Please take a look at product delays in delivery and correct the issue promptly.'); 
                notification.setTitle('Delay in Delivery'); 
                notification.setSenderId(Userinfo.getUserId()); 
                notification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                notification.setTargetId(cse.id);
                notification.send(refundTeamUsers);
                
                WareHouseNotification.setBody('Dear Warehouse and Refund teams,Please take a look at product delays in delivery and correct the issue promptly.'); 
                WareHouseNotification.setTitle('Delay in Delivery'); 
                WareHouseNotification.setSenderId(Userinfo.getUserId()); 
                WareHouseNotification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                WareHouseNotification.setTargetId(cse.id);
                WareHouseNotification.send(WareHouseUsers);
                
                task tsk = new task();
                tsk.subject ='Delay in Delivery';
                tsk.Priority = 'High';
                tsk.ActivityDate = System.today().addDays(2);
                tsk.whatId =   cse.Id;
                tsk.OwnerId = refundTeamTaskUsers[0];
                taskList.add(tsk);
                
            }
            if(cse.Inbound_Dealy_In_Delivery__c != oldMapCase.get(cse.Id).Inbound_Dealy_In_Delivery__c){
                // else if (cse.Inbound_Dealy_In_Delivery__c == true) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                Messaging.CustomNotification WareHouseNotification = new Messaging.CustomNotification();
                
                if (cse.ContactId != null) {
                    Body = Body.replace('{!Case.Contact}', mapOfContact.get(cse.ContactId).Name);
                }
                
                if (cse.OrderId__c != null) {
                    Body = Body.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                }
                if (cse.CreatedDate != null) {
                    Body = Body.replace('{!Case.CreatedDate}', String.ValueOf(cse.CreatedDate));
                }
                if (cse.OwnerId != null) {
                    Body = Body.replace('{!Case.OwnerFullName}', mapOfUser.get(cse.OwnerId).Name);
                }
                if(mapOfContact.get(cse.ContactId).Email != null){
                    emailString.add(mapOfContact.get(cse.ContactId).Email);
                }
                mail.setPlainTextBody(Body);
                mail.setTemplateId(temp != null ? temp.Id : null);
                mail.setSaveAsActivity(true);
                mail.setWhatId(cse.Id);
                mail.setToAddresses(emailString);
                mailList.add(mail);
                system.debug('mailList:::::::::>' + mailList);
                
                notification.setBody('Dear Warehouse and Refund teams,Please take a look at product delays in delivery and correct the issue promptly.'); 
                notification.setTitle('Delay in Delivery'); 
                notification.setSenderId(Userinfo.getUserId()); 
                notification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                notification.setTargetId(cse.id);
                notification.send(refundTeamUsers);   
                system.debug('notification:::::::::>' + notification);
                
                WareHouseNotification.setBody('Dear Warehouse and Refund teams,Please take a look at product delays in delivery and correct the issue promptly.'); 
                WareHouseNotification.setTitle('Delay in Delivery'); 
                WareHouseNotification.setSenderId(Userinfo.getUserId()); 
                WareHouseNotification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                WareHouseNotification.setTargetId(cse.id);
                WareHouseNotification.send(WareHouseUsers);
                
                task tsk = new task();
                tsk.subject ='Delay in Delivery';
                tsk.Priority = 'High';
                tsk.ActivityDate = System.today().addDays(2);
                tsk.whatId =   cse.Id;
                tsk.OwnerId = refundTeamTaskUsers[0];
                taskList.add(tsk);
            }
        }
        
        if (!mailList.isEmpty()) {
            //  Messaging.sendEmail(mailList);
        }
        Insert taskList;
        system.debug('taskList:::::::::>' + taskList);
        
    } */
    
    
    //this method is not used anywhere
 /*   public static void sendEmailToContactOwnerAndSendNotificationToOMSTeam(List<Case> caseList, map<Id,Case> oldMapCase){
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Order_Issue_Pin_Code_Unserviceable_Refund_Initiated'];
        List<CustomNotificationType> TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='custom_notification_to_refund_team_on_pincode_not_serviceable'];
        Map<Id, List<String>> mapOfEmails = new Map<Id, List<String>>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
        
        String str = temp.HTMLValue;
        String body = temp.Body;
        
        Set<Id> setOfId = new Set<Id>();
        Set<Id> setOfAccId = new Set<Id>();
        Set<Id> setOfOrderId = new Set<Id>();
        for (Case cs : caseList) {
            if(cs.AccountId != null){
                setOfAccId.add(cs.AccountId);
            }else if(cs.ContactId != null){
                setOfId.add(cs.ContactId);
            }
            setOfOrderId.add(cs.OrderId__c);
        }
        System.debug('setOfOrderId:::::::::>' + setOfOrderId);
        System.debug('setOfId:::::::::>' + setOfId);
        System.debug('setOfAccId:::::::::>' + setOfAccId);
        List<User> userList = [SELECT Id, Name, Profile.Name,Email FROM User WHERE Profile.Name = 'Order Management Team'];
        System.debug('userList:::::::::>' + userList);
        Set<String> OrderManagementTeamUsers = new Set<String>();
        List<String> OMTEmail = new List<String>();
        List<Id> OrderManagementTeamTaskUsers = new List<Id>();
        for (User usr : userList) {
            OrderManagementTeamUsers.add(usr.Id);
            OrderManagementTeamTaskUsers.add(usr.Id);
            OMTEmail.add(usr.Email);
        }
        System.debug('OrderManagementTeamUsers:::::::::>' + OrderManagementTeamUsers);
        System.debug('OrderManagementTeamTaskUsers:::::::::>' + OrderManagementTeamTaskUsers);
        
        List<String> emailString1 = new List<String>();
        List<Decimal> ordNumber = new List<Decimal>();
        Map<Id, Contact> mapOfContact = new Map<Id, Contact>();
        Map<Id, Account> mapOfAccount = new Map<Id, Account>();
        
        List<Contact> conList = [SELECT Id, Name, Email FROM Contact WHERE Id IN :setOfId];
        List<Account> accList = [SELECT Id, Name, Email__c FROM Account WHERE Id IN: setOfAccId];
        
        Map<Id, Order> mapOfOrd = new Map<Id, Order>();
        List<Order> orderList = [SELECT Id, CreatedDate, OrderNumber FROM Order WHERE Id IN :setOfOrderId];
        for (Order ord : orderList) {
            if (!mapOfOrd.containsKey(ord.Id)) {
                mapOfOrd.put(ord.Id, ord);
            }
        }
        
        for (Contact con : conList) {
            mapOfContact.put(con.Id, con);
        }
        for (Account acc : accList) {
            mapOfAccount.put(acc.Id, acc);
        }
        List<String> emailString = new List<String>();
        
        List<Task> taskList = new List<Task>();
        for (Case cse : caseList) {
            if (cse.Reason_for_RTO__c != null) {
                if(cse.Reason_for_RTO__c != oldMapCase.get(cse.Id).Reason_for_RTO__c){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    
                    if (cse.AccountId != null) {
                        body = body.replace('{!Case.Account}', mapOfAccount.get(cse.AccountId).Name);
                    }
                    else if (cse.ContactId != null) {
                        body = body.replace('{!Case.Contact}', mapOfContact.get(cse.ContactId).Name);
                    }
                    if (cse.OrderId__c != null) {
                        body = body.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                    }
                    if (cse.CreatedDate != null) {
                        body = body.replace('{!Case.CreatedDate}', String.ValueOf(cse.CreatedDate));
                    }
                    mail.setSubject(temp != null ? temp.Subject : '');
                    mail.setPlainTextBody(body);
                    mail.setTemplateId(temp != null ? temp.Id : null);
                    mail.setSaveAsActivity(true);
                    mail.setWhatId(cse.Id);
                    mail.setToAddresses(OMTEmail);
                    mailList.add(mail);
                    
                    notification.setBody('Dear OrderManagement, Please take a look at this Order as the it is been returing to Origin. Please do not deliver the Order and initiate the refund as early as possible.');
                    notification.setTitle('Return to Origin');
                    notification.setSenderId(UserInfo.getUserId());
                    notification.setNotificationTypeId(TemplateInfoDetail[0].Id);
                    notification.setTargetId(cse.Id);
                    notification.send(OrderManagementTeamUsers);
                    
                    Task tsk = new Task();
                    tsk.Subject = 'Check the Order Which Is Delivered';
                    tsk.Priority = 'High';
                    tsk.ActivityDate = System.today().addDays(2);
                    tsk.WhatId = cse.Id;
                    tsk.OwnerId = OrderManagementTeamTaskUsers[0];
                    taskList.add(tsk);
                }
            }
        }
        
        if (!mailList.isEmpty()) {
            // Messaging.sendEmail(mailList);
        }
        Insert taskList;
        System.debug('taskList:::::::::>' + taskList);
    } */
    @AuraEnabled
    public static Case courierRelatedCase(String recId) {
        System.debug('recId ==>' + recId);
        try {
            // Use Database.queryById to handle potential exceptions if record not found
            Case cse = [SELECT Id, Address_With_Pin_Code__PostalCode__s, Address_With_Pin_Code__Street__s, Address_With_Pin_Code__City__s, Address_With_Pin_Code__StateCode__s, 
                        Address_With_Pin_Code__CountryCode__s, Address_With_Pin_Code__Latitude__s, Address_With_Pin_Code__Longitude__s, Address_With_Pin_Code__GeocodeAccuracy__s, 
                        Address_With_Pin_Code__c FROM Case where Id =:recId];
            if (cse != null) {
                return cse;
            }
        } catch (QueryException e) {
            System.debug('Error fetching Case record: ' + e.getMessage());
        }
        return null; // If record not found or other error occurs
    }
    
    
    @AuraEnabled
    public static String updateCaseAndOrder(String recId) {
        system.debug('recId=======>'+ recId);
        Case cse = [SELECT Id, ContactId, OrderId__c,Address_With_Pin_Code__Street__s,Address_With_Pin_Code__City__s,Contact_Number__c,
                    Address_With_Pin_Code__PostalCode__s,Address_With_Pin_Code__CountryCode__s,Address_With_Pin_Code__StateCode__s FROM Case WHERE Id = :recId LIMIT 1];
        if (cse != null) {
            if(cse.ContactId != null){
                Contact conRec = [SELECT Id FROM Contact WHERE Id = :cse.ContactId LIMIT 1];
                if (conRec != null) {
                    conRec.Phone = cse.Contact_Number__c;
                    update conRec;
                }
            }
            
            
            if(cse.OrderId__c != null){
                Order ordRec = [SELECT Id FROM Order WHERE Id = :cse.OrderId__c LIMIT 1];
                if (ordRec != null) {
                    ordRec.ShippingStreet = cse.Address_With_Pin_Code__Street__s;
                    ordRec.ShippingState = cse.Address_With_Pin_Code__StateCode__s;
                    ordRec.ShippingCity = cse.Address_With_Pin_Code__City__s;
                    ordRec.ShippingCountry = cse.Address_With_Pin_Code__CountryCode__s;
                    ordRec.ShippingPostalCode =  cse.Address_With_Pin_Code__PostalCode__s;
                    update ordRec;
                }
            }
            
            
            return 'SUCCESS';
        } else {
            return 'ERROR: Case not found';
        }
    }
    
    @AuraEnabled
    public static String sendNotificationToOrderManagementTeam(String recId){
        try{
            List<Case> caseList = [SELECT Id,Status From Case Where Id=:recId];
            List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='custom_notification_to_refund_team_on_pincode_not_serviceable'];
            List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
            
            List<User> userist = [SELECT Id,Name,Email,Profile.Name From User Where Profile.Name = 'Order Management Team'];
            Set<String> OrderManagementTeamUsers = new Set<String>();
            for(User usr : userist){
                OrderManagementTeamUsers.add(usr.Id);
            }
            for (Case cse : caseList) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                
                notification.setBody('A new Case Has been Assigned to you Please go through it and resolve it ASAP');
                notification.setTitle('Assigned To Marketing Team');
                notification.setSenderId(UserInfo.getUserId());
                notification.setNotificationTypeId(TemplateInfoDetail[0].Id);
                notification.setTargetId(cse.Id);
                notification.send(OrderManagementTeamUsers);
            }
            return 'SUCCESS';
        }catch(Exception e){
            system.debug('Line Number'+ e.getLineNumber());
            return null;
        }
    }
    
    
    // Method to get Profile Name & its User List
    @AuraEnabled 
    public static Map<String,List<User>> getProfileBasedUserList(){
        try{
            Map<String, List<User>> profileUserMap = new Map<String, List<User>>();
            String ProfileNamesString = System.Label.profile_names;
            Set<String> ProfilenamesList = new Set<String>();
            ProfilenamesList.addAll(ProfileNamesString.split(',')); 
            System.debug('ProfilenamesList == >'+ProfilenamesList);
            List<User> userList = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name IN:ProfilenamesList];
            for(User u : userList) {
                String profileName = u.Profile.Name;
                if(!profileUserMap.containsKey(profileName)) {
                    profileUserMap.put(profileName, new List<User>());
                }
                profileUserMap.get(profileName).add(u);
            }
            if(profileUserMap.size()>0){
                System.debug('profileUserMap === >'+profileUserMap);
                return profileUserMap;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static Case createCaseUnderAccount(String recId, String RecordTypeName, String Type, String SubType, String Subjt, String Description, String OrderId, String Category) {
        try {
            Case newCase = new Case();
            
            if (RecordTypeName != null && Type != null && SubType != null) {
                RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = :RecordTypeName LIMIT 1];
                newCase.RecordTypeId = rt.Id;
                newCase.Sub_Type__c = Type;
                newCase.Sub_Sub_Type__c = SubType;
                newCase.AccountId = recId;
                newCase.Subject = Subjt;
                newCase.Status = 'New';
                newCase.Description = Description;
                newCase.Category__c = Category;
                newCase.OrderId__c = OrderId;
                
                insert newCase;
                System.debug('newCase.Subject ::'+newCase.Subject +'  newCase.Status  :'+ newCase.Status + 'newCase.Description::::::::' + newCase.Description +'newCase.Category__c::::::::::::' +newCase.Category__c );
                
                return newCase;
            } 
        } catch (Exception e) {
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }return null;
    }
    
    @AuraEnabled
    public static string returnToOrigin(String recId, String reasonForRto, String rtoResolution){
        System.debug('recId  == >'+recId +'  reasonForRto === >>'+ reasonForRto + 'rtoResolution ===>' +rtoResolution);
        try {
            List<User> CsTeamUserList = [SELECT Id,Name,Profile.Name,Email From User Where Profile.Name =:'Customer Service Executive' AND Name Like '%Aisha%' LIMIT 1];
            Case cs = new Case();
            cs.RTO_Reso__c = rtoResolution;
            cs.Reason_for_RTO__c = reasonForRto;
            cs.Id = recId;
            cs.OwnerId = CsTeamUserList[0].Id;
            update cs;
            System.debug('Update CS   ==>'+cs );
            
            List<Case> csList = [SELECT Id,OrderId__c,ContactId,CreatedDate,OwnerId,AccountId,Reason_for_RTO__c From Case Where Id=: recId LIMIT 1];
            System.debug('csList 1  ==>'+csList );
            
            set<Id> setOfOrderId = new set<Id>();
            set<Id> setOfContact = new set<Id>();
            set<Id> setOfAccount = new set<Id>();
            for(case cse : csList){
                if(cse.AccountId != null){
                    setOfAccount.add(cse.AccountId);
                }else if(cse.ContactId != null){
                    setOfContact.add(cse.ContactId);
                }
                if(cse.OrderId__c != null){
                    setOfOrderId.add(cse.OrderId__c);
                }
            }
            
            List<Order> ListOfOrder = [SELECT Id,OrderNumber,Total_Amount__c,Refund_Amount__c,TotalAmount,Reason_for_RTO__c From Order Where Id IN: setOfOrderId LIMIT 1];
            
            List<Order> ordList = new List<Order>();
            for(Order ord : ListOfOrder){
                order updatingOrder = new order();
                updatingOrder.Id = ord.Id;
                updatingOrder.Refund_Amount__c = ord.Refund_Amount__c;
                updatingOrder.Total_Amount__c = ord.TotalAmount;
                updatingOrder.Reason_for_RTO__c = reasonForRto;
                ordList.add(updatingOrder);
            }
            if(ordList.size() > 0){
                update ordList;
            }
            System.debug('cs ::'+cs +'  csList:::::>'+ csList + 'ListOfOrder::::::::' +ListOfOrder );
            List<OrderItem> OrderItemList = [SELECT Id,OrderId,TotalPrice,Refund_Price__c From OrderItem  Where OrderId IN: setOfOrderId];
            if(OrderItemList.size()>0){
                List<OrderItem> ordItmList = new List<OrderItem>();
                for(OrderItem ordItm : OrderItemList){
                    OrderItem orIt = new OrderItem();
                    orIt.Refund_Reason__c = reasonForRto;
                    orIt.Id = ordItm.Id;
                    orIt.Reason_for_RTO__c = reasonForRto;
                    orIt.Refund_Price__c = ordItm.TotalPrice;
                    ordItmList.add(orIt);
                }
                if(ordItmList.size() > 0){
                    update ordItmList;
                    System.debug('Updated  ordItmList == >'+ordItmList );
                }
            }else{
                system.debug(' OrderItemList is Empty ');
            }
            
            system.debug(' CsTeamUserList  == > '+CsTeamUserList);
            
            set<String> CsTeamUsers = new set<String>();
            List<String> CsTeamUsersInList = new List<String>();
            List<Id> CsteamTaskUsers = new List<Id>();
            
            for(User usr : CsTeamUserList){
                CsTeamUsers.add(usr.Id);
                CsTeamUsersInList.add(usr.Email);
                CsteamTaskUsers.add(usr.id);
            }
            
            
            List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='custom_notification_to_refund_team_on_pincode_not_serviceable'];
            
            List<String> emailString1 = new List<String>();
            Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
            Map<Id,Account> mapOfAccount = new Map<Id,Account>();
            
            List<Contact> conList =[SELECT Id,Name,Email From Contact Where Id IN:setOfContact];
            List<Account> accList =[SELECT Id,Name,Email__c From Account Where Id IN:setOfAccount];
            
            EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'ReturnToOriginForCustomer'];
            EmailTemplate Reftemp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'ReturnToOriginForRefundTeam'];
            OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='refund team'];
            
            System.debug('conList ::'+conList +'  TemplateInfoDetail:::::>'+ TemplateInfoDetail + 'temp::::::::' +temp +'Reftemp:::::>'+Reftemp +'  owea:::::>'+ owea );
            Map<Id,Order> mapOfOrd = new Map<Id,Order>();
            List<Order> orderList = [SELECT Id,CreatedDate,OrderNumber,Refund_Amount__c From Order Where Id IN:setOfOrderId];
            for(Order ord : orderList){
                if(!mapOfOrd.containsKey(ord.Id)){
                    mapOfOrd.put(Ord.Id,Ord);
                }
            }
            
            for(Contact con : conList){
                mapOfContact.put(con.Id, con);
            }
            for(Account acc : accList){
                mapOfAccount.put(acc.Id, acc);
            }
            System.debug('conList ::'+conList +'  TemplateInfoDetail:::::>'+ TemplateInfoDetail + 'temp::::::::' +temp +'Reftemp:::::>'+Reftemp +'  owea:::::>'+ owea +'mapOfOrd::::>'+mapOfOrd + 'mapOfContact::::::::>'+mapOfContact);
            List<String> emailString = new List<String>();
            
            List<task> taskList = new List<task>();
            String body = temp.body;
            String body1 = Reftemp.body;
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> mailListToRefundTeam = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> mailListToCsTeam = new List<Messaging.SingleEmailMessage>();
            for (Case cse : csList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.SingleEmailMessage mailToRefundUser = new Messaging.SingleEmailMessage();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                Messaging.CustomNotification WareHouseNotification = new Messaging.CustomNotification();
                
                if (cse.OrderId__c != null) {
                    Body = Body.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                }
                if(mapOfOrd.get(cse.OrderId__c).Refund_Amount__c != null){
                    body1 = body1.replace('{!Case.Order__r}', String.valueOf(mapOfOrd.get(cse.OrderId__c).Refund_Amount__c));
                }
                
                if (cse.Reason_for_RTO__c != null) {
                    Body = Body.replace('{!Case.Reason_for_RTO__c}', cse.Reason_for_RTO__c);
                }
                
                if (cse.OrderId__c != null) {
                    body1 = body1.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                }if(mapOfOrd.get(cse.OrderId__c).Refund_Amount__c != null){
                    body1 = body1.replace('{!Case.Order__r}', String.valueOf(mapOfOrd.get(cse.OrderId__c).Refund_Amount__c));
                }
                
                if (cse.Reason_for_RTO__c != null) {
                    body1 = body1.replace('{!Case.Reason_for_RTO__c}', cse.Reason_for_RTO__c);
                }
                // if(mapOfAccount.get(cse.AccountId).Email__c != null){
                //     emailString.add(mapOfAccount.get(cse.AccountId).Email__c);
                // }
                // else if(mapOfContact.get(cse.ContactId).Email != null){
                //     emailString.add(mapOfContact.get(cse.ContactId).Email);
                // }else if(cse.Email_Id__c != null){
                //     emailString.add(cse.Email_Id__c);
                // }
                
                // mail.setSubject(temp != null ? temp.Subject : '');
                // mail.setPlainTextBody(Body);
                // mail.setTemplateId(temp != null ? temp.Id : null);
                // mail.setSaveAsActivity(true);
                // mail.setWhatId(cse.Id);
                // //mail.setorgwideemailaddressid(owea.id);
                // mail.setToAddresses(emailString);
                // mailList.add(mail);
                
                mailToRefundUser.setSubject(Reftemp != null ? Reftemp.Subject : '');
                mailToRefundUser.setPlainTextBody(body1);
                mailToRefundUser.setTemplateId(Reftemp != null ? Reftemp.Id : null);
                mailToRefundUser.setSaveAsActivity(true);
                mailToRefundUser.setWhatId(cse.Id);
                //mailToRefundUser.setorgwideemailaddressid(owea.id);
                mailToRefundUser.setToAddresses(CsTeamUsersInList);
                mailListToCsTeam.add(mailToRefundUser);
                
                notification.setBody('Dear CS teams,Please Check For this Case As the Case is Returned To Origin'); 
                notification.setTitle('Return To Origin'); 
                notification.setSenderId(Userinfo.getUserId()); 
                notification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                notification.setTargetId(cse.id);
                notification.send(CsTeamUsers);
                
                task tsk = new task();
                tsk.subject ='Return To Origin';
                tsk.Priority = 'High';
                tsk.ActivityDate = System.today().addDays(2);
                tsk.whatId =   cse.Id;
                tsk.OwnerId = CsteamTaskUsers[0];
                taskList.add(tsk);
            }
            if(mailListToCsTeam.size()>0){
                Messaging.SendEmail(mailListToCsTeam);
            }
            //if(mailList.size()>0){
            //     Messaging.SendEmail(mailList);
            // }
            if(taskList.size()>0){
                Insert taskList;
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('e.getLineNumber::::::::::::>' + e.getLineNumber() + ' e.getMessage::::::>' + e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static createDupLicateWrapper showAllCaseData(String recId) {
        try {
            System.debug('recId before if==> ' + recId);
            if (String.isNotBlank(recId)) {
                System.debug('recId==> ' + recId);
                createDupLicateWrapper oosWr = new createDupLicateWrapper();
                //AND OrderId__r.OrderNumber != null AND Order_Date__c != null AND OrderId__r.OrderNumber != null
                Case caseRec = [SELECT Id, CaseNumber, OrderId__r.OrderNumber, OrderId__r.Status, OrderId__c, Order_Date__c, Status, ContactId, Reason_for_RTO__c,Contact.Email FROM Case WHERE Id = :recId  LIMIT 1 ];
                oosWr.caseRec = caseRec;
                if (caseRec.OrderId__c != null) {
                    List<OrderItem> oliList = [SELECT Id, Product2.Name, Quantity, TotalPrice, OrderID, OriginalOrderItemId, Is_Duplicate_Order__c, PricebookEntryId, Product2Id, ListPrice, UnitPrice, Refund_Quantity__c FROM OrderItem WHERE OrderID = :caseRec.OrderId__c];
                    if (!oliList.isEmpty()) {
                        oosWr.oliList = oliList;
                    }
                }
                System.debug('oosWr==> ' + oosWr);
                return oosWr;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
            return null;
        }
    }
    
    public class createDupLicateWrapper {
        @AuraEnabled
        public Case caseRec;
        @AuraEnabled
        public List<OrderItem> oliList;
    }
    
    @AuraEnabled
    public static String UpdateCaseRecord(String recId, String OrdId){
        try{
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.Id = recId;
            
            
            System.debug('cse=====> ' + lct);
            
            return 'SUCCESS';
        }catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static List<OrderItem> getAllRelatedOrderItems(String OrdId){
        try{
            return [SELECT Id, OrderItemNumber, SKU__c,Product_Name__c, UnitPrice, Description,Quantity FROM OrderItem WHERE OrderId = :OrdId];
        } catch(Exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
            return null;
        }
    }
    //     @AuraEnabled(cacheable=true)
    // public static Map<String, List<String>> getAllPickListVal(Map<String, String> ObjectByField){
    //     Map<String, List<String>> picklistValByField = new Map<String, List<String>>();
    //     for(String field : ObjectByField.keySet()){
    //         String objName = ObjectByField.get(field);
    //         System.debug('Object Name: ' + objName);
    //         List<String> picklistValues = getPicklistValuesList(objName, field);
    //         System.debug('Picklist Values for ' + field + ': ' + picklistValues);
    //         picklistValByField.put(field, picklistValues);
    //     }
    //     return picklistValByField;
    // }
    
      
    @AuraEnabled
    public static List<OrderItem> getOrderItems(String OrdId){
        system.debug('OrdId ===========>' +OrdId);
        List<OrderItem> orderItems = new List<OrderItem>(); // Define the list outside the try-catch block
        
        try {
            if (OrdId != null) {
                orderItems = [SELECT Id, Product2.Name, Quantity, Refund_Quantity__c, TotalPrice, Refund_Price__c, Refund_Reason__c, Refund_Reasons__c, Refund_Type__c, SKU__c, Total_Selling_Price__c, Selling_Price__c FROM OrderItem WHERE OrderId = :OrdId];
            }
        } catch (Exception e) {
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
            return null; // Return null if an exception occurs
        }
        
        return orderItems; // Return the list outside the try-catch block
    }
    
    
    @AuraEnabled
    public static String createCaseInLiveChatTranscript(String RecordTypeName, String Type, String SubType, String AccId, String conId, String Subjt, String conNumber, String recId, Id ownId) {
        system.debug('RecordTypeName ==> '+RecordTypeName + 'Type===>'+Type + 'SubType===>'+SubType+ 'AccId===>'+AccId+ 'conId===>'+conId+ 'Subjt===>'+Subjt +'conNumber===>'+conNumber+ 'recId===>'+recId+ 'ownId===>'+ownId);
        try {
            Case newCase = new Case();
            if (RecordTypeName != null && Type != null && SubType != null) {
                Set<Id> setOfOwnerId = new Set<Id>();
                List<Case> cseList = new List<Case>();
                RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = :RecordTypeName LIMIT 1];
                
                newCase.RecordTypeId = rt.Id;
                newCase.Sub_Type__c = Type;
                newCase.Sub_Sub_Type__c = SubType;
                
                if(AccId != null){
                    newCase.AccountId = AccId;
                }
                if(conId != null){
                    newCase.ContactId = conId;
                }
                if(Subjt != null){
                    newCase.Subject = Subjt;
                }
                if(AccId != null){
                    newCase.Contact_Number__c = conNumber;
                }
                
                newCase.Status = 'New';
                if(ownId != null){
                    newCase.OwnerId = ownId;
                }
                
                
                insert newCase;
                setOfOwnerId.add(newCase.OwnerId);
                cseList.add(newCase);
                System.debug('newCase:::::::::::>' + newCase);
                
                LiveChatTranscript LCTRec = new LiveChatTranscript(Id = recId, CaseId = newCase.Id);
                update LCTRec;
                System.debug('LCTRec:::::::::::>' + LCTRec);
                
                
                Set<String> setOfUserId = new Set<String>();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
                List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :setOfOwnerId];
                EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='child case creation'];
                Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                System.debug('userList:::::::::::>' + userList);
                for (User us : userList) {
                    setOfUserId.add(us.Id);
                }
                System.debug('setOfUserId:::::::::::>' + setOfUserId);
                
                User usr = [SELECT Id,Name,Email From User Where Id=:ownId ];
                // notification to user
                notification.setBody('A New Case Has been created. Please check the details.');
                notification.setTitle('Hi, A New Case Has been created.');
                notification.setSenderId(usr.Id);
                notification.setNotificationTypeId(customNotiList.Id); 
                notification.setTargetId(newCase.Id);
                // email to user
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                String body = temp.body;
                body = body.replace('{!Case.Id}',newCase.Id);
                mail.setPlainTextBody(body);
                mail.setTemplateId(temp.id);
                //mail.setTargetObjectId(newCase.Id);
                mail.setToAddresses(new List<String> {usr.Email});
                mailList.add(mail);
                
                System.debug('notification:::::::::::>' + notification);
                notification.send(new Set<String> { newCase.OwnerId });
                Messaging.sendEmail(mailList);
                
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static String createCaseFromContact(String RecordTypeName, String Type, String SubType, String Subjt, String conNumber, String recId, String ordId) {
        system.debug('RecordTypeName ==> '+RecordTypeName + 'Type===>'+Type + 'SubType===>'+SubType+ 'Subjt===>'+Subjt +'conNumber===>'+conNumber+ 'recId===>'+recId);        
        try {

           Contact con = [SELECT Id,Name,AccountId From Contact Where Id =: recId];
           system.debug('ContactAccountId===============>'+ con.AccountId );

            Case newCase = new Case();
            if (RecordTypeName != null && Type != null && SubType != null) {
                Set<Id> setOfOwnerId = new Set<Id>();
                List<Case> cseList = new List<Case>();
                RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = :RecordTypeName LIMIT 1];

                
                newCase.RecordTypeId = rt.Id;
                newCase.Sub_Type__c = Type;
                newCase.Sub_Sub_Type__c = SubType;

                if(ordId != null){
                    newCase.OrderId__c = ordId;
                   
                }
              
                if(con.AccountId != null){
                    newCase.AccountId = con.AccountId;
                }
                if(Subjt != null){
                    newCase.Subject = Subjt;
                }
                if(conNumber != null){
                    newCase.Contact_Number__c = conNumber;
                }
                if(recId != null){
                    newCase.contactId = recId;
                }

                newCase.Status = 'New';
                newCase.OwnerId = UserInfo.getUserId();
                            
                
                insert newCase;
                system.debug('newCaseId==============> '+ newCase.Id);
                system.debug('Order_SKU_details__c===============>'+ newCase.OwnerId);

                
                update newCase;
                setOfOwnerId.add(newCase.OwnerId);
                cseList.add(newCase);
                System.debug('newCase:::::::::::>' + newCase);
                
 
                Set<String> setOfUserId = new Set<String>();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
                List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :setOfOwnerId];
                EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='child case creation'];
                Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                System.debug('userList:::::::::::>' + userList);
                for (User us : userList) {
                    setOfUserId.add(us.Id);
                }
                System.debug('setOfUserId:::::::::::>' + setOfUserId);
                
                User usr = [SELECT Id,Name,Email From User Where Id=: newCase.OwnerId];
                // notification to user
                notification.setBody('A New Case Has been created. Please check the details.');
                notification.setTitle('Hi, A New Case Has been created.');
                notification.setSenderId(usr.Id);
                notification.setNotificationTypeId(customNotiList.Id); 
                notification.setTargetId(newCase.Id);
                // email to user
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                String body = temp.body;
                body = body.replace('{!Case.Id}',newCase.Id);
                mail.setPlainTextBody(body);
                mail.setTemplateId(temp.id);
                //mail.setTargetObjectId(newCase.Id);
                mail.setToAddresses(new List<String> {usr.Email});
                mailList.add(mail);
                
                System.debug('notification:::::::::::>' + notification);
                notification.send(new Set<String> { newCase.OwnerId });
                Messaging.sendEmail(mailList);
                
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static String createCaseFromAccount(String RecordTypeName, String Type, String SubType, String Subjt, String conNumber, String recId, String ordId) {
        system.debug('RecordTypeName ==> '+RecordTypeName + 'Type===>'+Type + 'SubType===>'+SubType+ 'Subjt===>'+Subjt +'conNumber===>'+conNumber+ 'recId===>'+recId);
        try {
            Case newCase = new Case();
            if (RecordTypeName != null && Type != null && SubType != null) {
                Set<Id> setOfOwnerId = new Set<Id>();
                List<Case> cseList = new List<Case>();
                RecordType rt = [SELECT Id FROM RecordType WHERE Name = :RecordTypeName LIMIT 1];
                
                newCase.RecordTypeId = rt.Id;
                newCase.Sub_Type__c = Type;
                newCase.Sub_Sub_Type__c = SubType;

                
                if(ordId != null){
                    newCase.OrderId__c = ordId;
                }
                
                if(Subjt != null){
                    newCase.Subject = Subjt;
                }
                if(conNumber != null){
                    newCase.Contact_Number__c = conNumber;
                }
                
                newCase.Status = 'New';
                newCase.OwnerId = UserInfo.getUserId();
                
                
                
                insert newCase;
                system.debug('newCaseId==============> '+ newCase.Id);
                system.debug('Order_SKU_details__c===============>'+ newCase.OwnerId);

                if(recId != null){
                    newCase.AccountId = recId;
                }
                update newCase;
                setOfOwnerId.add(newCase.OwnerId);
                cseList.add(newCase);
                System.debug('newCase:::::::::::>' + newCase);
                
 
                Set<String> setOfUserId = new Set<String>();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
                List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :setOfOwnerId];
                EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='child case creation'];
                Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                System.debug('userList:::::::::::>' + userList);
                for (User us : userList) {
                    setOfUserId.add(us.Id);
                }
                System.debug('setOfUserId:::::::::::>' + setOfUserId);
                
                User usr = [SELECT Id,Name,Email From User Where Id=:newCase.OwnerId ];
                // notification to user
                notification.setBody('A New Case Has been created. Please check the details.');
                notification.setTitle('Hi, A New Case Has been created.');
                notification.setSenderId(usr.Id);
                notification.setNotificationTypeId(customNotiList.Id); 
                notification.setTargetId(newCase.Id);
                // email to user
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                String body = temp.body;
                body = body.replace('{!Case.Id}',newCase.Id);
                mail.setPlainTextBody(body);
                mail.setTemplateId(temp.id);
                //mail.setTargetObjectId(newCase.Id);
                mail.setToAddresses(new List<String> {usr.Email});
                mailList.add(mail);
                
                System.debug('notification:::::::::::>' + notification);
                notification.send(new Set<String> { newCase.OwnerId });
                Messaging.sendEmail(mailList);
                
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<String> getCaseFieldSetListForCourierIssue(){
        try{
            List<String> caseFieldSetList = new List<String>();
            List<Schema.FieldSetMember> FieldSetListFromCase  = SobjectType.Case.FieldSets.courierIssue.getFields();
            for(Schema.FieldSetMember fieldsToAdd : FieldSetListFromCase){
                System.debug('Fields === >'+String.valueOf(fieldsToAdd.sobjectfield));
                caseFieldSetList.add(String.valueOf(fieldsToAdd.sobjectfield));
            }
            if(caseFieldSetList.size()>0){
                return caseFieldSetList;
            }
        }catch(Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }

   @AuraEnabled
   public static List<OrderItem> getOrderIfItHasLineItems(String recId){
        try {
            if(recId != null){
                Case cserec = [SELECT Id,OrderId__c From Case Where Id=:recId ];

                return [SELECT Id,SKU__C,OrderId,product2.Name,product2Id,Order.Name,Order.OrderNumber From OrderItem  Where OrderId =: cserec.OrderId__c];
            }
        
        } catch (Exception e) {
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
   }

   @AuraEnabled
    public static String updateSKUdetailsAndCreateRecordOfSKU( String recId,String ordId, List<Id> ordLinItmList) {
        system.debug('recId===>'+recId+ 'ordId========>'+ordId);
        system.debug('ordLinItmList==============>'+ordLinItmList);
        try {
            List<String> skuString = new List<String>();
            if(ordLinItmList.Size()>0){
                List<OrderItem> ordList = [SELECT Id,SKU__c From OrderItem Where Id IN:ordLinItmList ];
                
                for(OrderItem itemRec : ordList){
                    skuString.add(itemRec.SKU__c);
                }
            }
            
           

            // Create a comma-separated string from the SKU values
            String commaSeparatedSKUs = String.join(skuString, ',');

            Case newCase = new Case();
            if (recId != null ) {

                if(skuString.size()>0){
                    newCase.Order_SKU_details__c = commaSeparatedSKUs;
                }
                if(ordId != null){
                    newCase.OrderId__c = ordId;
                }
                    newCase.Id = recId;
                
                
                update newCase;
                system.debug('newCase.Order_SKU_details__c==============>'+newCase.Order_SKU_details__c);

                
                    List<String> splitSKUs = newCase.Order_SKU_details__c.split(',');
                    system.debug('splitSKUs==============>'+splitSKUs);
                
                

                // Create a list to store the Affected_SKU__c records
                List<Affected_SKU__c> affectedSKUsList = new List<Affected_SKU__c>();

                // Iterate over the split SKUs and create Affected_SKU__c records
              if(splitSKUs.size()>0){
                for (String sku : splitSKUs) {
                    Affected_SKU__c affectedSKU = new Affected_SKU__c();
                    affectedSKU.Name = sku;
                    affectedSKU.Case__c = recId;
                    // Add other fields as needed for the Affected_SKU__c object
                    affectedSKUsList.add(affectedSKU);
                }
              }

                // Insert the list of Affected_SKU__c records
                insert affectedSKUsList;
              system.debug('affectedSKUsList==============>'+affectedSKUsList);
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }
}