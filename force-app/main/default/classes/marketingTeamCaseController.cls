public without sharing class marketingTeamCaseController {

    @AuraEnabled
    public Static Case marketingTeamCase(String recId) {
        return [SELECT Id, CaseNumber, Account.Name, OrderId__c,OrderId__r.OrderNumber,Subject,MT_Assignment_Reason__c,MT_Assignment_Remarks__c, RecordType.Name,CreatedBy.Name, Sub_Type__c, Sub_Sub_Type__c FROM Case WHERE Id = :recId LIMIT 1];
       
        
    }
    @AuraEnabled
    public static List<User> getUsersByProfileName() {
        List<User> users = [SELECT Id, Name FROM User WHERE Profile.Name = 'Marketing Team'];       
        System.debug('users=====>'+users);
        return users;
    }

    @AuraEnabled
    public static String userUpdate(String recId, String UserName, String MarketingReason) {
        System.debug('recId=====>' + recId);
        System.debug('UserName=====>' + UserName);
        System.debug('MarketingReason=====>' + MarketingReason);
        try {
            Set<Id> setOfOwnerId = new Set<Id>();
            List<Case> caseList1 = [SELECT Id, OwnerId, Owner.Email, Owner.Name, ContactId, Contact.Email, CreatedDate, CaseNumber, CS_Team_Member__c FROM Case WHERE Id =:recId];
            Case cs = new Case();
            if(!caseList1.isEmpty()){
                cs = caseList1[0];
            }
            if(cs.CS_Team_Member__c == null){
                cs.CS_Team_Member__c = cs.OwnerId;
            }
            String CSteamId = cs.CS_Team_Member__c;
            //cs.Marketing_Team__c = UserName;
            cs.OwnerId = UserName;
            cs.MT_Assignment_Reason__c = MarketingReason;
            cs.Marketing__c = true;
            cs.Status = 'In Progress';
            cs.Case_Sub_Status__c = 'Assigned to Marketing Team';
            update cs;
            System.debug('cs ==>'+cs);
        
            setOfOwnerId.add(caseList1[0].OwnerId);
            System.debug('caseList=====>' + caseList1);

            List<CaseShare> existingShares = [SELECT Id FROM CaseShare WHERE CaseId = :cs.Id AND UserOrGroupId = :CSteamId];
                System.debug('existingShares======>'+existingShares);

                if(!existingShares.isEmpty()){
                    //delete existingShares;
                    System.debug('existingShares delete records======>'+existingShares);
                }else{
                    CaseShare newCaseShare = new CaseShare();
                    newCaseShare.CaseId =  cs.Id;    //caseRecord.Id;
                    //System.debug('caseId=======>'+caseId);      
                    newCaseShare.UserOrGroupId = CSteamId;
                    //System.debug('CSteamId=====>'+CSteamId);
                    newCaseShare.CaseAccessLevel = 'Edit';
                    //newCaseShare.RowCause = Schema.CaseShare.RowCause.Manual;
                    insert newCaseShare;
                    System.debug('newCaseShare======>'+newCaseShare);
                }
    
            Map<Id, Contact> mapOfContact = new Map<Id, Contact>();
            Set<Id> setOfContactId = new Set<Id>();
            if (!caseList1.isEmpty()) {
                for (Case cse : caseList1) {
                    setOfContactId.add(cse.ContactId);
                }
            }
            System.debug('setOfContactId ==>'+setOfContactId);
            List<Contact> conlist = [SELECT Id, Name, Phone, Email FROM Contact WHERE Id IN :setOfContactId];
            System.debug('conlist=====>' + conlist);
            if (!conlist.isEmpty()) {
                for (Contact Con : conlist) {
                    mapOfContact.put(Con.Id, Con);
                }
            }
    
            List<User> useList = [SELECT Id, Name,Email FROM User WHERE Id IN :setOfOwnerId];
            System.debug('useList=====>' + useList);
            Set<String> marketingTeamUsers = new Set<String>();
            List<Id> marketingTeamTaskUsers = new List<Id>();
            for (User usr : useList) {
                marketingTeamUsers.add(usr.Id);
                marketingTeamTaskUsers.add(usr.Id);
            }
            System.debug('marketingTeamUsers=====>' + marketingTeamUsers);
            System.debug('marketingTeamTaskUsers=====>' + marketingTeamTaskUsers);
    
            EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'email_to_customer_on_marketing_team'];
            System.debug('temp=====>' + temp);
    
            List<CustomNotificationType> TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'custom_notification_to_refund_team_on_pincode_not_serviceable'];
            System.debug('TemplateInfoDetail=====>' + TemplateInfoDetail);
    
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            //List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
    
            String str = temp.HTMLValue;
            String body = temp.body;
            List<Task> taskList = new List<Task>();
            List<Case> caseListToBeUpdated = new List<Case>();
            List<String> emailString = new List<String>();
            for (Case cse : caseList1) {
    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
    
                if (cse.Owner.Name != null) {
                    body = body.replace('{!Case.Contact}', cse.Owner.Name);
                }
                if (cse.ContactId != null) {
                    body = body.replace('{!Case.Contact}', mapOfContact.get(cse.ContactId).Name);
                }
                if (cse.CaseNumber != null) {
                    body = body.replace('{!Case.CaseNumber}', String.ValueOf(cse.CaseNumber));
                }
    
                emailString.add(cse.Owner.Email);
                System.debug('emailString===>' + emailString);
                mail.setSubject(temp != null ? temp.Subject : '');
                mail.setPlainTextBody(body);
                mail.setTemplateId(temp != null ? temp.Id : null);
                mail.setSaveAsActivity(true);
                mail.setWhatId(cse.Id);
                mail.setToAddresses(emailString);
                mailList.add(mail);
    
                // notification.setBody('A new Case Has been Assigned to you Please go through it and resolve it ASAP');
                // notification.setTitle('Assigned To Marketing Team');
                // notification.setSenderId(UserInfo.getUserId());
                // notification.setNotificationTypeId(TemplateInfoDetail[0].Id);
                // notification.setTargetId(cse.Id);
                // notification.send(marketingTeamUsers);
    
                Task tsk = new Task();
                tsk.Subject = 'Resolve the Case as early as Possible';
                tsk.Priority = 'High';
                tsk.ActivityDate = System.today().addDays(2);
                tsk.WhatId = cse.Id;
                tsk.OwnerId = marketingTeamTaskUsers[0];
                taskList.add(tsk);
                System.debug('tsk ==>'+tsk);
            }
            Insert taskList;
            if (!mailList.isEmpty()) {
                Messaging.sendEmail(mailList);
            }
    
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error == >' + e.getMessage() + ' && Error Line == >' + e.getLineNumber());
        }
        return null;
    }
    
}