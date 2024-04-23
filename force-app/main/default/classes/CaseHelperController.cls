public class CaseHelperController {
    
    // Method to get All Profile Names   
    @AuraEnabled(cacheable = true)
    public static List<String> getAllProfileNames() {
        List<String> profileNames = new List<String>();
        for (Profile prof : [SELECT Name FROM Profile]) {
            profileNames.add(prof.Name);
        }
        return profileNames;
    }
    
    // Method to get User List Based on Selected Profile
    @AuraEnabled(cacheable=true)
    public static List<String> getUsersByProfile(String profileName) {
        List<String> userList = new List<String>();
        for (User user : [SELECT Id,Name,Profile.Name FROM User WHERE Profile.Name = :profileName]) {
            userList.add(user.Name);
        }
        return userList;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<User> getUsersBasedOnSelectedProfile(String profileName) {
        try {
            List<User> userList = new List<User>();
            if(profileName !=null){
                userList = [SELECT id,Name,Profile.Name FROM User WHERE Profile.Name=: profileName];
                if(userList.size()>0){
                    System.debug('User List Size === >'+userList.size());
                    return userList;
                }
            }
        } catch (Exception e)  {
            System.debug('Error == >'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }
    
    // Method for Case Sharing Record to Selected User -Dinesh
    @AuraEnabled 
    public static string shareCaseRecordWithSelectedUser(String recordId,String userOrGroupId){
        system.debug('userOrGroupId===>'+userOrGroupId);
        Case caseRec = new Case();
        CaseShare cshare = new CaseShare();
        List<CaseShare> csList = new List<CaseShare>();
        try{
            if(recordId !=null && userOrGroupId !=null){
                
                caseRec =  [SELECT Id, Subject FROM Case WHERE Id=:recordId];
                if(caseRec !=null){ 
                    cshare.CaseId = caseRec.Id;
                    cshare.UserOrGroupId = userOrGroupId;
                    cshare.CaseAccessLevel = 'Edit';
                    cshare.RowCause = Schema.CaseShare.RowCause.Manual;
                    csList.add(cshare);
                }
                if(csList.size()>0){
                    Database.SaveResult[] srList = Database.insert(csList, false);
                    if(srList[0].isSuccess()){
                        sendEmailToUser(caseRec.Id,userOrGroupId);
                        return 'SUCCESS';
                    }else{
                        return 'ERROR';
                    }
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    
    // Method for Sending Email to User,
    @AuraEnabled 
    public static string sendEmailToUser(string recordId,string userId){
        System.debug('recordId == >'+recordId+' && userId == >'+userId);
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE Name ='Case Record Share Email'];
        User CurrentUserRec = new User();
        Case CaseRec = new Case();
        try{
            if(recordId !=null && userId != null){
                CaseRec = [SELECT Id,Subject,CaseNumber,Owner.Name FROM Case WHERE Id=:recordId];
                String htmlBody = temp.HTMLValue;
                String plainTextBody = temp.body;
                String CaseURL = System.label.CaseURL;
                
                CurrentUserRec = [select userName,Name,Email from user WHERE Id=:userId LIMIT 1];
                system.debug('CurrentUserRec == >'+CurrentUserRec);
                if(CurrentUserRec !=null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    htmlBody = htmlBody.replace('{!Case.OwnerFullName}', CurrentUserRec.Name);
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}', CaseRec.CaseNumber);
                    htmlBody = htmlBody.replace('{!Case.Subject}', CaseRec.Subject);
                    htmlBody = htmlBody.replace('{!User.FirstName}', UserInfo.getName());
                    htmlBody = htmlBody.replace('{!RecordURL}', CaseURL+CaseRec.Id+'/view');
                    
                    plainTextBody = plainTextBody.replace('{!Case.OwnerFullName}', CurrentUserRec.Name);
                    plainTextBody = plainTextBody.replace('{!Case.CaseNumber}', CaseRec.CaseNumber);
                    plainTextBody = plainTextBody.replace('{!Case.Subject}', CaseRec.Subject);
                    plainTextBody = plainTextBody.replace('{!User.FirstName}', UserInfo.getName());
                    plainTextBody = plainTextBody.replace('{!RecordURL}', CaseURL+CaseRec.Id+'/view');
                    
                    mail.setHtmlBody(htmlBody);
                    mail.setSubject(temp.Subject);
                    mail.setPlainTextBody(plainTextBody);
                    mail.toAddresses = new String[] {CurrentUserRec.Email};
                        mailList.add(mail);
                    if(!mailList.isEmpty()){
                        Messaging.sendEmail(mailList);
                        return 'SUCCESS';
                    }
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // Method for OrderLineItem Controller - Tushar ,
    @AuraEnabled
    public static List<OrderItem> getOrderLineItems(String orderId){
        List<OrderItem> orderLineItems = new List<OrderItem>();
        
        // Case cRec = [Select Id,OrderId__c FROM Case WHERE ID =: caseId];
        
        if(orderId != null){
            orderLineItems = [Select Id,Product2.Name,Quantity,TotalPrice,UnitPrice FROM OrderItem WHERE OrderId =:orderId];
            if(orderLineItems.size()>0){
                system.debug('orderLineItems'+orderLineItems);
                return orderLineItems;
            }
        } 
        return null;          
        
    }
    
    @AuraEnabled
    public static Case getCaseRecord(String recordId){
        Case cRec = new Case();
        try{
            if(recordId != null){
                cRec = [Select Id,OrderId__c FROM Case WHERE Id =:recordId AND OrderId__c != null];
                if(cRec != null){
                    system.debug('cRec '+cRec);
                    return cRec;
                }else{
                    
                }
            }
        }catch(Exception e){
            system.debug('Error ===> '+e.getMessage()+ '  &&  Error Line === >'+ e.getLineNumber());
        }
        return null;
    }
    
    
    // Method for Getting Case Record Details - Record Type & Case Details
    @AuraEnabled 
    Public static Case getCaseRecordDetails(String recordId){
        Case caseRec = new Case();
        try{
            if(recordId !=null){
                caseRec = [SELECT Id,RecordTypeId,RecordType.Name,Origin FROM Case WHERE Id=:recordId];
                if(caseRec !=null){
                    system.debug('Case Details === >'+caseRec);
                    return caseRec;
                }
            }
        }catch(Exception e){
            System.debug('Error '+e.getMessage()+' && Error Message == >'+e.getLineNumber());
        }
        return null;
    }
    
    
    //Method for Getting Case Details on LWC Card - Tushar
    @AuraEnabled
    Public static Case getCaseDetails(String recId){
        return  [Select Id,Account.Name,OrderId__r.OrderNumber,Refund_Reason__c,Sub_Type__c,Sub_Sub_Type__c,Origin,Type_Of_Case__c, Case_Sub_Status__c FROM Case WHERE Id=: recId];         
    }
    
    // @AuraEnabled
    // public static String getOrderDetailsFromCa(String recId){
    
    //     String orderName;
    //     String orderId;
    //     if(recId !=null){
    //          orderId = [Select Id,Account.Name,OrderId__c,Refund_Reason__c FROM Case WHERE Id=: recId].OrderId__c;
    //         if(orderId !=null){
    //          orderName = [Select Id,OrderNumber from Order where Id=:orderId].OrderNumber;
    //             if(orderName !=null){
    //                 return orderName;
    //             }
    //         }
    //     } 
    // }
    
    @AuraEnabled
    public static String getOrderDetailsFromCaseRecord(String recId){
        String orderName;
        String orderId;
        try{
            if(recId !=null){
                orderId = [Select Id,Account.Name,OrderId__c,Refund_Reason__c FROM Case WHERE Id=: recId].OrderId__c;
                if(orderId !=null){
                    orderName = [Select Id,OrderNumber from Order where Id=:orderId].OrderNumber;
                    if(orderName !=null){
                        return orderName;
                    }else{
                        return 'Blank or Null orderName ';
                    }
                }else{
                    return 'Blank or Null orderId ';
                }
            }else{
                return 'Blank or Null recId ';
            }
        }catch(Exception e){
            system.debug('ERROR == >'+e.getMessage()+' && Error Line === >'+e.getLineNumber());
        }
        return null;
    }
    
    
    
    @AuraEnabled
    public static List<Order> getOrder(String recId){
        
        String orderId = [Select Id,Account.Name,OrderId__c,Refund_Reason__c FROM Case WHERE Id=: recId].OrderId__c;
        List<Order> orderName = [Select Id,OrderNumber from Order where Id=:orderId];
        return orderName;
    }
    
    
    //EmailTemplate Code - Tushar
    
    public static List<Case> getCasesByOrder(Id caseId) {
        system.debug('caseId=====>'+caseId);
        List<Case> relatedCases = [SELECT Id,Contact.Name,Contact.Email,Subject,OrderId__r.OrderNumber,OrderId__r.UTR_Number__c,Inital_Commented_Date__c,OrderId__c, Description, Status,Product.Name,Owner.Name FROM Case WHERE Id =:caseId];
        system.debug('relatedCases::::'+relatedCases);
        List<OrderItem> orderItems = new List<OrderItem>();
        if (!relatedCases.isEmpty()) {
            // Id relorderId = relatedCases[0].OrderId__c;
            orderItems = [SELECT Id,OrderId, Product2.Name FROM OrderItem WHERE OrderId = :relatedCases[0].OrderId__c];
            system.debug('orderItems::::'+orderItems);
        }
        
        sendEmailWithTemplate(relatedCases,orderItems);
        // sendEmailWithTemplate(relatedCases,orderItems,'Wrong Missing Order or Product');
        return relatedCases;
    }
    
    @AuraEnabled
    public static string sendEmailWithTemplate(List<Case> caseList, List<OrderItem> orderItemsList) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Notification_About_Refund_Processing'];
        system.debug('temp:::'+temp);
        
        
        try{
            if(!orderItemsList.isEmpty() && !caseList.isEmpty()){
                String htmlBody = temp.HTMLValue;
                String plainTextBody = temp.body;
                String CaseURL = System.label.CaseURL;                
                
                
                for (Case caseRec : caseList) {
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    String subject = temp.Subject + ' - Order Number: ' + caseRec.OrderId__r.OrderNumber;
                    system.debug('subject::::'+subject);
                    
                    
                    if (caseRec.Contact.Name != null && caseRec.OrderId__r.OrderNumber !=null && caseRec.Inital_Commented_Date__c != null && caseRec.Subject != null && caseRec.OrderId__r.UTR_Number__c != null && caseRec.Owner.Name !=null ) {
                        List<String> commDateSplit = String.valueOf(caseRec.Inital_Commented_Date__c).split('-');
                        String commDate = commDateSplit[2] + '-' + commDateSplit[1] + '-' + commDateSplit[0];
                        
                        htmlBody = htmlBody.replace('{!Case.Contact}', caseRec.Contact.Name);
                        htmlBody = htmlBody.replace('{!Case.OrderId__c}', caseRec.OrderId__r.OrderNumber);
                        htmlBody = htmlBody.replace('{!Case.Inital_Commented_Date__c}', commDate);
                        htmlBody = htmlBody.replace('{!Case.Subject}', caseRec.Subject);
                        //htmlBody = htmlBody.replace('{!Case.ProductId.Name}', caseRec.ProductId.Name);
                        htmlBody = htmlBody.replace('{!Case.UTRNo__c}', caseRec.OrderId__r.UTR_Number__c); 
                        htmlBody = htmlBody.replace('{!Case.OwnerFullName}', caseRec.Owner.Name);
                        //htmlBody = htmlBody.replace('{!RecordURL}', CaseURL+CaseRec.Id+'/view');
                        
                        plainTextBody = plainTextBody.replace('{!Case.Inital_Commented_Date__c}', commDate);
                        plainTextBody = plainTextBody.replace('{!Case.Subject}', caseRec.Subject);
                        plainTextBody = plainTextBody.replace('{!Case.Contact}', caseRec.Contact.Name);
                        plainTextBody = plainTextBody.replace('{!Case.OrderId__c}', caseRec.OrderId__r.OrderNumber);
                        //plainTextBody = plainTextBody.replace('{!Case.ProductId.Name}', caseRec.ProductId.Name);
                        plainTextBody = plainTextBody.replace('{!Case.UTRNo__c}', caseRec.OrderId__r.UTR_Number__c);
                        plainTextBody = plainTextBody.replace('{!Case.OwnerFullName}', caseRec.Owner.Name);
                        //plainTextBody = plainTextBody.replace('{!RecordURL}', CaseURL+CaseRec.Id+'/view');
                    }else{
                        System.debug('Contact is null for Case: ' + caseRec.Id);
                        System.debug('Order is null for Case: ' + caseRec.Id);
                        System.debug('Unexpected date format for Case: ' + caseRec.Id);
                        System.debug('Subject is null for Case: ' + caseRec.Id);
                        System.debug('UTR No is null for Case: ' + caseRec.Id);
                        System.debug('Owner is null for Case: ' + caseRec.Id);
                    }
                    
                    String prodNames ='';
                    
                    for (OrderItem orderItem : orderItemsList) {
                        if (orderItem.OrderId == caseRec.OrderId__c) {
                            prodNames += orderItem.Product2.Name + ',';
                        }
                    }
                    
                    htmlBody = htmlBody.replace('{!Case.Product}', prodNames);
                    plainTextBody = plainTextBody.replace('{!Case.Product}', prodNames);
                    
                    mail.setHtmlBody(htmlBody);
                    mail.setSubject(subject);
                    mail.setPlainTextBody(plainTextBody);
                    mail.toAddresses = new String[] {caseRec.Contact.Email};
                        mailList.add(mail);                  
                }
                
                if(!mailList.isEmpty()){
                    Messaging.sendEmail(mailList);
                    return 'SUCCESS';
                }  
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;        
    }
}