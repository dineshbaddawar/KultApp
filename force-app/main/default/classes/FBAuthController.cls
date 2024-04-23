public class FBAuthController {
    // Replace these with your actual Facebook App ID, App Secret, and Redirect URI
    /*private static final String APP_ID;
    private static final String APP_SECRET;
    private static final String REDIRECT_URI;
    private static final String API_VERSION;
    private static final String ACCESS_TOKEN;*/
    // Scopes required for user access token
    private static final String SCOPE = 'openid';//'manage_pages,pages_show_list,pages_messaging_subscriptions,pages_read_engagement,pages_manage_metadata,pages_manage_engagement,pages_read_user_content';
    private static final String FB_GRAPH_API_BASE_URL = 'callout:meta';
    private static String PAGE_NAME;
	static Map<String,PageInfo>  myPagesMap = new Map<String,PageInfo>();
    static Map<String,Meta_App_Credentials__c> APP_CREDS_MAP = new Map<String,Meta_App_Credentials__c>();
    static {
        //Meta_App_Credentials__c credentials = Meta_App_Credentials__c.getAll() != null ? Meta_App_Credentials__c.getAll().get('live') : null; //TODO: make this dynamic
        APP_CREDS_MAP = Meta_App_Credentials__c.getAll();
        System.debug('--- APP_CREDS_MAP '+APP_CREDS_MAP);
        /* if(credentials != null) {
            APP_ID = credentials.App_Id__c;
            APP_SECRET = credentials.App_Secret__c;
            REDIRECT_URI = credentials.Redirect_URI__c;
            //API_VERSION = credentials.API_Version__c;
            ACCESS_TOKEN = credentials.Access_Token__c;
            PAGE_NAME = credentials.Page_Name__c;
        } */
    }

    /*@AuraEnabled(cacheable = true)
    public static String initiateFacebookLogin() {
        
        String responseType = 'code';
        String graphApiVersion = 'v17.0'; // Replace with your desired API version
        String baseLoginUrl = 'https://www.facebook.com/' + graphApiVersion + '/dialog/oauth';
        
        
        String codeVerifier = 'asdasdasdsdasdakfyhkjlafhjLFK!';

        
        Blob codeVerifierBlob = Blob.valueOf(codeVerifier);
        Blob codeChallengeBlob = Crypto.generateDigest('SHA-256', codeVerifierBlob);
        String codeChallenge = base64UrlEncode(codeChallengeBlob);

        String nonce = 'asadasdasd';        
        String state = 'asdasdasd';

        String loginDialogUrl = baseLoginUrl + '?response_type=' + EncodingUtil.urlEncode(responseType, 'UTF-8') +
                            '&client_id=' + EncodingUtil.urlEncode(APP_ID, 'UTF-8') +
                            '&redirect_uri=' + EncodingUtil.urlEncode(REDIRECT_URI, 'UTF-8') +
                            '&scope=' + EncodingUtil.urlEncode(SCOPE, 'UTF-8') +
                            '&code_challenge_method=S256' +
                            '&code_challenge=' + EncodingUtil.urlEncode(codeChallenge, 'UTF-8') +
                            '&nonce=' + EncodingUtil.urlEncode(nonce, 'UTF-8') +
                            '&state=' + EncodingUtil.urlEncode(state, 'UTF-8');    


        //c35b532f78fa602cc906d82f83d6ba84
        

        return loginDialogUrl;
    }*/

    
    /*public static String base64UrlEncode(Blob input) {
        String encodedString = EncodingUtil.base64Encode(input);
        encodedString = encodedString.replace('+', '-').replace('/', '_').replace('=', '');
        return encodedString;
    }*/

    public static String getUserAccessToken(String code, String config) {

        if(String.isBlank(config) || !APP_CREDS_MAP.containsKey(config)) {
            System.debug('--- invalid params: ');
            return '';
        }
        config = config.toLowerCase();
        Meta_App_Credentials__c credentials = APP_CREDS_MAP.get(config);
        String tokenEndpoint = FB_GRAPH_API_BASE_URL + '/oauth/access_token';
        String params = 'client_id=' + EncodingUtil.urlEncode(credentials.App_Id__c, 'UTF-8') +
                        '&client_secret=' + EncodingUtil.urlEncode(credentials.App_Secret__c, 'UTF-8') +
                        '&redirect_uri=' + EncodingUtil.urlEncode(credentials.Redirect_URI__c, 'UTF-8') +
                        '&code=' + EncodingUtil.urlEncode(code, 'UTF-8');

        HttpRequest request = new HttpRequest();
        request.setEndpoint(tokenEndpoint + '?' + params);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return (String) responseData.get('access_token');
        } else {
            // Handle error response
            System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug('Error Response Body: ' + response.getBody());
            return null;
        }
    }

    public static String getAppAccessToken(String config) {
        if(String.isBlank(config) || !APP_CREDS_MAP.containsKey(config)) {
            System.debug('--- invalid params: ');
            return '';
        }

        Meta_App_Credentials__c credentials = APP_CREDS_MAP.get(config);
        String appAccessToken = credentials.App_Id__c + '|' + credentials.App_Secret__c;
        return appAccessToken;
    }

    private static Map<String, PageInfo> getPagesMap(String config) {

        if(String.isBlank(config) || !APP_CREDS_MAP.containsKey(config)) {
            System.debug('--- invalid params: ');
            return null;
        }

        Meta_App_Credentials__c credentials = APP_CREDS_MAP.get(config);
        PAGE_NAME = credentials.Page_Name__c != null ? credentials.Page_Name__c.toLowerCase() : credentials.Page_Name__c;
        // Prepare the API endpoint URL to get the user's pages
        String apiEndpoint = FB_GRAPH_API_BASE_URL + '/me/accounts?access_token=' + credentials.Access_Token__c;

        // Make an HTTP GET request to the Facebook Graph API
        HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(apiEndpoint, null, null);

        if (response.getStatusCode() == 200) {
            // Parse the JSON response to extract the list of pages
            System.debug('--- page tokens: '+response.getBody());
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> pageDataList = (List<Object>) jsonResponse.get('data');

            // Convert the page data into a list of PageInfo objects
            Map<String, PageInfo> pagesMap = new Map<String, PageInfo>();
            for (Object pageData : pageDataList) {
                Map<String, Object> pageMap = (Map<String, Object>) pageData;
                PageInfo pageInfo = new PageInfo(
                    (String) pageMap.get('id'),
                    (String) pageMap.get('name'),
                    (String) pageMap.get('access_token'),
                    (List<Object>) pageMap.get('tasks')
                );
                pagesMap.put(((String) pageMap.get('name')).toLowerCase(), pageInfo);
            }

            return pagesMap;
        } else {
            // Handle the case when the API call fails
            System.debug('Error getting pages list. Response status code: ' + response.getStatusCode());
            return null;
        }
    }

    public static String getPageAccessToken(String config) {
        if(myPagesMap == null || myPagesMap.isEmpty()) {
            myPagesMap = getPagesMap(config);
        }
        PAGE_NAME = 'Lets Hyphen';
        if(myPagesMap.containsKey(PAGE_NAME)) {
            return myPagesMap.get(PAGE_NAME).accessToken;
        }
        System.debug('--- pagemap.keyset: '+myPagesMap.keySet());
        System.debug('--- page access token no found for mentioned page: '+PAGE_NAME);
        return null;
    }

    public static String getPageId(String config) {
        if(myPagesMap == null || myPagesMap.isEmpty()) {
            myPagesMap = getPagesMap(config);
        }
        if(myPagesMap.containsKey(PAGE_NAME)) {
            return myPagesMap.get(PAGE_NAME).id;
        }
        System.debug('--- page access token no found for mentioned page: '+PAGE_NAME);
        return null;
    }

    

    public static void subscribeToPageWebhook(String config) {
        String graphApiVersion = 'v17.0';
        String subscribeEndpoint = FB_GRAPH_API_BASE_URL + '/' + getPageId(config) + '/subscribed_apps';

        String callbackUrl = 'YOUR_WEBHOOK_CALLBACK_URL'; // Replace with your webhook's callback URL
        String subscribedFields = 'feed,mention,conversations,message_mention,messages'; // Add additional fields as needed (comma-separated)

        String params = 'access_token=' + EncodingUtil.urlEncode(getPageAccessToken(config), 'UTF-8') +
                        '&subscribed_fields=' + EncodingUtil.urlEncode(subscribedFields, 'UTF-8') +
                        '&callback_url=' + EncodingUtil.urlEncode(callbackUrl, 'UTF-8');

        HttpRequest request = new HttpRequest();
        request.setEndpoint(subscribeEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(params);

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('--- response'+response.getBody());
        if (response.getStatusCode() == 200) {
            System.debug('Webhook subscription successful!');
        } else {
            // Handle error response
            System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug('Error Response Body: ' + response.getBody());
        }
    }

    // Utility method to remove HTML tags from the comment message
    private static String removeHTMLTags(String commentText) {
        if(String.isBlank(commentText))
            return commentText;
        // Replace HTML tags with an empty string to remove them
        return commentText.replaceAll('<[^>]*>', '');
    }

    @AuraEnabled
    public static void postCommentToFB(String config, String caseId, String commentId, String parentSfId, String commentText) {
        System.debug('--- postId '+commentId);
        System.debug('--- commentText '+commentText);
        System.debug('--- parentSfId '+parentSfId);
        System.debug('--- brand '+config);

        if(String.isBlank(config)){
            System.debug('--- invalid config ' +config);
            return;
        }
            
        config = config.toLowerCase();

        // Prepare the API endpoint URL to post a comment on the specified post
        String apiEndpoint = FB_GRAPH_API_BASE_URL + '/' + commentId + '/comments';//?message=' + commentText + '&access_token='+getPageAccessToken();

        // Prepare the parameters for the comment post request
       /*  Map<String, String> parameters = new Map<String, String>();
        parameters.put('access_token', getPageAccessToken()); */
        //parameters.put('message', commentText);
        System.debug(apiEndpoint);
        commentText = removeHTMLTags(commentText);
        Map<String, String> parameters = new Map<String, String>();
        parameters.put('access_token', getPageAccessToken(config));
        parameters.put('message', commentText);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(buildQueryString(parameters));

        HttpResponse response = new Http().send(request);
        String responseJSON = response.getBody();
        System.debug('--- response body: '+responseJSON);

        if (response.getStatusCode() == 200) {
            //Not required - due to circular dependency
            /* Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(responseJSON);
            Post_Comments__c pc = new Post_Comments__c();
            pc.Case_Communication__c = parentSfId;
            pc.Comment_Id__c = (String)responseMap.get('id');
            pc.Activity_Content__c = commentText;
            pc.Activity_Author__c = PAGE_NAME;
            pc.Case__c = caseId;
            pc.Activity_Created_DateTime__c = String.valueOf(getTimeInUnix());
            try{
              insert pc;
            }catch(DMLException e) {
              System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
              System.debug('Error Response Body: ' + response.getBody());
            } */

            System.debug('Comment posted successfully.');
        } else {
            System.debug('Error posting comment. Response status code: ' + response.getStatusCode());
        }
    }

    @TestVisible
    private static Long getTimeInUnix() {
        DateTime now = DateTime.now();
        return now.getTime() / 1000;
    }

     // Helper method to build query string from a map of parameters
    @TestVisible
    private static String buildQueryString(Map<String, String> parameters) {
        List<String> keyValuePairs = new List<String>();
        for (String key : parameters.keySet()) {
            String value = parameters.get(key);
            keyValuePairs.add(key + '=' + EncodingUtil.urlEncode(value, 'UTF-8'));
        }
        return String.join(keyValuePairs, '&');
    }

    public class PageInfo {
        public String id { get; private set; }
        public String name { get; private set; }
        public String accessToken { get; private set; }
        public List<Object> tasks { get; private set; }

        public PageInfo(String id, String name, String accessToken, List<Object> tasks) {
            this.id = id;
            this.name = name;
            this.accessToken = accessToken;
            this.tasks = tasks;
        }
    }

    @AuraEnabled
    public Static FacebookWrapper getCaseDetails(String recordId){
        
        List<Case> CaseDetails = [Select id,subject,Description,Caption__c,Post_Id__c,Brand__c,Post_Attachment_Url__c,Post_Url__c,(Select Id,Activity_Type__c,Activity_Content__c,Activity_ID__c,Replied_Activities__c,Case__c,Activity_Author__c,Platform_URL__c,Activity_Created_DateTime__c,CreatedDate FROM Case_Communications__r WHERE Sent_from_SFDC__c = false ORDER BY CreatedDate DESC LIMIT 100) from case where id = :recordId];
        
        FacebookWrapper respWrapper = new FacebookWrapper();

        Map<Id, CommentWrapper> commentWrapperMap = new Map<Id,CommentWrapper>();

        for(Case caseRec : CaseDetails){
            respWrapper = new FacebookWrapper(caseRec.Description, caseRec.Post_Id__c, caseRec.Brand__c,caseRec.Post_Attachment_Url__c,caseRec.Post_Url__c);
            for(Case_Communication__c pcRec : caseRec.Case_Communications__r ) {
                 CommentWrapper iw = new CommentWrapper();
                iw.sf_id = pcRec.Id;
                iw.comment = pcRec.Activity_Content__c;
                iw.CommentedBy = pcRec.Activity_Author__c;
                iw.PostUrl = pcRec.Platform_URL__c;
                iw.CommentId = pcRec.Activity_ID__c;
                iw.messageType = pcRec.Activity_Type__c;
                iw.postTime = pcRec.CreatedDate + '';//!String.isBlank(pcRec.Activity_Created_DateTime__c) ? getFormattedTimeByUnixTimeStamp(pcRec.Activity_Created_DateTime__c) : '';
                iw.relURL = '/lightning/r/Case_Communication__c/'+ pcRec.Id +'/related/Message_Attachments__r/view';
                commentWrapperMap.put(pcRec.Id, iw);
            }
        }

        if(!commentWrapperMap.isEmpty()) {
            List<AggregateResult> attCountResult = [SELECT Count(Id),Case_Communication__c FROM Message_Attachment__c WHERE Case_Communication__c IN: commentWrapperMap.keySet() GROUP BY Case_Communication__c];
            System.debug('--- ares: '+attCountResult);
            for(AggregateResult ag: attCountResult) {
                
                if(commentWrapperMap.containsKey((Id)ag.get('Case_Communication__c'))) {
                    commentWrapperMap.get((Id)ag.get('Case_Communication__c')).numOfAttachments = (Integer)ag.get('expr0');
                }
            }
        }
        System.debug('--- idToCommentMap: '+commentWrapperMap);
        respWrapper.setComments(commentWrapperMap.values());
        system.debug('respWrapper------------>'+respWrapper);
        return respWrapper;
    }

    @testVisible
    private static String getFormattedTimeByUnixTimeStamp(String unixTimestampStr) {
        if(String.isBlank(unixTimestampStr))
            return '';
        Long unixTimestamp = Long.valueOf(unixTimestampStr);
        DateTime dt = DateTime.newInstance(unixTimestamp * 1000);

        return dt.format('dd/mm/yyyy hh:mm a'); // Format as desired
    }

    @AuraEnabled
    public static List<RepledPostComments> getRepliesDetails(String commentId){
        System.debug('--- commentId:'+commentId);
        List<Case_Communication__c> postCommentsList = [Select Activity_Content__c,Activity_ID__c,Activity_Author__c,Platform_URL__c,Activity_Created_DateTime__c,CreatedDate FROM Case_Communication__c WHERE Case_Communication__r.Activity_ID__c =:commentId AND Sent_from_SFDC__c = true ORDER BY CreatedDate DESC];

        List<RepledPostComments> returnList = new List<RepledPostComments>();
        for(Case_Communication__c pc: postCommentsList) {
            returnList.add(new RepledPostComments(pc.Activity_Content__c, pc.Activity_ID__c, pc.Activity_Author__c, pc.Platform_URL__c, pc.CreatedDate + ''));
        }
        return returnList;
    }

    @AuraEnabled
    public static void sendMessage(String config, String recipientId, String messageText, String caseId, String parentCommentId) {
        System.debug('--- caseId: '+caseId);
        System.debug('--- config: '+config);
        if(String.isBlank(config)) {
            System.debug('--- invalid config: '+config);
            return;
        }
        config = config.toLowerCase();
        // Construct the API endpoint URL
        String apiUrl = FB_GRAPH_API_BASE_URL + '/me/messages?access_token='+getPageAccessToken(config);

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
                pc.Activity_Content__c = messageText;
                pc.Case_Communication__c = parentCommentId;
                pc.Activity_ID__c = responseMessage.containsKey('message_id') ? (String)responseMessage.get('message_id') : '';
                pc.Sent_from_SFDC__c = true;
                pc.Activity_Author__c = PAGE_NAME;
                insert pc;
                System.debug('--- reply insert: '+ pc);
            }catch(DmlException e){
                System.debug('--- e.getmessage: '+e.getMessage());
                System.debug('--- e.getLineNo: '+e.getLineNumber());
            }
            // Message sent successfully
            System.debug('Message sent successfully');
        }
    }

    public class FacebookWrapper {

        @auraEnabled
        public string description = '';

        @AuraEnabled
        public String recepientId = '';

        @AuraEnabled
        public String brand = '';
        
        @AuraEnabled
        public String merdidaUrl='';

        @AuraEnabled
        public String PostUrl='';

        @AuraEnabled
        public List<CommentWrapper> commentWrapperList = new List<CommentWrapper>();

        FacebookWrapper(){}
        
        public void addComment(CommentWrapper commentWrapper) {
            this.commentWrapperList.add(commentWrapper);
        }

        public void setComments(List<CommentWrapper> commentWrapperList) {
            this.commentWrapperList = commentWrapperList;
        }

        public FacebookWrapper(String description, String recepientId, String brand,String merdidaUrl,String PostUrl) {
            this.description = description;
            this.recepientId = recepientId;
            this.brand = brand;
            this.merdidaUrl = merdidaUrl;
            this.PostUrl = PostUrl;
        }
        
    }


    public class CommentWrapper {
        @AuraEnabled
        public String sf_id{get;set;}
        @AuraEnabled
        public String comment{get;set;}
        @AuraEnabled
        public String postTime{get;set;}
        @AuraEnabled
        public String CommentedBy {get;set;}
        @AuraEnabled
        public String PostUrl{get;set;}
        @AuraEnabled
        public String CommentId{get;set;}
        @AuraEnabled
        public Integer numOfAttachments {get;set;}
        @AuraEnabled
        public String messageType {get;set;}
        @AuraEnabled
        public String relURL {get;set;}
        @AuraEnabled
        public String comment_case{get;set;}
        @AuraEnabled
        public String comment_case_number{get;set;}
        
        CommentWrapper() {
            this.numOfAttachments = 0;
        }
    }

    public class RepledPostComments {
        @AuraEnabled
        public String comment;
        @AuraEnabled
        public String comment_id;
        @AuraEnabled
        public String commented_by;
        @AuraEnabled
        public String post_url;
        @AuraEnabled
        public String post_comment_time;

        public RepledPostComments(String comment, String Comment_id, String commented_by, String post_url, String post_comment_time) {
            this.comment = comment;
            this.comment_id = Comment_id;
            this.commented_by = commented_by;
            this.post_url = post_url;
            this.post_comment_time = post_comment_time;
        }
    }

}





