/* Test Class name : InstagramUtilityTest
* created Date     : 02/03/2024
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class contains all the api's related to instagram DM..
*/   
public class instaDmLWCController {
    private static Instagram_Api_Details__c fap         = Instagram_Api_Details__c.getInstance();
    private static String pageaccessToken               = fap.pageAccessToken__c;
    private static final String FB_GRAPH_API_BASE_URL = 'callout:meta';
    
    @AuraEnabled
    public Static List<instaDMWrapper> getInstaDmDetails(String recordId){
        List<instaDMWrapper> repliesWrapperList = new List<instaDMWrapper>();
        //List<ReplyWrapperRecords> replyDataList = new List<ReplyWrapperRecords>();
        /*List<case> postCommentDetails = [Select Related_to__c,User_Id__c,Description,Post_Id__c,Created_DateTime__c,(Select Activity_Content__c ,Comment_Id__c,Activity_Author__c,User_Id__c,Type__c,Created_DateTime__c from post_comments__r order by Created_DateTime__c) from case where id =:recordId order by Created_DateTime__c];
        
        if(postCommentDetails.size() > 0){
            try{
                for(case caseRec : postCommentDetails){
                    instaDMWrapper dmRec = new instaDMWrapper();
                    dmRec.text = caseRec.Description;
                    dmRec.sender = caseRec.Related_to__c;
                    dmRec.timestamp = String.valueOf(caseRec.Created_DateTime__c);
                    dmRec.senderId = caseRec.User_Id__c;
                    if(caseRec.Related_to__c == 'Lets Hyphen'){
                        dmRec.type = 'outbound';
                    }else{
                        dmRec.type = 'inbound';
                    }
                    repliesWrapperList.add(dmRec);
                    for(post_comments__c postCommRec : caseRec.post_comments__r){
                        instaDMWrapper messageRec = new instaDMWrapper();
                        messageRec.text = postCommRec.Activity_Content__c;
                        messageRec.sender = postCommRec.Activity_Author__c;
                        messageRec.senderId = postCommRec.User_Id__c;
                        messageRec.timestamp = String.valueOf(postCommRec.Created_DateTime__c);
                        if(postCommRec.Activity_Author__c == 'Lets Hyphen'){
                            messageRec.type = 'outbound';
                        }else{
                            messageRec.type = 'inbound';
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
        }*/
        return repliesWrapperList;  
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
                /*Post_Comments__c pc = new Post_Comments__c();
                pc.Case__c = caseId;
                pc.Activity_Content__c = messageText;
                //pc.Case_Communication__c = parentCommentId;
                pc.Comment_Id__c = responseMessage.containsKey('message_id') ? (String)responseMessage.get('message_id') : '';
                pc.Sent_from_SFDC__c = true;
                pc.Created_DateTime__c = system.now();
                pc.Activity_Author__c = 'Lets Hyphen';
                insert pc;*/
                //System.debug('--- reply insert: '+ pc);
            }catch(DmlException e){
                System.debug('--- e.getmessage: '+e.getMessage());
                System.debug('--- e.getLineNo: '+e.getLineNumber());
            }
            // Message sent successfully
            System.debug('Message sent successfully');
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
        public String type{get;set;}
    }
    
    
}