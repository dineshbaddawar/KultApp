/* Test Class name : InstagramUtilityTest
* created Date     : 02/03/2024
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class contains all the api's related to instagram DM..
*/
public class InstaDmUtilityClass {
    
    private static Instagram_Api_Details__c fap         = Instagram_Api_Details__c.getInstance();
    
    private static final String CLIENT_ID               = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET                 = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI                  = fap.REDIRECT_URI__c;
    private static String accessToken                   = fap.accessToken__c;
    private static String pageaccessToken               = fap.pageAccessToken__c;
    private static String basicUrl                      = fap.basicUrl__c;
    private static String pageId                        = fap.Page_Id__c;
    //private static String userId                        = fap.user_Id__c;
    private static Id caseRecordTypeId                  = Schema.SObjectType.case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId();
    private static final String FB_GRAPH_API_BASE_URL   = 'callout:meta';
    private static final String ACCESS_TOKEN;
    private static final String PAGE_NAME;
    
    public static string getAllDmMessages(){
        
        List<Case_Communication__c> caseCommunicationList                    = new List<Case_Communication__c>();
        List<Case_Communication__c> caseCommunicationListToBeUpdated         = new List<Case_Communication__c>();
        map<String,List<Case_Communication__c>> communicationsOnCaseByPostId = new map<String,List<Case_Communication__c>>();
        map<string,List<Case_Communication__c>> caseCommunicationsByThreadId = new map<string,List<Case_Communication__c>>();
        map<string,Case> caseByThreadId                                      = new map<string,Case>();
        map<string,Case> caseBySenderId                                      = new map<string,Case>();
        map<Case,List<Case_Communication__c>> communicationsByCase           = new map<Case,List<Case_Communication__c>>();
        map<String,String> caseIdByPostId                                    = new map<String,String>();
        map<String,String> caseCommentIdByPostId                             = new map<String,String>();
        List<String> casePostIds                                             = new List<String>();
        Map<String, String> queryParams                                      = new Map<String, String>();
        Map<String, String> headers                                          = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+pageaccessToken};
            String jsonResponse                                              = '';
        InstaDMWrapper messageInfo                                           = new InstaDMWrapper(); 
        List<String> senderIds                                               = new List<String>();
        
        
        String endpointUrl = basicUrl+pageId+'/conversations?fields=message_count,messages{message,id,thread_id,created_time,from},id,can_reply,senders';
        //&user_id=25162329106715195 
        try{
            system.debug('endpointUrl==>'+endpointUrl);
            if(test.isRunningTest()){
                jsonResponse = '{"id": "17841405793087218", "media_url": "https://www.example.com/image.jpg", "comments": { "data": [{"id": "17851087209098192", "text": "Awesome!", "username": "user1", "timestamp": "2023-07-29T12:40:00+0000"}] } }';
                messageInfo = (InstaDMWrapper) JSON.deserialize(jsonResponse, InstaDMWrapper.class);
            }else{
                HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
                String body = response.getBody();
                system.debug('The response is ==>'+body);
                body = body.replaceAll('from','fromDetails');
                messageInfo = (InstaDMWrapper)JSON.deserialize(body, InstaDMWrapper.class);
            }
            if(messageInfo.data.size() > 0){
                //Getting the Sender ids..
                for(InstaDMWrapper.Data messageRec : messageInfo.data){
                    for(InstaDMWrapper.SenderData senderRec : messageRec.senders.data){
                        senderIds.add(senderRec.id);
                    }
                }
                system.debug('Here is the sender ids==>'+senderIds);
                List<Case> existingCaseList = [Select id,subject,Description,User_ID__c,Post_Id__c from Case where User_ID__c IN :senderIds ];
                List<Case_Communication__c> caseCommunicationsList = [Select Id , Activity_ID__c ,Case__c , Case__r.User_ID__c from Case_Communication__c where Case__c IN : existingCaseList];
                system.debug('caseCommunicationsList==>'+caseCommunicationsList.size());
                map<String,List<String>> existingDmRecordsByCaseId = new map<String,List<String>>();
                for(Case_Communication__c caseCommRec : caseCommunicationsList){
                    if(existingDmRecordsByCaseId.containsKey(caseCommRec.Case__r.User_ID__c)){
                        existingDmRecordsByCaseId.get(caseCommRec.Case__r.User_ID__c).add(caseCommRec.Activity_ID__c);
                    }else{
                        List<String> existingIdForCase = new List<String>();
                        existingIdForCase.add(caseCommRec.Activity_ID__c);
                        existingDmRecordsByCaseId.put(caseCommRec.Case__r.User_ID__c , existingIdForCase);
                    }
                }                
                
                if(existingCaseList.size() > 0){
                    for(Case caseRec : existingCaseList){
                        caseBySenderId.put(caseRec.User_ID__c , caseRec);    
                    }
                    system.debug(caseBySenderId);
                    system.debug('existingDmRecordsByCaseId==>'+existingDmRecordsByCaseId);
                    
                    for(InstaDMWrapper.Data messageRec : messageInfo.data){
                        for(Integer i = 0; i < messageRec.messages.data.size(); i++){
                            InstaDMWrapper.MessageData dmRec = messageRec.messages.data[i];
                            if(caseBySenderId.containsKey(dmRec.fromDetails.id)){
                                if(existingDmRecordsByCaseId.containsKey(dmRec.fromDetails.id) && !existingDmRecordsByCaseId.get(dmRec.fromDetails.id).contains(dmRec.id)){
                                    Case_Communication__c communicationRec        = new Case_Communication__c();
                                    communicationRec.Case__c                      = caseBySenderId.get(dmRec.fromDetails.id).Id;
                                    communicationRec.Activity_Content__c          = dmRec.message;
                                    communicationRec.Activity_ID__c               = dmRec.id;
                                    communicationRec.Activity_Type__c             = 'DM';
                                    communicationRec.Activity_Created_DateTime__c = getDateTime(String.valueOf(dmRec.created_time).removeEnd('+0000'));
                                    caseCommunicationList.add(communicationRec);
                                }
                            }
                        }
                    }
                    if(caseCommunicationList.size() > 0){
                        insert caseCommunicationList;
                        List<String> caseIds = new List<String>();
                        for(Case_Communication__c ccRec : caseCommunicationList){
                            caseIds.add(ccRec.Case__c);
                        }
                        List<Case> caseRecList = [Select id ,record_changed__c from Case where id IN: caseIds];
                        for(Case caseRec : caseRecList){
                            caseRec.record_changed__c = caseRec.record_changed__c ? true : false;
                        }
                        update caseRecList;
                    }
                }else{
                    for(InstaDMWrapper.Data messageRec : messageInfo.data){
                        Integer messageCount = messageRec.messages.data.size();
                        List<Case_Communication__c> newCaseCommunicationList = new List<Case_Communication__c>();
                        Case newCase = new Case();
                        for(Integer i = 0; i < messageRec.messages.data.size(); i++){
                            InstaDMWrapper.MessageData dmRec = messageRec.messages.data[i];
                            system.debug('dmRec==>'+dmRec);
                            if(i == messageCount - 1){
                                //This is the first message so create a case..
                                newCase.User_Name__c              = dmRec.fromDetails.name;
                                newCase.User_Id__c                = dmRec.fromDetails.id;
                                newCase.Description               = dmRec.message;
                                newCase.Brand__c                  = 'Kult App';
                                newCase.Origin                    = 'Facebook';
                                newCase.Type_of_Post__c           = 'DM';
                                newCase.Post_Id__c                = dmRec.id;
                                newCase.Created_DateTime__c       = getDateTime(String.valueOf(dmRec.created_time).removeEnd('+0000'));
                                newCase.recordtypeId              = caseRecordTypeId;
                                newCase.Priority                  = 'High';
                                newCase.Subject                   = 'DM from ' + dmRec.fromDetails.name + ' (userId: ' + dmRec.fromDetails.id + ') Created at: ' + String.valueOf(dmRec.created_time).removeEnd('+0000');
                                caseBythreadId.put(dmRec.thread_id,newCase);
                            } else {
                                //These will be the case communications..
                                Case_Communication__c communicationRec        = new Case_Communication__c();
                                communicationRec.Activity_Content__c          = dmRec.message;
                                communicationRec.Activity_ID__c               = dmRec.id;
                                communicationRec.Activity_User_ID__c          = dmRec.fromDetails.id;
                                communicationRec.Activity_Author__c           = dmRec.fromDetails.name;
                                communicationRec.Activity_Type__c             = 'DM';
                                communicationRec.Activity_Created_DateTime__c = getDateTime(String.valueOf(dmRec.created_time).removeEnd('+0000'));
                                if(caseCommunicationsByThreadId.containsKey(dmRec.thread_id)){
                                    caseCommunicationsByThreadId.get(dmRec.thread_id).add(communicationRec);  
                                }else{
                                    newCaseCommunicationList.add(communicationRec);
                                    caseCommunicationsByThreadId.put(dmRec.thread_id,newCaseCommunicationList);
                                }
                            }
                        }
                        communicationsByCase.put(newCase,newCaseCommunicationList);
                    }
                    system.debug('communicationsByCase==>'+communicationsByCase);
                    system.debug('caseCommunicationsByThreadId==>'+caseCommunicationsByThreadId);
                    system.debug('caseBythreadId==>'+caseBythreadId);
                    if(caseCommunicationsByThreadId.size() > 0){
                        for(string threadId : caseBythreadId.keyset()){
                            Case caseRec = caseBythreadId.get(threadId);
                            insert caseRec;
                            if(caseCommunicationsByThreadId.containsKey(threadId)){
                                for(Case_Communication__c communicationRec : caseCommunicationsByThreadId.get(threadId)){
                                    communicationRec.Case__c = caseRec.Id;
                                }
                                insert caseCommunicationsByThreadId.get(threadId);    
                            }
                        }
                    }
                }
            }
            return 'Success';
        }catch(Exception e){
            system.debug('Error message'+e.getMessage()+'@'+e.getLineNumber());
            return e.getMessage();    
        }
    }
    
    public static string getDmMessagesForUser(String recipientId, String caseId){
        
        List<Case_Communication__c> caseCommunicationList = new List<Case_Communication__c>();
        List<Case_Communication__c> caseCommunicationListToBeUpdated = new List<Case_Communication__c>();
        Map<String, List<Case_Communication__c>> communicationsOnPostByPostId = new Map<String, List<Case_Communication__c>>();
        Map<String, List<Case_Communication__c>> communicationsByThreadId = new Map<String, List<Case_Communication__c>>();
        Map<String, Case> caseByThreadId = new Map<String, Case>();
        Map<String, Case> caseBySenderId = new Map<String, Case>();
        Map<Case, List<Case_Communication__c>> communicationsByCase = new Map<Case, List<Case_Communication__c>>();
        Map<String, String> caseIdByPostId = new Map<String, String>();
        Map<String, String> communicationIdByPostId = new Map<String, String>();
        List<String> caseIds = new List<String>();
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer ' + pageaccessToken};
            String jsonResponse = '';
        InstaDMWrapper messageInfo = new InstaDMWrapper(); 
        List<String> senderIds = new List<String>();
        
        String endpointUrl = basicUrl + pageId + '/conversations?fields=message_count,messages{message,id,thread_id,created_time,from},id,can_reply,senders&user_id=' + recipientId;
        
        try{
            if(Test.isRunningTest()){
                jsonResponse = '{"id": "17841405793087218", "media_url": "https://www.example.com/image.jpg", "comments": { "data": [{"id": "17851087209098192", "text": "Awesome!", "username": "user1", "timestamp": "2023-07-29T12:40:00+0000"}] } }';
                messageInfo = (InstaDMWrapper) JSON.deserialize(jsonResponse, InstaDMWrapper.class);
            } else {
                HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
                String body = response.getBody();
                body = body.replaceAll('from','fromDetails');
                messageInfo = (InstaDMWrapper) JSON.deserialize(body, InstaDMWrapper.class);
            }
            
            if(messageInfo.data.size() > 0){
                //Getting the Sender ids..
                for(InstaDMWrapper.Data messageRec : messageInfo.data){
                    for(InstaDMWrapper.SenderData senderRec : messageRec.senders.data){
                        senderIds.add(senderRec.id);
                    }
                }
                
                List<Case> existingCases = [SELECT Id, Subject, record_changed__c, Description, User_ID__c, Post_Id__c FROM Case WHERE Id = :caseId];
                List<Case_Communication__c> communications = [SELECT Id, Activity_ID__c, Case__c, Case__r.User_ID__c FROM Case_Communication__c WHERE Case__c IN :existingCases];
                
                Map<String, List<String>> existingDmRecordsByCaseId = new Map<String, List<String>>();
                
                for(Case_Communication__c communication : communications){
                    if(existingDmRecordsByCaseId.containsKey(communication.Case__r.User_ID__c)){
                        existingDmRecordsByCaseId.get(communication.Case__r.User_ID__c).add(communication.Activity_ID__c);
                    } else {
                        existingDmRecordsByCaseId.put(communication.Case__r.User_ID__c, new List<String>{communication.Activity_ID__c});
                    }
                }
                
                if(existingCases.size() > 0){
                    for(Case caseRec : existingCases){
                        caseBySenderId.put(caseRec.User_ID__c , caseRec);    
                    }
                    
                    for(InstaDMWrapper.Data messageRec : messageInfo.data){
                        for(InstaDMWrapper.MessageData dmRec : messageRec.messages.data){
                            if(caseBySenderId.containsKey(dmRec.fromDetails.id)){
                                if(!existingDmRecordsByCaseId.get(dmRec.fromDetails.id).contains(dmRec.id)){
                                    Case_Communication__c communication = new Case_Communication__c();
                                    communication.Case__c = caseBySenderId.get(dmRec.fromDetails.id).Id;
                                    communication.Activity_Content__c = dmRec.message;
                                    communication.Activity_ID__c = dmRec.id;
                                    communication.Activity_User_ID__c = dmRec.fromDetails.id;
                                    communication.Activity_Type__c = 'DM';
                                    communication.Activity_Created_DateTime__c = getDateTime(String.valueOf(dmRec.created_time).removeEnd('+0000'));
                                    caseCommunicationList.add(communication);
                                }
                            }
                        }
                    }
                    
                    if(caseCommunicationList.size() > 0){
                        insert caseCommunicationList;
                    }
                }
            }
            
            return 'Success';
        } catch(Exception e){
            System.debug('Error message' + e.getMessage() + '@' + e.getLineNumber());
            return e.getMessage();    
        }
    }
    
    
    
    public static dateTime getDateTime(String strDatetime){
        List<String> datetimeParts = strDatetime.split('T');
        String datePart = datetimeParts[0];
        String timePart = datetimeParts[1];
        
        // Split the time component into hours, minutes, and seconds
        List<String> timeParts = timePart.split(':');
        Integer hours = Integer.valueOf(timeParts[0]);
        Integer minutes = Integer.valueOf(timeParts[1]);
        Integer seconds = Integer.valueOf(timeParts[2]);
        
        // Parse the date component
        List<String> dateParts = datePart.split('-');
        Integer year = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer day = Integer.valueOf(dateParts[2]);
        
        // Construct the DateTime object
        Datetime dt = Datetime.newInstance(year, month, day, hours, minutes, seconds).addminutes(330);
        return dt;
    }
}