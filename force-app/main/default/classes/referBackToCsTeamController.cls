public without sharing class referBackToCsTeamController {
    
    @AuraEnabled
    public static Case getCaseById(String caseId) {
        System.debug('caseId====>'+caseId);
        Case cases = [SELECT Id, Refer_Back_Reason__c, Refund_Amount__c, Approval_Remarks__c, 
                      Rejection_Remarks__c, Rejection_Reason__c, Describe_Information_Needed__c, 
                      OrderId__c, OrderId__r.Refund_Amount__c,ownerId  FROM Case  WHERE Id = :caseId LIMIT 1];
        System.debug(cases);
        return cases;
    }
    
    @AuraEnabled
    public static List<Case> getCaseAndOrderDetails(String caseId, String referBackReason,String approvalRemarks, String  rejectionReason,String describeInformationNeeded,Decimal orderRefundAmount) {
        System.debug('caseId====>' + caseId);
        System.debug('referBackReason ===>'+referBackReason);
        System.debug('approvalRemarks===>'+approvalRemarks);
        System.debug('rejectionReason===>'+rejectionReason);
        System.debug('describeInformationNeeded===>'+describeInformationNeeded);
        System.debug('orderRefundAmount===>'+orderRefundAmount);
        String currUserId = userInfo.getUserId();
        List<Case> updatedCases = new List<Case>();   
        
        try {
            if(String.isNotBlank(caseId)){
                Case caseRec = [SELECT Id, OwnerId, CS_Team_Member__c FROM Case WHERE Id=: caseId LIMIT 1]; //SELECT Id, OwnerId, User.ManagerId FROM Case WHERE Id = '500F300000DLFGLIA5'
                String OwnersId= caseRec.CS_Team_Member__c;
                List<User> userList = [SELECT Id,Email,Name From User Where Profile.Name = 'Customer Service Executive' AND Id=:OwnersId LIMIT 1];
                User userRec = new User();
                if(!userList.isEmpty()){
                    userRec = userList[0];
                }
                Case caseToUpdate = new Case();
                if(caseId != null){
                    caseToUpdate.id = caseId;
                }
                if(caseRec.CS_Team_Member__c != null){
                    caseToUpdate.OwnerId = caseRec.CS_Team_Member__c;
                }else{
                    caseToUpdate.OwnerId = userRec.Id;
                }
                if(referBackReason != null){
                    caseToUpdate.Refer_Back_Reason__c = referBackReason;
                }
                // if(refundAmount != null){
                // caseToUpdate.Refund_Amount__c = refundAmount;
                // }
                if(approvalRemarks != null){
                    caseToUpdate.Approval_Remarks__c = approvalRemarks;
                }
                // if(rejectionRemarks != null){
                // caseToUpdate.Rejection_Remarks__c = rejectionRemarks;
                // }
                if(rejectionReason != null){
                    caseToUpdate.Rejection_Reason__c = rejectionReason;
                }
                if(describeInformationNeeded != null){
                    caseToUpdate.Describe_Information_Needed__c = describeInformationNeeded;
                }
                // caseToUpdate.OrderId__c = orderId;
                
                if (caseToUpdate.OrderId__c != null && orderRefundAmount != null) {
                    caseToUpdate.OrderId__r.Refund_Amount__c = orderRefundAmount;
                }
                caseToUpdate.Case_Sub_Status__c = 'Referred Back to CS Team';
                update caseToUpdate;
                
                List<CaseShare> existingShares = [SELECT Id, UserOrGroup.Name FROM CaseShare WHERE CaseId = :caseToUpdate.Id AND UserOrGroupId = :currUserId];
                System.debug('existingShares======>'+existingShares);
                if(!existingShares.isEmpty()){
                    delete existingShares;
                }
                
                System.debug('Case record updated successfully===========>' + caseToUpdate);        
                updatedCases.add(caseToUpdate);
                
                // String ownerId = caseToUpdate.OwnerId;
                
                // System.debug('caseToUpdate.OwnerId=======>'+caseToUpdate.OwnerId);
                //list<string> emaillist=new List<string>{userRec.Email};
                //sendingCustomNotification(userRec.Id,caseId, 'Case Referred Back', 'Refund Team Member has assigned the case back to you, kindly take relevant actions',emaillist);
                //moveToRefundTeamController.sendingCustomNotification(caseToUpdate.OwnerId, caseToUpdate.Id, 'Case Referred Back', 'Refund Team Member has assigned the case back to you, kindly take relevant actions');
                
            }
            
            
        } catch (Exception e) {
            System.debug('Error updating Case record: ' + e.getMessage());
            system.debug('Exception Line Number--->'+e.getLineNumber());
        }
        return updatedCases;
    }
    
    // Method to delete CaseShare records associated with the given Case Id
    public static void deletecaseShares(String caseId){
        List<CaseShare> lscaseshare = [Select Id From CaseShare where Id =:caseId];
        if(!lscaseshare.isEmpty()){
            delete lscaseshare;
            System.debug('lscaseshare deleted sucessfully=====>'+lscaseshare);
        }
        else{
            System.debug('lscaseshare is empty=====>'+lscaseshare);
        }
    } 
    
    public static void sendingCustomNotification(String OwnerId,String caseId,String notificationTitle, String notificationBody,list<string> emaillist){
        System.debug('OwnerId=====>'+OwnerId);
        System.debug('caseId=====>'+caseId);
        System.debug('notificationTitle=====>'+notificationTitle);
        
        // Fetching the manager's UserId
        User ownerUser = [SELECT ManagerId FROM User WHERE Id = : ownerId LIMIT 1];
        String managerId = ownerUser.ManagerId;
        System.debug('managerId======>' + managerId);
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName='ReferBackToCsTeam'];
        System.debug('notificationType=====>'+notificationType);
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(notificationTitle);
        notification.setBody(notificationBody);
        
        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(caseId);
        
        Set<String> addressee = new Set<String>();
        addressee.add(OwnerId);
        //addressee.add(managerId);
        
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='Case Assigned to CS Team'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String body = temp.body;
        //body = body.replace('{!Case.Id}',newCase.Id);
        mail.setPlainTextBody(body);
        mail.setTemplateId(temp.id);
        mail.setWhatId(caseId);
        mail.setToAddresses(emaillist);
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.setSaveAsActivity(FALSE);
        mailList.add(mail);
        // Actually send the notification
        try {
            notification.send(addressee);
            Messaging.sendEmail(mailList);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    
   // We Dont use this method any where ==================================================>
   /*
    public static void sendEmailToUserAndNotificationToUserReasonForLostInTransit(List<Case> caseList, map<Id,Case> oldMapCase) {
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Lost_In_Transit_Clone'];
        System.debug('temp======>'+temp);
        EmailTemplate temp1 = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Incorrect_Addresses_Clone'];
        System.debug('temp1======>'+temp1);
        EmailTemplate temp2 = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Customer_Unreachable_Clone'];
        System.debug('temp1======>'+temp2);
        
        
        
        List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Lost_In_Transit'];
        System.debug('TemplateInfoDetail======>'+TemplateInfoDetail);
        
        Map<Id, List<String>> mapOfEmails = new Map<Id, List<String>>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
        
        
        set<Id> setOfAccId = new set<Id>();
        set<Id> setOfId = new set<Id>();
        set<Id> setOfOrderId = new set<Id>();
        
        
        for(case cs : caseList){
            setOfId.add(cs.contactId);
            System.debug('setOfId=======>'+setOfId);
            setOfAccId.add(cs.AccountId);
            setOfOrderId.add(cs.OrderId__c);
        }
        System.debug('setOfAccId=======>'+setOfAccId);
        
        List<User> userList = [SELECT Id,Name,Profile.Name From User Where Profile.Name =: 'Order Management Team'];
        System.debug('userList======>'+userList);
        
        set<String> orderTeamUsers = new set<String>();
        List<Id> OrderTeamTaskUsers = new List<Id>();
        for(User usr : userList){
            orderTeamUsers.add(usr.Id);
            System.debug('orderTeamUsers======>'+orderTeamUsers);
            OrderTeamTaskUsers.add(usr.Id);
        }
        System.debug('orderTeamUsers======>'+orderTeamUsers);
        System.debug('OrderTeamTaskUsers======>'+OrderTeamTaskUsers);
        
        List<User> userListForWareHouse = [SELECT Id,Name,Profile.Name From User Where Profile.Name =:'WareHouse Team'];
        System.debug('userListForWareHouse======>'+userListForWareHouse);
        
        set<String> WareHouseUsers = new set<String>();
        for(User usr : userListForWareHouse){
            WareHouseUsers.add(usr.Id);
            
        }
        
        
        List<String> emailString1 = new List<String>();
        List<decimal> ordNumber = new List<decimal>();
        Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
        Map<Id,Account> mapOfAccount = new Map<Id,Account>();
        
        List<Contact> conList =[SELECT Id,Name,Email From Contact Where Id IN:setOfId];
        System.debug('conList========>'+conList);
        List<Account> acclist = [Select Id,Name,Email__C From Account Where Id IN: setOfAccId];
        System.debug('acclist========>'+acclist);
        
        
        
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
        
        for(Account acc : acclist){
            mapOfAccount.put(acc.Id, acc);
        }
        
        List<String> emailString = new List<String>();
        
        List<task> taskList = new List<task>();
        for (Case cse : caseList) {
            
            if(cse.Reason_For_Dealy__c != oldMapCase.get(cse.Id).Reason_For_Dealy__c){
                if (cse.Reason_For_Dealy__c == 'Lost in Transit') {
                    if(cse.Reason_For_Dealy__c != null){
                        String str = temp.HTMLValue;
                        String body = temp.body;
                        System.debug('cse.Reason_For_Dealy__c=====>'+cse.Reason_For_Dealy__c);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        Messaging.CustomNotification WareHouseNotification = new Messaging.CustomNotification();
                        
                        if (cse.AccountId != null) {
                            System.debug('check 1');
                            System.debug('cse.AccountId==> ' + cse.AccountId);
                            Body = Body.replace('{!Account.Name}', mapOfAccount.get(cse.AccountId).Name);
                        }
                        
                        else if (cse.ContactId != null) {
                            Body = Body.replace('{!Account.Name}', mapOfContact.get(cse.ContactId).Name);
                        }
                        else {
                            System.debug('Hello Name'); 
                            Body = Body.replace('{!Account.Name}', 'Customer');  
                        }
                        // if (cse.OrderId__c != null) {
                        //     Body = Body.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                        // }
                        // if (cse.CreatedDate != null) {
                        //     Body = Body.replace('{!Case.CreatedDate}', String.ValueOf(cse.CreatedDate));
                        // }
                        // if (cse.Address_With_Pin_Code__PostalCode__s != null) {
                        //     Body = Body.replace('{!Case.Address_With_Pin_Code__c}', cse.Address_With_Pin_Code__PostalCode__s);
                        // }
                        // if (cse.Amount_Paid__c != null) {
                        //     Body = Body.replace('{!Case.Amount_Paid__c}', String.valueOf(cse.Amount_Paid__c));
                        // }
                        if(cse.ContactId !=null){
                            if(mapOfContact.get(cse.ContactId).Email != null){
                                emailString.add(mapOfContact.get(cse.ContactId).Email);
                            }
                        }
                        if (cse.AccountId != null){
                            if(mapOfAccount.get(cse.AccountId).Email__c != null){
                                emailString.add(mapOfAccount.get(cse.AccountId).Email__c);
                            }
                        }
                        mail.setSubject(temp != null ? temp.Subject : '');
                        mail.setPlainTextBody(Body);
                        //System.debug('setPlainTextBody====>'+setPlainTextBody);
                        System.debug('Body====>'+Body);
                        mail.setTemplateId(temp != null ? temp.Id : null);
                        mail.setSaveAsActivity(true);
                        mail.setWhatId(cse.Id);
                        mail.setToAddresses(emailString);
                        mailList.add(mail);
                        
                        notification.setBody('Dear orderTeamUsers, Please take a look of this Order Lost In Transit'); 
                        notification.setTitle('Lost In Transit'); 
                        notification.setSenderId(Userinfo.getUserId()); 
                        notification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                        notification.setTargetId(cse.id);
                        notification.send(orderTeamUsers);
                        system.debug('orderTeamUsers:::::::::>' + orderTeamUsers);
                        
                        
                        WareHouseNotification.setBody('Dear WareHouse, Please take a look of this Order Lost In Transit'); 
                        WareHouseNotification.setTitle('Lost In Transit'); 
                        WareHouseNotification.setSenderId(Userinfo.getUserId()); 
                        WareHouseNotification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                        WareHouseNotification.setTargetId(cse.id);
                        WareHouseNotification.send(WareHouseUsers);
                        system.debug('WareHouseNotification:::::::::>' + WareHouseNotification);
                        
                        task tsk = new task();
                        tsk.subject ='Lost In Transit';
                        tsk.Priority = 'High';
                        tsk.ActivityDate = System.today().addDays(2);
                        tsk.whatId =   cse.Id;
                        tsk.OwnerId = OrderTeamTaskUsers[0];
                        taskList.add(tsk);
                        
                    } 
                }
                
            } 
            if(cse.Reason_For_Dealy__c != oldMapCase.get(cse.Id).Reason_For_Dealy__c){
                if (cse.Reason_For_Dealy__c == 'Incorrect Addresses') {
                    if(cse.Reason_For_Dealy__c != null){
                        String str = temp1.HTMLValue;
                        String body = temp1.body;
                        System.debug('cse.Reason_For_Dealy__c 2nd =====>'+cse.Reason_For_Dealy__c);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        Messaging.CustomNotification WareHouseNotification = new Messaging.CustomNotification();
                        
                        if (cse.AccountId != null) {
                            System.debug('check 1');
                            System.debug('cse.AccountId==> ' + cse.AccountId);
                            Body = Body.replace('{!Account.Name}', mapOfAccount.get(cse.AccountId).Name);
                        }
                        
                        else if (cse.ContactId != null) {
                            Body = Body.replace('{!Account.Name}', mapOfContact.get(cse.ContactId).Name);
                        }
                        else {
                            System.debug('Hello Name'); 
                            Body = Body.replace('{!Account.Name}', 'Customer');  
                        }
                        // if (cse.OrderId__c != null) {
                        //     Body = Body.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                        // }
                        // if (cse.CreatedDate != null) {
                        //     Body = Body.replace('{!Case.CreatedDate}', String.ValueOf(cse.CreatedDate));
                        // }
                        // if (cse.Address_With_Pin_Code__PostalCode__s != null) {
                        //     Body = Body.replace('{!Case.Address_With_Pin_Code__c}', cse.Address_With_Pin_Code__PostalCode__s);
                        // }
                        // if (cse.Amount_Paid__c != null) {
                        //     Body = Body.replace('{!Case.Amount_Paid__c}', String.valueOf(cse.Amount_Paid__c));
                        // }
                        if(cse.ContactId !=null){
                            if(mapOfContact.get(cse.ContactId).Email != null){
                                emailString.add(mapOfContact.get(cse.ContactId).Email);
                            }
                        }
                        if (cse.AccountId != null){
                            if(mapOfAccount.get(cse.AccountId).Email__c != null){
                                emailString.add(mapOfAccount.get(cse.AccountId).Email__c);
                            }
                        }
                        mail.setPlainTextBody(Body);
                        system.debug('temp1--->'+temp1); 
                        mail.setTemplateId(temp1.Id);
                        mail.setSaveAsActivity(true);
                        mail.setWhatId(cse.Id);
                        mail.setToAddresses(emailString);
                        mailList.add(mail);
                        system.debug('mailList:::::::::>' + mailList);
                        system.debug('checking 2:::::::::>');
                        notification.setBody('Dear orderTeamUsers, Please take a look of this Order Incorrect Addresses'); 
                        notification.setTitle('Incorrect Addresses'); 
                        notification.setSenderId(Userinfo.getUserId()); 
                        notification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                        notification.setTargetId(cse.id);
                        notification.send(orderTeamUsers); 
                        system.debug('notification:::::::::>' + notification);
                        
                        
                        WareHouseNotification.setBody('Dear WareHouse, Please take a look of this Order Incorrect Addresses'); 
                        WareHouseNotification.setTitle('Incorrect Addresses'); 
                        WareHouseNotification.setSenderId(Userinfo.getUserId()); 
                        WareHouseNotification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                        WareHouseNotification.setTargetId(cse.id);
                        WareHouseNotification.send(WareHouseUsers);
                        system.debug('WareHouseNotification:::::::::>' + WareHouseNotification);
                        
                        task tsk = new task();
                        tsk.subject ='Incorrect Addresses';
                        tsk.Priority = 'High';
                        tsk.ActivityDate = System.today().addDays(2);
                        tsk.whatId =   cse.Id;
                        tsk.OwnerId = OrderTeamTaskUsers[0];
                        taskList.add(tsk);
                    }
                }
            }
            
            if(cse.Reason_For_Dealy__c != oldMapCase.get(cse.Id).Reason_For_Dealy__c){
                if (cse.Reason_For_Dealy__c == 'Customer Unreachable') {
                    if(cse.Reason_For_Dealy__c != null){
                        String str = temp2.HTMLValue;
                        String body = temp2.body;
                        System.debug('cse.Reason_For_Dealy__c 3rd =====>'+cse.Reason_For_Dealy__c);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        Messaging.CustomNotification WareHouseNotification = new Messaging.CustomNotification();
                        
                        if (cse.AccountId != null) {
                            System.debug('check 1');
                            System.debug('cse.AccountId==> ' + cse.AccountId);
                            Body = Body.replace('{!Account.Name}', mapOfAccount.get(cse.AccountId).Name);
                        }
                        
                        else if (cse.ContactId != null) {
                            Body = Body.replace('{!Account.Name}', mapOfContact.get(cse.ContactId).Name);
                        }
                        else {
                            System.debug('Hello Name'); 
                            Body = Body.replace('{!Account.Name}', 'Customer');  
                        }
                        // if (cse.CreatedDate != null) {
                        //     Body = Body.replace('{!Case.CreatedDate}', String.ValueOf(cse.CreatedDate));
                        // }
                        // if (cse.Address_With_Pin_Code__PostalCode__s != null) {
                        //     Body = Body.replace('{!Case.Address_With_Pin_Code__c}', cse.Address_With_Pin_Code__PostalCode__s);
                        // }
                        // if (cse.Amount_Paid__c != null) {
                        //     Body = Body.replace('{!Case.Amount_Paid__c}', String.valueOf(cse.Amount_Paid__c));
                        // }
                        if(cse.ContactId !=null){
                            if(mapOfContact.get(cse.ContactId).Email != null){
                                emailString.add(mapOfContact.get(cse.ContactId).Email);
                            }
                        }
                        if (cse.AccountId != null){
                            if(mapOfAccount.get(cse.AccountId).Email__c != null){
                                emailString.add(mapOfAccount.get(cse.AccountId).Email__c);
                            }
                        }
                        mail.setPlainTextBody(Body);
                        //System.debug('setPlainTextBody====>'+setPlainTextBody);
                        System.debug('Body====>'+Body);
                        mail.setTemplateId(temp2 != null ? temp2.Id : null);
                        mail.setSaveAsActivity(true);
                        mail.setWhatId(cse.Id);
                        mail.setToAddresses(emailString);
                        mailList.add(mail);
                        system.debug('mailList:::::::::>' + mailList);
                        
                        notification.setBody('Dear orderTeamUsers, Please take a look of this Order Customer Unreachable'); 
                        notification.setTitle('Customer Unreachable'); 
                        notification.setSenderId(Userinfo.getUserId()); 
                        notification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                        notification.setTargetId(cse.id);
                        notification.send(orderTeamUsers); 
                        system.debug('notification:::::::::>' + notification);
                        
                        
                        WareHouseNotification.setBody('Dear WareHouse, Please take a look of this Order Customer Unreachable'); 
                        WareHouseNotification.setTitle('Customer Unreachable'); 
                        WareHouseNotification.setSenderId(Userinfo.getUserId()); 
                        WareHouseNotification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                        WareHouseNotification.setTargetId(cse.id);
                        WareHouseNotification.send(WareHouseUsers);
                        system.debug('WareHouseNotification:::::::::>' + WareHouseNotification);
                        
                        task tsk = new task();
                        tsk.subject ='Customer Unreachable';
                        tsk.Priority = 'High';
                        tsk.ActivityDate = System.today().addDays(2);
                        tsk.whatId =   cse.Id;
                        tsk.OwnerId = OrderTeamTaskUsers[0];
                        taskList.add(tsk);
                    }
                }
            }
        }
        
        if (!mailList.isEmpty()) {
            Messaging.sendEmail(mailList);
        }
        Insert taskList;
        system.debug('taskList:::::::::>' + taskList);
        
    }
    */
    public static void AccountCreatedConCreated(List<Account> AccList) {
        List<Contact> conlist = new List<Contact>();
        for(Account acc : AccList){
            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.LastName = acc.Name;
            con.Phone = acc.Phone;
            con.Description = acc.Description;
            con.Email = acc.Email__c;
            conlist.add(con);
        }
        if (!conlist.isEmpty()) {
            insert conlist;  
        }
    }
    
}