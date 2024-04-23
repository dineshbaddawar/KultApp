public class showAllRelatedCasesController {
    @AuraEnabled(cacheable = true)
    public static List<Case> getCaseList(String chatTranscripId){
        try{
            if(chatTranscripId != null && string.valueOf(chatTranscripId).startsWith('570')){
                List<LiveChatTranscript> caseList1 = [SELECT Id, CaseId FROM LiveChatTranscript WHERE Id=: chatTranscripId LIMIT 1];
                String caseId;
                if(!caseList1.isEmpty()){
                    caseId = caseList1[0].CaseId;
                }
                if(caseId != null){
                    Case caseRec = [SELECT Id, CaseNumber, OrderId__c, OrderId__r.AccountId, ContactId, AccountId FROM Case WHERE Id=: caseId LIMIT 1];
                    String orderId;
                    String accountId;
                    String caseContactId;
                    String caseAccountId;
                    if(caseRec.OrderId__c != null){
                        orderId = caseRec.OrderId__c;
                    }
                    if(caseRec.OrderId__r.AccountId != null){
                        accountId = caseRec.OrderId__r.AccountId;
                    }
                    if(caseRec.ContactId != null){
                        caseContactId = caseRec.ContactId;
                    }
                    if(caseRec.AccountId != null){
                        caseAccountId = caseRec.AccountId;
                    }
                List<Case> caseList =[SELECT Id, CaseNumber, OrderId__c, OrderId__r.AccountId, Status, Origin, Subject, Priority,Sub_Sub_Type__c, Sub_Type__c FROM Case WHERE (OrderId__c =: orderId OR AccountId =: accountId OR ContactId =: caseContactId OR AccountId =: caseAccountId) AND Status != 'Closed' ORDER BY CreatedDate DESC];
                return caseList;
                }
                return null;
            }else if(chatTranscripId != null && string.valueOf(chatTranscripId).startsWith('500')){
            Case caseRec = [SELECT Id, CaseNumber, OrderId__c, OrderId__r.AccountId, ContactId, AccountId FROM Case WHERE Id=: chatTranscripId LIMIT 1];
            String orderId;
            String accountId;
            String caseContactId;
            String caseAccountId;
            if(caseRec.OrderId__c != null){
                orderId = caseRec.OrderId__c;
            }else{
                orderId = '0';
            }
            if(caseRec.OrderId__r.AccountId != null){
                accountId = caseRec.OrderId__r.AccountId;
            }else{
                accountId = '0';
            }
            if(caseRec.ContactId != null){
                caseContactId = caseRec.ContactId;
            }else{
                caseContactId = '0';
            }
            if(caseRec.AccountId != null){
                caseAccountId = caseRec.AccountId;
            }else{
                caseAccountId = '0';
            }
            List<Case> caseList =[SELECT Id, CaseNumber, OrderId__c, OrderId__r.AccountId, Status, Origin, Subject, Priority,Sub_Sub_Type__c, Sub_Type__c FROM Case WHERE (OrderId__c =: orderId OR AccountId =: accountId OR ContactId =: caseContactId OR AccountId =: caseAccountId) AND Status != 'Closed' ORDER BY CreatedDate DESC];
                return caseList;
        }else{
                return null;
            }
        }catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at line number ' + e.getLineNumber());
            return null;
        }
    }
}