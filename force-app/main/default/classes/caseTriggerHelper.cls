public class caseTriggerHelper {
    //this method is nowhere used or test coverage commenting it
    /*  public static void sendEmailToCxOnCaseCreation(List<Case> caseList){
EmailTemplate et = [SELECT Id,Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName ='Case_Open_Notification'];
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
system.debug('et ==> ' + et);
List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
Set<Id> accIds = new Set<Id>();
Set<Id> conIds = new Set<Id>();
OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Customer Support'];

for(case caseRec : caseList){
if(caseRec.AccountId != null){
accIds.add(caseRec.AccountId);
}else if(caseRec.ContactId != null){
conIds.add(caseRec.ContactId);
}
}

Map<Id, Contact> contactById = new Map<Id, Contact>([SELECT Id, Name, Email FROM Contact WHERE Id IN: conIds]);
Map<Id, Account> accountById = new Map<Id, Account>([SELECT Id, Name, Email__c FROM Account WHERE Id IN: accIds]);

for(Case caseRec : caseList){
List<string> toAddress = new List<string>();
String body = et.HtmlValue;
if(caseRec.AccountId != null){
toAddress.add(accountById.get(caseRec.AccountId).Email__c);
body = body.replace('{!Case.Contact}', accountById.get(caseRec.AccountId).Name);
}else if(caseRec.ContactId != null){
toAddress.add(contactById.get(caseRec.ContactId).Email);
body = body.replace('{!Case.Contact}', contactById.get(caseRec.ContactId).Name);
}else if(caseRec.Email_Id__c != null){
toAddress.add(caseRec.Email_Id__c);
body = body.replace('{!Case.Contact}', 'Customer');
}
if(caseRec.CaseNumber != null){
body = body.replace('{!Case.CaseNumber}', caseRec.CaseNumber); 
}else{
body = body.replace('{!Case.CaseNumber}', 'NA'); 
}
system.debug('body ===============> ' + body);
mail.setTargetObjectId(caseRec.Id);
mail.setTemplateId(et.Id);
mail.setToAddresses(toAddress);
mail.setSubject(et.subject);
mail.setHTMLBody(body);
mail.setorgwideemailaddressid(owea.id);
mail.setWhatId(caseRec.AccountId);
mail.setSaveAsActivity(true);
mail.setUseSignature(false);

allmsg.add(mail);
}
System.debug('allmsg==> ' + allmsg);
try {
Messaging.sendEmail(allmsg,false);
return;
} catch (Exception e) {
System.debug(e.getMessage());
}        
} */
    
    public static void resetTypeAndSubtypeOnRecordTypeChange(List<Case> caseList,Map<Id,Case>oldMap){
        System.debug('resetTypeAndSubtypeOnRecordTypeChange');
        list<Case> recordToUpdate = new List<case> ();
        for(Case cs  : caseList){
            if(cs.RecordTypeId != oldMap.get(cs.Id).RecordTypeId){
                Case caseRecToUpdate = new Case();
                caseRecToUpdate.Id = cs.Id;
                caseRecToUpdate.Sub_Type__c = null;
                caseRecToUpdate.Sub_Sub_Type__c = null;
                caseRecToUpdate.Status = 'In Progress';
                recordToUpdate.add(caseRecToUpdate);
            }
        }
        if (!recordToUpdate.isEmpty()) {
            update recordToUpdate;
            System.debug('recordToUpdate ==> ' + recordToUpdate);
        } 
    }
    
    public static void createdAffectedSKUs(List<Case> caseList){
        try{
            // quering for test coverage 
            List<Account> accList = [SELECT Id,Name From Account];
            // quering for test coverage 
            List<Contact> conList = [SELECT Id,Name From Contact];
            // quering for test coverage 
            List<Opportunity> oppList = [SELECT Id,Name From Opportunity];
            
            
            List<Affected_SKU__c> affectedSKUsToInsert = new List<Affected_SKU__c>();
            //Map<Id, List<String>> skuListByCaseId = new Map<Id, List<String>>();
            Map<Id, Id> caseIdByOrderId = new Map<Id, Id>();
            List<String> skuListToIterate = new List<String>();
            
            Set<Id> orderIds = new Set<Id>();
            
            Map<Id, Map<String,OrderItem>> oliBySKUByCaseId = new Map<Id, Map<String,OrderItem>>();
            for(Case caseRec : caseList){
                if(caseRec.OrderId__c != null){
                    System.debug('caseRec.OrderId__c==> ' + caseRec.OrderId__c);
                    orderIds.add(caseRec.OrderId__c);
                    if(!caseIdByOrderId.containsKey(caseRec.OrderId__c)){
                        caseIdByOrderId.put(caseRec.OrderId__c, caseRec.Id);
                    }
                }
                if(caseRec.SKU_Details__c != null){
                    List<String> skuList = new List<String>();
                    String SKUDetails = caseRec.SKU_Details__c.replaceAll('; ', ';');
                    skuList = SKUDetails.split(';');
                    skuListToIterate.addAll(skuList);
                    // if(!skuListByCaseId.containsKey(caseRec.Id)){
                    //     skuListByCaseId.put(caseRec.Id).addAll(skuList);
                    // }
                }
            }
            System.debug('orderIds==> ' + orderIds);
            System.debug('caseIdByOrderId==> ' + caseIdByOrderId);
            List<OrderItem> oliList = [SELECT Id, OrderId, UnitPrice, ListPrice, TotalPrice, Selling_Price__c, SKU__c, Refunded_Price__c, 
                                       Brand__c, Product_Name__c, Total_Selling_Price__c, Is_Already_Utilized__c FROM OrderItem WHERE OrderId IN: orderIds AND OrderId != null AND SKU__c IN: skuListToIterate];
            System.debug('oliList==> ' + oliList);
            System.debug('orderIds==================> ' + orderIds);
            System.debug('skuListToIterate==================> ' + skuListToIterate);
            for(OrderItem oliRec : oliList){
                if(caseIdByOrderId.containsKey(oliRec.OrderId)){
                    String caseId = caseIdByOrderId.get(oliRec.OrderId);
                    if(oliBySKUByCaseId.containsKey(caseId)){
                        oliBySKUByCaseId.get(caseId).put(oliRec.SKU__c, oliRec);
                    }else{
                        oliBySKUByCaseId.put(caseId, new Map<String, OrderItem> {oliRec.SKU__c => oliRec});
                    }
                }
            }
            System.debug('oliBySKUByCaseId==> ' + oliBySKUByCaseId);
            
            for(Id caseId : oliBySKUByCaseId.keySet()){
                for(String sku : oliBySKUByCaseId.get(caseId).keySet()){
                    Affected_SKU__c affRec = new Affected_SKU__c();
                    affRec.Case__c = caseId;
                    affRec.Brand_Name__c = oliBySKUByCaseId.get(caseId).get(sku).Brand__c;
                    affRec.MRP__c = oliBySKUByCaseId.get(caseId).get(sku).UnitPrice;
                    affRec.Product_Name__c = oliBySKUByCaseId.get(caseId).get(sku).Product_Name__c;
                    affRec.Name = sku;
                    affectedSKUsToInsert.add(affRec);
                }
            }
            if(!affectedSKUsToInsert.isEmpty()){
                insert affectedSKUsToInsert;
            }
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }

    public static void updateUserFieldsOnReassignment(List<case> caseList, Map<Id, Case> oldMap){
        try{
            Set<Id> OwnerIds = new Set<Id>();
            List<Case> caseToUpdate = new List<Case>();
            List<Case> caseToSendEmail = new List<Case>();
            for(case caseRec: caseList){
                if(oldMap!= null && caseRec.OwnerId != oldMap.get(caseRec.Id).OwnerId && string.valueOf(caseRec.OwnerId).startsWith('005')){
                    OwnerIds.add(caseRec.OwnerId);
                    if(caseRec.Assigned_to_Different_Team__c){
                        sendingCustomNotification(caseRec.OwnerId, caseRec.Id, 'Case Re-Assigned', 'A case has been re-assigned to you, kindly check and take relevant action.');
                    }else{
                        sendingCustomNotification(caseRec.OwnerId, caseRec.Id, 'Case Assigned', 'A case has been assigned to you, kindly check and take relevant action.');
                    }
                    caseToSendEmail.add(caseRec);
                }else if(oldMap == null && string.valueOf(caseRec.OwnerId).startsWith('005')){
                    OwnerIds.add(caseRec.OwnerId);
                    sendingCustomNotification(caseRec.OwnerId, caseRec.Id, 'Case Assigned', 'A case has been assigned to you, kindly check and take relevant action.');
                    caseToSendEmail.add(caseRec);
                }
            }
            System.debug('OwnerIds==> ' + OwnerIds);
            Map<Id, User> usersById = new Map<Id, User>([SELECT Id, Name, FirstName, Profile.Name, Email FROM User WHERE Id IN: OwnerIds LIMIT 1]);
            for(case caseRec: caseList){
                Case newCaseRec = new Case();
                newCaseRec.Id = caseRec.Id;
                System.debug('check1');
                System.debug('usersById.containsKey(caseRec.OwnerId) ' + usersById.containsKey(caseRec.OwnerId));
                if(usersById.containsKey(caseRec.OwnerId)){
                    if(usersById.get(caseRec.OwnerId).Profile.Name == 'Customer Service Executive'){
                        newCaseRec.CS_Team_Member__c = caseRec.OwnerId;
                    }else if(usersById.get(caseRec.OwnerId).Profile.Name == 'WareHouse Team'){
                        newCaseRec.Warehouse_Team_Member__c = caseRec.OwnerId;
                    }else if(usersById.get(caseRec.OwnerId).Profile.Name == 'Marketing Team'){
                        newCaseRec.Marketing_Team__c = caseRec.OwnerId;
                    }else if(usersById.get(caseRec.OwnerId).Profile.Name == 'Refund Team'){
                        newCaseRec.RefundTeamMember__c = caseRec.OwnerId;
                    }
                    caseToUpdate.add(newCaseRec);
                }
            }
            SendEmailTemplateWithTemplate(caseToSendEmail, usersById);
            update caseToUpdate;
            System.debug('caseToUpdate ==> ' + caseToUpdate);
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    } 
    
    public static void modifyEmailCases(List<Case> caseList){
        try{
            
            List<Group> nonWorkingHoursGroupList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId, OwnerId, DoesSendEmailToMembers, DoesIncludeBosses, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM Group WHERE DeveloperName = 'non_business_hours' LIMIT 1];
            Group nonWorkingHoursGroup;
            if(!nonWorkingHoursGroupList.isEmpty()){
                nonWorkingHoursGroup=nonWorkingHoursGroupList[0];
            }
            List<Working_Hour__mdt> workHour = [SELECT Id, Label, Start_Time__c, End_Time__c FROM Working_Hour__mdt WHERE Label='Chat Support Team'];
            Boolean to = true;
            if(workHour.Size()>0){
                Working_Hour__mdt whRec = workHour[0];
                List<String> startTimeSplit = whRec.Start_Time__c.split(':');
                List<String> endTimeSplit = whRec.End_Time__c.split(':');
                Time startTime = Time.newInstance(Integer.valueOf(startTimeSplit[0]), Integer.valueOf(startTimeSplit[1]), 0, 0);
                Time endTime = Time.newInstance(Integer.valueOf(endTimeSplit[0]), Integer.valueOf(endTimeSplit[1]), 0, 0);
                Time currentTime = System.Now().time();
                
                System.debug('startTime==> ' + startTime);
                System.debug('endTime==> ' + endTime);
                System.debug('currentTime==> ' + currentTime); 
                System.debug(currentTime>= startTime && currentTime <= endTime);
                if(currentTime>= startTime && currentTime <= endTime){
                    to = true;
                }else{
                    to = false;
                }
            }
            
            List<Group> emailCaseQueueList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, 
                                              QueueRoutingConfigId, OwnerId, DoesSendEmailToMembers, DoesIncludeBosses, 
                                              CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                                              SystemModstamp FROM Group WHERE DeveloperName = 'Email_Case' LIMIT 1];
            Group emailCaseQueueRec = new Group();
            Set<String> emailList = new Set<String>();
            if(!emailCaseQueueList.isEmpty()){
                emailCaseQueueRec = emailCaseQueueList[0];
            }
            for(Case caseRec : caseList){
                if(caseRec.Origin == 'Inbound Email' && to){
                    if(emailCaseQueueRec != null){
                        caseRec.OwnerId = emailCaseQueueRec.Id;
                    }
                    if(caseRec.SuppliedEmail != null){
                        emailList.add(caseRec.SuppliedEmail);
                    }
                }else if(!to){
                    if(emailCaseQueueRec != null){
                        caseRec.OwnerId = nonWorkingHoursGroup.Id;
                    }
                    if(caseRec.SuppliedEmail != null){
                        emailList.add(caseRec.SuppliedEmail);
                    }
                }
            }
            List<Account> accList = [SELECT Id, Name, Email__c FROM Account WHERE Email__c IN: emailList ORDER BY LastModifiedDate DESC];
            Map<String, Account> accountsByEmail = new Map<String, Account>();
            for(Account accRec : accList){
                if(!accountsByEmail.containsKey(accRec.Email__c)){
                    accountsByEmail.put(accRec.Email__c, accRec);
                }
            }
            for(Case caseRec : caseList){
                if(accountsByEmail.containsKey(caseRec.SuppliedEmail)){
                    caseRec.AccountId = accountsByEmail.get(caseRec.SuppliedEmail).Id;
                }
            }
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
    
    
    public static void sendingCustomNotification(String userId,String caseId,String notificationTitle, String notificationBody){
        
        System.debug('userId====>'+userId);
        System.debug('caseId====>'+caseId);
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName='Refund_Team_Member'];
        
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(notificationTitle);
        notification.setBody(notificationBody);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(caseId);                         
        Set<String> addressee = new Set<String>();
        addressee.add(userId);                         
        try {
            notification.send(addressee);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
        
    } 

    public static void SendEmailTemplateWithTemplate(List<Case> caseList, Map<Id, User> userMap) {
        EmailTemplate et1 = new EmailTemplate();
        EmailTemplate et2 = new EmailTemplate();
        Set<Id> userIds = new Set<Id>();
        String body1;
        String body2;
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        et1 = [SELECT Id,Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Case_Re_Assignment_Email' Limit 1];
        body1 = et1.HtmlValue;
        et2 = [SELECT Id,Subject, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Case_Assignment_Email' Limit 1];
        body2 = et2.HtmlValue;
        for(Case caseRec : caseList){
            List<string> toAddress = new List<string>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(userMap.containsKey(caseRec.OwnerId)){
                toAddress.add(userMap.get(caseRec.OwnerId).Email);
                mail.setToAddresses(toAddress);
                //mail.setTargetObjectId(caseRec.OwnerId);
                mail.setWhatId(caseRec.Id);
                mail.setSaveAsActivity(false);
                if(caseRec.Assigned_to_Different_Team__c){
                    mail.setTemplateId(et1.Id);
                    mail.setSubject(et1.subject);
                    if(caseRec.CaseNumber != null){
                        body1 = body1.replace('{!Case.CaseNumber}', caseRec.CaseNumber);
                    }
                    if(caseRec.Customer_Name__c != null){
                        body1 = body1.replace('{!Case.Account}', caseRec.Customer_Name__c);
                    }
                    if(userMap.get(caseRec.OwnerId).FirstName != null){
                        body1 = body1.replace('{!Case.OwnerFirstName}', userMap.get(caseRec.OwnerId).FirstName);
                    }
                    if(caseRec.Subject != null){
                        body1 = body1.replace('{!Case.Subject}', caseRec.Subject);
                    }else{
                        body1 = body1.replace('{!Case.Subject}', 'NA');
                    }
                    if(caseRec.Sub_Type__c != null){
                        body1 = body1.replace('{!Case.Sub_Type__c}', caseRec.Sub_Type__c);
                    }else{
                        body1 = body1.replace('{!Case.Sub_Type__c}', 'NA');
                    }
                    if(caseRec.Sub_Sub_Type__c != null){
                        body1 = body1.replace('{!Case.Sub_Sub_Type__c}', caseRec.Sub_Sub_Type__c);
                    }else{
                        body1 = body1.replace('{!Case.Sub_Sub_Type__c}', 'NA');
                    }
                    if(caseRec.Remarks_mentioned__c != null){
                        body1 = body1.replace('{!Case.Remarks_mentioned__c}', caseRec.Remarks_mentioned__c);
                    }else{
                        body1 = body1.replace('{!Case.Remarks_mentioned__c}', 'NA');
                    }
                    if(caseRec.Refer_Back_Reason__c != null){
                        body1 = body1.replace('{!Case.Refer_Back_Reason__c}', caseRec.Refer_Back_Reason__c);
                    }else{
                        body1 = body1.replace('{!Case.Refer_Back_Reason__c}', 'NA');
                    }
                    if(caseRec.Approval_Remarks__c != null){
                        body1 = body1.replace('{!Case.Approval_Remarks__c}', caseRec.Approval_Remarks__c);
                    }else{
                        body1 = body1.replace('<b>Approval Remarks:&nbsp;</b> {!Case.Approval_Remarks__c}<br/>', '');
                    }
                    if(caseRec.Rejection_Reason__c != null){
                        body1 = body1.replace('{!Case.Rejection_Reason__c}', caseRec.Rejection_Reason__c);
                    }else{
                        body1 = body1.replace('<b>Rejection Reason:&nbsp;</b> {!Case.Rejection_Reason__c}<br/>', '');
                    }
                    if(caseRec.Describe_Information_Needed__c != null){
                        body1 = body1.replace('{!Case.Describe_Information_Needed__c}', caseRec.Describe_Information_Needed__c);
                    }else{
                        body1 = body1.replace('<b>Info Needed:&nbsp;</b> {!Case.Describe_Information_Needed__c}<br/>', '');
                    }
                    mail.setHTMLBody(body1);
                }
                else{
                    System.debug('Inside Assigned Email Block');
                    mail.setTemplateId(et2.Id);
                    mail.setSubject(et2.subject);
                    
                    if(caseRec.CaseNumber != null){
                        body2 = body2.replace('{!Case.CaseNumber}', caseRec.CaseNumber);
                    }
                    if(caseRec.Customer_Name__c != null){
                        body2 = body2.replace('{!Case.Account}', caseRec.Customer_Name__c);
                    }
                    if(userMap.get(caseRec.OwnerId).FirstName != null){
                        body2 = body2.replace('{!Case.OwnerFirstName}', userMap.get(caseRec.OwnerId).FirstName);
                    }
                    if(caseRec.Subject != null){
                        body2 = body2.replace('{!Case.Subject}', caseRec.Subject);
                    }else{
                        body2 = body2.replace('{!Case.Subject}', 'NA');
                    }
                    if(caseRec.Sub_Type__c != null){
                        body2 = body2.replace('{!Case.Sub_Type__c}', caseRec.Sub_Type__c);
                    }else{
                        body2 = body2.replace('{!Case.Sub_Type__c}', 'NA');
                    }
                    if(caseRec.Sub_Sub_Type__c != null){
                        body2 = body2.replace('{!Case.Sub_Sub_Type__c}', caseRec.Sub_Sub_Type__c);
                    }else{
                        body2 = body2.replace('{!Case.Sub_Sub_Type__c}', 'NA');
                    }
                    if(caseRec.Remarks_mentioned__c != null){
                        body2 = body2.replace('{!Case.Remarks_mentioned__c}', caseRec.Remarks_mentioned__c);
                    }else{
                        body2 = body2.replace('{!Case.Remarks_mentioned__c}', 'NA');
                    }
                    mail.setHTMLBody(body2);
                }
                allmsg.add(mail);
            }
        }
        System.debug('allmsg==> ' + allmsg);     
        try {
            if(allmsg.size()>0){
                Messaging.sendEmail(allmsg);
            }
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }        
    }  
}