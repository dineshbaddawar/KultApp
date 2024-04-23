public class CallLogTriggerHelper {
    
    public static void collectEmailOrPhoneOfCallLogs(List<Call_Logs_Custom__c> callLogList) {
        
        List<Call_Logs_Custom__c> recordFindedwihEmailPhoneContact = new List<Call_Logs_Custom__c>();
        Map<String,String> mapOfCallLogIdContactId = new Map<String,String>();
        Map<String,String> mapOfContactCustomLog = new Map<String,String>();
        Set<Id> setOfContactId = new Set<Id>();
        List<Id> contactIds = new List<Id>();
        String callLogEmail;
        String callLogPhone;
        Boolean isContactCreated;
        Boolean isPhoneThere;
        Boolean isMobileThere;
        
        for (Call_Logs_Custom__c clg : callLogList) {
            if(clg.Contact__c != null){
                isContactCreated = true;
                setOfContactId.add(clg.Contact__c);
            }else{
                isContactCreated= false;
            }
            if(clg.Email__c != null){
                callLogEmail = clg.Email__c;
            }if( clg.Phone__c != null){
                callLogPhone =  clg.Phone__c;
            }
        }
     //   System.debug('setOfContactId::::>'+setOfContactId);
     //   System.debug('callLogEmail::::>'+callLogEmail);
     //   System.debug('callLogPhone::::>'+callLogPhone);
        
        List<Contact> conList = [SELECT Id, Name, Email, Phone FROM Contact WHERE Id IN :setOfContactId OR Email = :callLogEmail OR Phone = :callLogPhone];
        System.debug('conList Record Find Using Phone or Email or Id>'+conList);
        if (!conList.isEmpty()) {
            for (Contact con : conList) {
                contactIds.add(con.Id);
            }
        }
        
        recordFindedwihEmailPhoneContact = [SELECT Id,Contact__c FROM Call_Logs_Custom__c WHERE Contact__c IN:contactIds];
         System.debug('Contact Record Find Size === >'+recordFindedwihEmailPhoneContact.size());
        if(recordFindedwihEmailPhoneContact.size()>0){
            for(Call_Logs_Custom__c cus : recordFindedwihEmailPhoneContact){
                mapOfCallLogIdContactId.put(cus.id,cus.Contact__c);
                mapOfContactCustomLog.put(cus.Contact__c,cus.Id);
            }
        }
        System.debug('mapOfCallLogIdContactId === >'+mapOfCallLogIdContactId);
        
        List<BusinessHours> bhList = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
         
        //Assign case when business hours call came in non business hours 
        List<Group> groupList = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'non business hours'];
        //Assign case when business hours call came in business hours but not picked 
        List<Group> groupLists = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Non Picked Call'];
        
        System.debug('groupList::::>'+groupList);
        System.debug('groupLists::::>'+groupLists);
        
        List<Case> caseList = new List<Case>();
        for (Call_Logs_Custom__c callLog : callLogList) {
            Boolean isWithinBusinessHours = BusinessHours.isWithin(bhList[0].Id, callLog.CreatedDate);
            System.debug('isWithinBusinessHours == >'+isWithinBusinessHours);
            if (callLog.CreatedDate != null) {
                if(callLog.Status__c != null){
                    if (callLog.Status__c == 'Missed') {
                        if (isWithinBusinessHours == true) {
                            if(groupList.Size()>0){
                                Case cs = new Case();
                                cs.Status = 'Un Assigned';
                                cs.ownerId = groupList[0].id;
                                cs.ContactId = mapOfCallLogIdContactId.get(callLog.Id);
                                caseList.add(cs);
                                System.debug('caseList Missed == >'+caseList);
                            }
                        } else {
                            if (isWithinBusinessHours != true) {
                                if(groupLists.Size()>0){
                                    Case cs = new Case();
                                    cs.Status = 'Un Assigned';
                                    cs.ContactId =mapOfCallLogIdContactId.get(callLog.Id);
                                    cs.ownerId = groupLists[0].id;
                                    caseList.add(cs);
                                    System.debug('caseList Un Assigned === >>'+caseList);
                                }
                            }
                        }
                    } else if (callLog.Status__c == 'In-progress') {
                        case cs = new Case();
                        cs.ContactId =mapOfCallLogIdContactId.get(callLog.Id);
                        cs.OwnerId = callLog.OwnerId;
                        caseList.add(cs);
                        System.debug('caseList In-progress >>>'+caseList);
                    }
                }
            }
        }
        if(!caseList.isEmpty()){
            Insert caseList;
            System.debug('case Record Inserted === >'+caseList);
             System.debug('caseList Inserted from Call log Size ==>>'+caseList.size());
        }
       
        
        List<Call_Logs_Custom__c> updateCallList = new List<Call_Logs_Custom__c>();
        List<Call_Logs_Custom__c> updateCallLogList = [SELECT Id,Contact__c FROM Call_Logs_Custom__c WHERE Id IN:mapOfCallLogIdContactId.keySet()];
        for(Case cse : caseList){
            for(Call_Logs_Custom__c log : updateCallLogList){
                if(log.Contact__c !=null && log.Contact__c == cse.ContactId ){
                    Call_Logs_Custom__c updateLog = new Call_Logs_Custom__c();
                    updateLog.Id =log.id;
                    updateLog.Case__c = cse.Id;
                    updateCallList.add(log);
                }
            }
        }
        if(updateCallList.size()>0){
            update updateCallList;
            System.debug('updateCallList::::>'+updateCallList);
        }
        
    }
}