/*
* {
  "data": [
    {
      "access_token": "EAAKJz6xiZC6gBO1rQnXmAMvnfa6rhdylyAldc3EPGqsvsScpsAe8ZBvEu0QrfxwMZBTSgANwq1vpp9BLXIrwbhGbl0cZBX9b3RormsspVZBBaDXWHaKAIYNF4iilwZAbtfDb1IZB8a8ORjyXRjCLCiPZAZAI8FJ50rfMgdzQWXyLWu6sp8fbUaKcUViPboZBLlnvcNJ5ZChLo2iOwgcx3pSnzZCwwyIZD",
      "category": "E-commerce website",
      "category_list": [
        {
          "id": "1756049968005436",
          "name": "E-commerce website"
        }
      ],
      "name": "Test Salesforce Integration",
      "id": "103319499517877",
      "tasks": [
        "ADVERTISE",
        "ANALYZE",
        "CREATE_CONTENT",
        "MESSAGING",
        "MODERATE",
        "MANAGE"
      ]
    },
    {
      "access_token": "EAAKJz6xiZC6gBO3H6Vc5glZBpUB8AIi4iXRe0Ft40tv04QdsFvYxaXLfTPUM7cXO15gCOzj9IQe7I7fFtxgDNXZAG7WSxVlsclskbKnEcZB5q4ykSPqLNwAdTU2eYmKMud0wwELlLoUDtYWixGgnq8DD1ZBn3lIfWcB2E2uC9aZCLZC0o5q7Ry7DijJOgUK1JGhFVHxY1MCTUU4r3jDP03BorAZC",
      "category": "Community Organization",
      "category_list": [
        {
          "id": "152880021441864",
          "name": "Community Organization"
        }
      ],
      "name": "Kya Tum Mantally The Sick Ho My Buoy?",
      "id": "452266158177799",
      "tasks": [
        "ADVERTISE",
        "ANALYZE",
        "CREATE_CONTENT",
        "MESSAGING",
        "MODERATE",
        "MANAGE"
      ]
    },
    {
      "access_token": "EAAKJz6xiZC6gBOZBtiMl8LMDKZBKT2Tkti9KYMfJbIYEWxJiHUrJloYgyVXkI5FsFI1yYPja024kZAO2XmOmRfcBhcOEYIOX0w3dyCf3pLC29ZBcxoNuz1udk0V9IXZAPZAGWnpp6ryxweCOjdYb9PwjdH4JUSvJmAlmRMae2VRzy36JqMZAq5Yl63kIe5m8TNZA9T8ZBF3lGrnZCjWoVcZCz6QCKPVp",
      "category": "Drug Addiction Treatment Center",
      "category_list": [
        {
          "id": "1618392255156255",
          "name": "Drug Addiction Treatment Center"
        }
      ],
      "name": "Budy buildur",
      "id": "584221768332627",
      "tasks": [
        "ADVERTISE",
        "ANALYZE",
        "CREATE_CONTENT",
        "MESSAGING",
        "MODERATE"
      ]
    },
    {
      "access_token": "EAAKJz6xiZC6gBOxYzTd7BXZCNneQUjyUvrnlT2amiyxhFZBUMmLdtvqTIB32vcZCeVPeoSW7DUTOURy19tpenyCuYBixGdaHxLIz1cydvjTCLsZC8DIYcecuA2B18z96ZAKCmMmfpkpOoaZBa8Te29XvUCIcRs6rnUsVxAVyj11ZBoMv7sFSC1Tb8sQHdARJT1gkFhZC1yeInGmQVLZBC3onlmhDkZD",
      "category": "Community",
      "category_list": [
        {
          "id": "2612",
          "name": "Community"
        }
      ],
      "name": "RTR 180",
      "id": "262437830480049",
      "tasks": [
        "ADVERTISE",
        "ANALYZE",
        "CREATE_CONTENT",
        "MESSAGING",
        "MODERATE",
        "MANAGE"
      ]
    }
  ],
  "paging": {
    "cursors": {
      "before": "QVFIUkxlbTNqOWRycENrUkJFd0JrREI5enpiRnoyMjI3VU04M2pQcVp3Wk4wdWNlTVF6bXNQOTlkRGp2djgtSmlWNHJsa1JHYTlYVDVEeVFEeFZAwb1daYktn",
      "after": "QVFIUml1RjlOSmtCR1Myc1pST2hKcFZAFMk1yRC1MdUhhZAHIwTzgydjFzbWs2TG1abWxKMXZA5c09kcEpQdnROZATVGcDQ5VzYyQlliODc4MnRqa25fa1diejhB"
    }
  }
}
**/