global class batchForCaseAssignInBusinnessHours implements Database.Batchable<sObject> {
    global Database.queryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Name,Type,DeveloperName FROM Group WHERE Type = 'Queue' AND (DeveloperName= 'Email_Case' OR DeveloperName= 'Missed_Call_Queue' OR DeveloperName= 'non_business_hours' OR DeveloperName= 'Warehouse_Team_Queue')]);
    }
    global void execute(Database.BatchableContext bc, List<Group> queueList) {
        try{
            system.debug('queueList=====>'+queueList);
            String QueueComesWithEmailIds;
            String QueueComesFromMissedCallIds;
            String QueueComesFromNonBusinessHoursIds;
            String QueueComesInWarehouseTeamQueueIds;
            
            List<Working_Hour__mdt> workHour = [SELECT Id, Label, Start_Time__c, End_Time__c FROM Working_Hour__mdt WHERE Label='Chat Support Team'];
            System.debug('workHour====>' +workHour);
            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'custom_notification_to_refund_team_on_pincode_not_serviceable'];  
            System.debug('type====>' +type);
            List<User> userList = [SELECT Id,Email,Name FROM User Where profile.Name ='System Administrator'];
            System.debug('userList====>' +userList);
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='emailTemplateWhichAreInQueues'];
            System.debug('temp====>' +temp);
            OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Customer Support'];
            System.debug('owea====>' +owea);
            
             
            set<String> setOfUserId = new set<String>(); 
            List<String> ListOfUserEmail = new List<String>(); 
            for(User us : userList){
                setOfUserId.add(us.Id);
                ListOfUserEmail.add(us.email);
            }
            
            Map<String,String> mapOfQueues = new Map<String,String>();
            for(Group queues : queueList){
                system.debug('queues=====>'+queues);
                if(queues.type == 'Queue' && queues.DeveloperName == 'Email_Case'){
                    QueueComesWithEmailIds = queues.Id;
                    mapOfQueues.put(queues.Id,queues.Name);
                    System.debug('mapOfQueues====>' +mapOfQueues);
                    System.debug('QueueComesWithEmailIds====>' +QueueComesWithEmailIds);
                    
                }else if(queues.type == 'Queue' && queues.DeveloperName == 'Missed_Call_Queue'){
                    QueueComesFromMissedCallIds = queues.Id;
                    mapOfQueues.put(queues.Id,queues.Name);
                    System.debug('mapOfQueues====>' +mapOfQueues);
                    System.debug('QueueComesFromMissedCallIds====>' +QueueComesFromMissedCallIds);
                    
                }else if(queues.type == 'Queue' && queues.DeveloperName == 'non_business_hours'){
                    QueueComesFromNonBusinessHoursIds = queues.Id;
                    mapOfQueues.put(queues.Id,queues.Name);
                    System.debug('mapOfQueues====>' +mapOfQueues);
                    System.debug('QueueComesFromNonBusinessHoursIds====>' +QueueComesFromNonBusinessHoursIds);
                    
                }else if(queues.type == 'Queue' && queues.DeveloperName == 'Warehouse_Team_Queue'){
                    QueueComesInWarehouseTeamQueueIds = queues.Id;
                    mapOfQueues.put(queues.Id,queues.Name);
                    System.debug('mapOfQueues====>' +mapOfQueues);
                    System.debug('QueueComesInWarehouseTeamQueueIds====>' +QueueComesInWarehouseTeamQueueIds);
                }
            }
            
            
            List<Case> caseList = [SELECT Id,OwnerId,caseNumber,Priority,Status,Subject From Case];
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
                    if(caseList.size() > 0){
                        String body = temp.Body;
                        String subject = temp.Subject;
                        Integer CaseQueueComesWithEmailIds = 0;
                        Integer CaseQueueComesFromMissedCallIds = 0;
                        Integer CaseQueueComesFromNonBusinessHoursIds = 0;
                        Integer CaseQueueComesInWarehouseTeamQueueIds = 0;
                        List<Case> caseListQueueComesWithEmailIds = new List<Case>();
                        List<Case> caseListQueueComesFromMissedCallIds = new List<Case>();
                        List<Case> caseListQueueComesFromNonBusinessHoursIds = new List<Case>();
                        List<Case> caseListQueueComesInWarehouseTeamQueueIds = new List<Case>();
                        
                        
                        for(Case cse : caseList){
                            system.debug('cse OwnerId === >'+cse.OwnerId);
                            system.debug('QueueComesWithEmailIds  === >'+QueueComesWithEmailIds);
                            if(cse.OwnerId != null && (cse.OwnerId == QueueComesWithEmailIds || cse.OwnerId == QueueComesFromMissedCallIds || cse.OwnerId == QueueComesFromNonBusinessHoursIds || cse.OwnerId == QueueComesInWarehouseTeamQueueIds)){
                                if(cse.OwnerId == QueueComesWithEmailIds){
                                    CaseQueueComesWithEmailIds++; 
                                }
                                if(cse.OwnerId == QueueComesFromMissedCallIds){
                                    CaseQueueComesFromMissedCallIds++;
                                }
                                if(cse.OwnerId == QueueComesFromNonBusinessHoursIds){
                                    CaseQueueComesFromNonBusinessHoursIds++;
                                }
                                if(cse.OwnerId == QueueComesInWarehouseTeamQueueIds){
                                    CaseQueueComesInWarehouseTeamQueueIds++;
                                }
                                
                                //Sending Notification
                                Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                                notification.setBody('This is Record Id'+ ' ' + cse.Id + ' '+ 'Of Case Which Is in Side the Bussiness Hours but inside the queue Please Go through It'); 
                                notification.setTitle('Case Which Is Inside the Queue'); 
                                notification.setNotificationTypeId(type.id); 
                                notification.setTargetId(cse.Id); 
                                notification.send(setOfUserId);
                                system.debug('notification::::::::>'+notification);
                                
                                //Sending Email
                                if(CaseQueueComesWithEmailIds > 0){
                                    Body = Body.replace('{!Case.Email_Case}', String.ValueOf(CaseQueueComesWithEmailIds));
                                }else{
                                    Body = Body.replace('{!Case.Email_Case}', 'NA');
                                }
                                if(CaseQueueComesFromMissedCallIds > 0){
                                    Body = Body.replace('{!Case.Missed_Call_Queue}',  String.ValueOf(CaseQueueComesFromMissedCallIds));
                                }else{
                                    Body = Body.replace('{!Case.Missed_Call_Queue}', 'NA');
                                } if(CaseQueueComesFromNonBusinessHoursIds > 0){
                                    Body = Body.replace('{!Case.non_business_hours}',  String.ValueOf(CaseQueueComesFromNonBusinessHoursIds));
                                }else{
                                    Body = Body.replace('{!Case.non_business_hours}', 'NA');
                                } if(CaseQueueComesInWarehouseTeamQueueIds > 0){
                                    Body = Body.replace('{!Case.Warehouse_Team_Queue}',  String.ValueOf(CaseQueueComesInWarehouseTeamQueueIds));
                                }else{
                                    Body = Body.replace('{!Case.Warehouse_Team_Queue}', 'NA');
                                }
                                Body = Body.replace('{!User.Name}', userList[0].Name);
                                if(mapOfQueues.containsKey(cse.OwnerId)){
                                    Body = Body.replace('{!Queue.Name}', mapOfQueues.get(cse.OwnerId));
                                }
                                
                                if(CaseQueueComesWithEmailIds > 0 || CaseQueueComesFromMissedCallIds > 0 || CaseQueueComesFromNonBusinessHoursIds > 0 || CaseQueueComesInWarehouseTeamQueueIds > 0){
                                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                                    mailTemp.setPlainTextBody(body);
                                    mailTemp.setTemplateId(temp.id);
                                    mailTemp.setSaveAsActivity(true);
                                    mailTemp.setWhatId(cse.id);
                                    mailTemp.setToAddresses(ListOfUserEmail);
                                    mailTemp.setorgwideemailaddressid(owea.id);
                                    mailList.add(mailTemp);
                                }
                                
                            }
                        }  
                    } 
                }
            }
            if(!mailList.isEmpty()){
                Messaging.sendEmail(mailList);
                system.debug('mailList::::::::>'+mailList);
            }
        }catch(Exception e){
            System.debug('The Error ======>'+e.getMessage() +' Erron Line ======>'+e.getLineNumber());
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {   
        
    }
}