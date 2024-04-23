public class RefundController {
    @AuraEnabled
    public static Case getCaseById(String caseId) {
        System.debug('caseId====>'+caseId);
        Case casesRec = [SELECT Id, CaseNumber, Account.Name, OrderId__c,OrderId__r.OrderNumber,Subject, RecordType.Name,CreatedBy.Name, Case_Sub_Status__c FROM Case WHERE Id = :caseId LIMIT 1];
        System.debug('casesRec === >'+casesRec);
        return casesRec;
    }
    
    // @AuraEnabled(cacheable=true)
    @AuraEnabled
    public static List<User> getUsersByProfileName() {
        System.debug('Fetching users with Profile Name: Customer Service Executive');
        List<User> users = [SELECT Id, Name FROM User WHERE Profile.Name = 'Customer Service Executive'];       
        System.debug('users=====>'+users);
        return users;
    }

    @AuraEnabled
    public static String userUpdate(String recordId, String UserName) {
        try {
            Set<Id> setOfOwnerId = new Set<Id>();
            Set<Id> setOfCaseId = new Set<Id>();
            
            Case cs = new Case();
            cs.Id = recordId;
            cs.OwnerId = UserName;
            cs.Case_Sub_Status__c = 'Assigned to CS Team';
            cs.Status='In Progress';
            update cs;
            
            setOfOwnerId.add(cs.OwnerId);
            setOfCaseId.add(cs.Id);
            
            List<Case> caseList = [SELECT Id, Email_Id__c, OwnerId, AccountId, ContactId, contact.email, CreatedDate, CaseNumber FROM Case WHERE Id IN :setOfCaseId];
            
            Map<Id, Contact> mapOfContact = new Map<Id, Contact>();
            Map<Id, Account> mapOfAccount = new Map<Id, Account>();
            Set<Id> setOfContactId = new Set<Id>();
            Set<Id> setOfAccountId = new Set<Id>();
            
            for (Case cse : caseList) {
                setOfContactId.add(cse.ContactId);
                setOfAccountId.add(cse.AccountId);
            }
            
            if (!setOfContactId.isEmpty()) {
                for (Contact con : [SELECT Id, Name, Phone, Email FROM Contact WHERE Id IN :setOfContactId]) {
                    mapOfContact.put(con.Id, con);
                }
            }
            
            if (!setOfAccountId.isEmpty()) {
                for (Account acc : [SELECT Id, Name, Email__c FROM Account WHERE Id IN :setOfAccountId]) {
                    mapOfAccount.put(acc.Id, acc);
                }
            }
            
            List<User> userList = [SELECT Id, Name, email FROM User WHERE Id IN :setOfOwnerId];
            Set<String> CSTeamUsers = new Set<String>();
            List<String> CSTeamUserEmail = new List<String>();
            List<Id> CsTeamTaskUsers = new List<Id>();
            
            for (User usr : userList) {
                CSTeamUsers.add(usr.Id);
                CsTeamTaskUsers.add(usr.Id);
                CSTeamUserEmail.add(usr.email);
            }
            
            EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'email_to_customer_on_CS_team_Clone'];
            List<CustomNotificationType> TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Assign_To_Cs_Team'];
            
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
            
            for (Case cse : caseList) {
                String body = temp.Body;
                
                if (cse.AccountId != null && mapOfAccount.containsKey(cse.AccountId)) {
                    body = body.replace('{!Account.Name}', mapOfAccount.get(cse.AccountId).Name);
                } else if (cse.ContactId != null && mapOfContact.containsKey(cse.ContactId)) {
                    body = body.replace('{!Account.Name}', mapOfContact.get(cse.ContactId).Name);
                } else {
                    body = body.replace('{!Account.Name}', 'Customer');
                }
                
                if (cse.CaseNumber != null) {
                    body = body.replace('{!Case.CaseNumber}', String.valueOf(cse.CaseNumber));
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(temp != null ? temp.Subject : '');
                mail.setPlainTextBody(body);
                mail.setTemplateId(temp != null ? temp.Id : null);
                mail.setSaveAsActivity(true);
                mail.setWhatId(cse.Id);
                mail.setToAddresses(CSTeamUserEmail);
                mailList.add(mail);
                
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody('A new Case has been Assigned to you. Please go through it and resolve it ASAP');
                notification.setTitle('A case has been assigned');
                notification.setSenderId(UserInfo.getUserId());
                notification.setNotificationTypeId(TemplateInfoDetail[0].Id);
                notification.setTargetId(cse.Id);
                Notification.send(new Set<String> {cse.OwnerId}); 
                
                Task tsk = new Task();
                tsk.Subject = 'Resolve the Case as early as Possible';
                tsk.Priority = 'High';
                tsk.ActivityDate = System.today().addDays(2);
                tsk.WhatId = cse.Id;
                tsk.OwnerId = CsTeamTaskUsers[0];
                insert tsk;
            }
            
            if (!mailList.isEmpty()) {
                Messaging.sendEmail(mailList);
            }
            
            
            
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error ==> ' + e.getMessage() + ' && Error Line ==> ' + e.getLineNumber());
            return null;
        }
    }
    
    
}