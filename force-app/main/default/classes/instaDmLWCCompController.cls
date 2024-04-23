/* Test Class name : InstagramUtilityTest
* created Date     : 02/03/2024
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class contains all the api's related to instagram DM..
*/   
public class instaDmLWCCompController {
    private static Instagram_Api_Details__c fap         = Instagram_Api_Details__c.getInstance();
    private static String pageaccessToken               = fap.pageAccessToken__c;
    private static final String FB_GRAPH_API_BASE_URL = 'callout:meta';
    
    @AuraEnabled
    public Static List<instaDMWrapper> getInstaDmDetails(String recordId){
        system.debug('recordId==>'+recordId);
        List<instaDMWrapper> repliesWrapperList = new List<instaDMWrapper>();
        List<case> postCommentDetails = [Select User_Name__c,User_Id__c,Description,Post_Id__c,Created_DateTime__c,
                                         (Select Activity_Content__c  ,Activity_ID__c,Activity_Author__c ,Activity_User_ID__c,Activity_Type__c,
                                          Activity_Created_DateTime__c from Case_Communications__r order by Activity_Created_DateTime__c) from case 
                                         where id =:recordId order by Created_DateTime__c];
        if(postCommentDetails.size() > 0){
            try{
                for(case caseRec : postCommentDetails){
                    instaDMWrapper dmRec = new instaDMWrapper();
                    dmRec.text = caseRec.Description;
                    dmRec.sender = caseRec.User_Name__c;
                    dmRec.timestamp = String.valueOf(caseRec.Created_DateTime__c);
                    dmRec.senderId = caseRec.User_Id__c;
                    if(caseRec.User_Name__c == 'Sokultsokool'){
                        dmRec.isInbound = false;
                    }else{
                        dmRec.isInbound = true;
                    }
                    repliesWrapperList.add(dmRec);
                    for(Case_Communication__c postCommRec : caseRec.Case_Communications__r){
                        instaDMWrapper messageRec = new instaDMWrapper();
                        messageRec.text = postCommRec.Activity_Content__c ;
                        messageRec.sender = postCommRec.Activity_Author__c ;
                        messageRec.senderId = postCommRec.Activity_User_ID__c;
                        messageRec.timestamp = String.valueOf(postCommRec.Activity_Created_DateTime__c);
                        if(postCommRec.Activity_Author__c == 'Sokultsokool'){
                            messageRec.isInbound = false;
                        }else{
                            messageRec.isInbound = true;
                        }
                        repliesWrapperList.add(messageRec);
                    }
                }
                return repliesWrapperList;
            }
            catch(exception e){
                system.debug('Error is '+e.getMessage());
                return repliesWrapperList;  
            }
        }else{
            return repliesWrapperList;  
        }
    }
    
    @AuraEnabled
    public static void sendMessage(String recipientId, String messageText, String caseId) {        
        String apiUrl = FB_GRAPH_API_BASE_URL + '/me/messages?access_token='+pageaccessToken;
        // Construct the request body
        messageText = removeHTMLTags(messageText);
        Map<String, Object> requestBody = new Map<String, Object>{
            'recipient' => new Map<String, Object>{
                'id' => recipientId
                    },
                        'message' => new Map<String, Object>{
                            'text' => messageText
                                }
        };
            // Send the POST request
            HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(requestBody));
        
        HttpResponse response = new Http().send(request);
        System.debug('--- response: '+response.getBody());
        if (response.getStatusCode() != 200) {
            // Handle error response
            System.debug('Error sending message: ' + response.getBody());
        } else {
            try {
                Map<String,Object> responseMessage = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Case_Communication__c pc = new Case_Communication__c();
                pc.Case__c = caseId;
                pc.Activity_Content__c  = messageText;
                //pc.Case_Communication__c = parentCommentId;
                pc.Activity_ID__c = responseMessage.containsKey('message_id') ? (String)responseMessage.get('message_id') : '';
                pc.Sent_from_SFDC__c  = true;
                pc.Activity_Created_DateTime__c = system.now();
                pc.Activity_Author__c  = 'Kult App';
                insert pc;
                
                case caseRec = [Select id ,record_changed__c from case where id = : caseId];
                caseRec.record_changed__c = caseRec.record_changed__c ? true : false;
                new case(record_changed__c = true);
                System.debug('--- reply insert: '+ pc);
            }catch(DmlException e){
                System.debug('--- e.getmessage: '+e.getMessage());
                System.debug('--- e.getLineNo: '+e.getLineNumber());
            }
            // Message sent successfully
            System.debug('Message sent successfully');
        }
    }
    
    @AuraEnabled
    public static string refreshChat(String recipientId, String caseId) {
        try{
            InstaDmUtilityClass.getDmMessagesForUser(recipientId,caseId);
            return 'Success';
        }catch(exception e){
            system.debug('Error message'+e.getMessage()+'@'+e.getLineNumber());
            return e.getMessage(); 
        }
    }
    
    // Utility method to remove HTML tags from the comment message
    private static String removeHTMLTags(String commentText) {
        if(String.isBlank(commentText))
            return commentText;
        // Replace HTML tags with an empty string to remove them
        return commentText.replaceAll('<[^>]*>', '');
    }
    
    public class instaDMWrapper{
        @AuraEnabled
        public String text{get;set;}
        @AuraEnabled
        public String sender{get;set;}
        @AuraEnabled
        public String senderId{get;set;}
        @AuraEnabled
        public String timestamp{get;set;}
        @AuraEnabled
        public boolean isInbound{get;set;}
    }
    
}