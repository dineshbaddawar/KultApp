public class CallLogHelper {
    public static Void CallLogGenerate(List<Call_Logs_Custom__c> newListOfLog){
        try{
            
            Set<String> CallLogNumber = new  Set<String>();
            Set<String> CallLogEmail = new Set<String>();
            List<Contact> conList = new List<Contact>();
            List<Contact> conListToBInserted = new List<Contact>();
            List<Contact> conListToUpdated= new List<Contact>();
            List<Case> caseList = new List<Case>();
            Map<String,String> mapOfCallLogIdContactId = new map<String,String>();
            Map<String,String> mapOfCallLogIdContactIdUpdated = new map<String,String>();
            Map<String,String> mapOfContactICustomLogId = new map<String,String>();
            List<Call_Logs_Custom__c> UpdatedCustomLogList = new List<Call_Logs_Custom__c>();
            Map<String,String> mapOf = new map<String,String>();
            
            for(Call_Logs_Custom__c CustomLog : newListOfLog){
                if(CustomLog.Phone__c != null){
                    CallLogNumber.add(CustomLog.Phone__c);
                }
                if(CustomLog.Email__c != null){
                    CallLogEmail.add(CustomLog.Email__c);
                }
            }
            System.debug('CallLogNumber === >>'+CallLogNumber +' && CallLogEmail === >>' +CallLogEmail);
            conList = [SELECT Id,Name,Email,Phone from Contact Where Phone IN: CallLogNumber OR Email IN:CallLogEmail];
            System.debug('conList Size === >>'+conList.size());
            if(conList.size()>0){
                System.debug('contact Record Found');
                for(Contact con : conList){
                    for(Call_Logs_Custom__c log : newListOfLog){
                        if((con.Phone !=null && con.Phone == log.Phone__c) || (con.Email !=null && con.Email ==log.Email__c )){
                            Contact contoUpdate = new Contact();
                            contoUpdate.Id = con.id;
                            contoUpdate.customLogId__c = log.Id;
                            conListToUpdated.add(contoUpdate);
                        }
                    }
                }
                System.debug('contact Record Found conListToUpdated == >'+conListToUpdated);
                if(conListToUpdated.size()>0){
                    update conListToUpdated;
                    system.debug('Updated contact with Log Id == >'+conListToUpdated);
                    if(conListToUpdated.size()>0){
                        for(Contact con : conListToUpdated){
                            if(con.customLogId__c !=null){
                                mapOfCallLogIdContactId.put(con.customLogId__c,con.Id);  
                            }
                        }
                    }
                }
                System.debug('contact Record Found mapOfCallLogIdContactId == >'+mapOfCallLogIdContactId);
            }else{
                System.debug('No contact Record Found');
                for(Call_Logs_Custom__c CustomLog : newListOfLog){
                    contact con = new Contact();
                    if(CustomLog.Phone__c == null){
                        con.Phone = CustomLog.Phone__c;
                    } if(CustomLog.Email__c == null){
                        con.Email = CustomLog.Email__c;                   
                    }
                    con.LastName = 'Not Provided';
                    con.customLogId__c = CustomLog.Id;
                    conListToBInserted.add(con);
                }
                if(conListToBInserted.Size()>0){
                    Insert conListToBInserted;
                    System.debug('Contact Record Create From Custom Log == >'+conListToBInserted);
                }
                if(conListToBInserted.size()>0){
                    for(Contact con : conListToBInserted){
                        if(con.customLogId__c != null){
                            mapOfCallLogIdContactId.put(con.customLogId__c,con.Id);                        
                        }
                    } 
                }
            }
            
            System.debug('mapOfCallLogIdContactId == >'+mapOfCallLogIdContactId);
            List<Call_Logs_Custom__c> updatcustomLogWithContactId = new List<Call_Logs_Custom__c>();
            for(Call_Logs_Custom__c log : [SELECT Id,Contact__c FROM Call_Logs_Custom__c WHERE Id IN:mapOfCallLogIdContactId.keySet()]){
                Call_Logs_Custom__c uplog = new Call_Logs_Custom__c();
                uplog.Id = log.id;
                uplog.Contact__c = mapOfCallLogIdContactId.get(log.Id);
                updatcustomLogWithContactId.add(uplog);
            }
            if(updatcustomLogWithContactId.size()>0){
                update updatcustomLogWithContactId;
                system.debug('Update custom Log with ContactId == >'+updatcustomLogWithContactId);
                if(updatcustomLogWithContactId.size()>0){
                    for (Call_Logs_Custom__c callLog : updatcustomLogWithContactId) {
                        mapOfCallLogIdContactIdUpdated.put(callLog.id,callLog.Contact__c);
                    }
                }
            }
            system.debug('mapOfCallLogIdContactIdUpdated === >'+mapOfCallLogIdContactIdUpdated);
            List<BusinessHours> bhList = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
            
            //Assign case when business hours call came in non business hours 
            List<Group> groupList = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'non business hours'];
            //Assign case when business hours call came in business hours but not picked 
            List<Group> groupLists = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Non Picked Call'];
            
            for (Call_Logs_Custom__c callLog : newListOfLog) {
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
            
            if(caseList.size()>0){
                insert caseList;
                System.debug('Inserted Case Record  >>>'+caseList);
                if(caseList.size()>0){
                    for(Case caseRe :  caseList){
                        if(caseRe.ContactId !=null){
                            mapOfContactICustomLogId.put(caseRe.ContactId,caseRe.Id);
                        }
                    }
                }
                System.debug('mapOfContactICustomLogId  >>>'+mapOfContactICustomLogId);
                System.debug('mapOfCallLogIdContactId  >>>'+mapOfCallLogIdContactId);
                List<Call_Logs_Custom__c> customList = [SELECT Id,Name,Contact__c FrOM Call_Logs_Custom__c WHERE Id IN:mapOfCallLogIdContactIdUpdated.keySet()];
                System.debug('customList Size  >>>'+customList);
                
                for(Call_Logs_Custom__c custlog : customList){
                    System.debug('custlog  >>>'+custlog);
                    Call_Logs_Custom__c custlogToUpdate = new Call_Logs_Custom__c();
                    custlogToUpdate.id = custlog.id;
                    custlogToUpdate.Case__c = mapOfContactICustomLogId.get(custlog.Contact__c);
                    UpdatedCustomLogList.add(custlogToUpdate);
                }
                if(UpdatedCustomLogList.size()>0){
                    update UpdatedCustomLogList;
                    system.debug('Update Log With Case Record == >'+UpdatedCustomLogList);
                }
            }
            
            
        }Catch(Exception e){
            System.debug('message::::>'+e.getMessage()+'Line Number::::>'+e.getLineNumber());
        }
    }
}