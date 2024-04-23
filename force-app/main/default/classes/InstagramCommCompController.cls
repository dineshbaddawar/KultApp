/*
* Test Class name : InstagramCommCompControllerTest
* created Date     : 09/02/2024
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class contains all the api's related to instagram.
*/
public class InstagramCommCompController {
    //Getting the basic details from custom setting
    private static Instagram_Api_Details__c fap  = Instagram_Api_Details__c.getInstance();
    private static final String CLIENT_ID        = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET          = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI           = fap.REDIRECT_URI__c;
    private static String accessToken            = fap.accessToken__c;
    private static String basicUrl               = fap.basicUrl__c;
    private static String businessUserId         = fap.businessUserId__c;
    
    @AuraEnabled
    public Static List<ReplyWrapperRecords> getRepliesDetails(String recordId){
        List<ReplyWrapperRecords> repliesWrapperList = new List<ReplyWrapperRecords>();
        case caseRecDetails = [Select id , Post_Id__c ,Description , User_Name__c , POST_URL__c ,Post_Comments__c , Post_Case_Comments__c, Case_Communication__c , recordTypeId from case where id = :recordId];
        if(caseRecDetails != null){
            try{
                String jsonString = caseRecDetails.Post_Case_Comments__c;
                system.debug('jsonString'+jsonString);
                if(jsonString != null){
                    List<Map<String, String>> replyDataList = new List<Map<String, String>>();
                    Matcher matcher = Pattern.compile('\\[id=(\\d+), text=(.*?), timestamp=(.*?), username=(.*?)\\]').matcher(jsonString);
                    while (matcher.find()) {
                        Map<String, String> replyData = new Map<String, String>();
                        replyData.put('id', matcher.group(1));
                        replyData.put('text', matcher.group(2));
                        replyData.put('timestamp', matcher.group(3));
                        replyData.put('username', matcher.group(4));
                        replyDataList.add(replyData);
                    }
                    //List<ReplyWrapperRecords> wrapperRecordsList = new List<ReplyWrapperRecords>();
                    for (Map<String, String> replyData : replyDataList) {
                        ReplyWrapperRecords wrapperRecord = new ReplyWrapperRecords();
                        wrapperRecord.id = replyData.get('id');
                        wrapperRecord.text = replyData.get('text');
                        // Extract and format timestamp as needed
                        wrapperRecord.postDate = replyData.get('timestamp').split('T')[0].removeEnd('+0000');//Datetime.parse(replyData.get('timestamp')).format('yyyy-MM-dd');
                        wrapperRecord.postTime = replyData.get('timestamp').split('T')[1].removeEnd('+0000');//Datetime.parse(replyData.get('timestamp')).format('HH:mm:ss');
                        wrapperRecord.username = replyData.get('username');
                        wrapperRecord.commentDescription = caseRecDetails.Description;
                        wrapperRecord.commentedBy = caseRecDetails.User_Name__c;
                        wrapperRecord.postUrl = caseRecDetails.POST_URL__c;
                        wrapperRecord.mainCommentId = caseRecDetails.Post_Id__c;
                        repliesWrapperList.add(wrapperRecord);
                    }
                    return repliesWrapperList;
                }else{
                    ReplyWrapperRecords replyData = new ReplyWrapperRecords();
                    replyData.commentDescription = caseRecDetails.Description;
                    replyData.commentedBy = caseRecDetails.User_Name__c;
                    replyData.postUrl = caseRecDetails.POST_URL__c;
                    replyData.mainCommentId = caseRecDetails.Post_Id__c;
                    repliesWrapperList.add(replyData);
                    return repliesWrapperList;  
                }
            }
            catch(exception e){
                system.debug('Error '+e.getMessage() +'@ line' +e.getLineNumber());
                return repliesWrapperList;  
            }
        }else{
            ReplyWrapperRecords replyData = new ReplyWrapperRecords();
            replyData.commentDescription = caseRecDetails.Description;
            replyData.commentedBy = caseRecDetails.User_Name__c;
            replyData.postUrl = caseRecDetails.POST_URL__c;
            system.debug('replyData==>'+replyData);
            repliesWrapperList.add(replyData);
            return repliesWrapperList;  
        }
    }
    
    
    @AuraEnabled
    public Static void replyToCommentOnInsta(String commentId,String commentMessage){
        system.debug('commentId'+commentId);
        system.debug('commentMessage'+commentMessage);
        commentMessage = EncodingUtil.urlEncode(commentMessage, 'UTF-8');
        commentMessage = commentMessage.replaceAll(' ','%20');
        commentMessage = commentMessage.replaceAll('<[^>]+>','');
        
        String endpointUrl = basicUrl+commentId+'/replies?message='+commentMessage;
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            HttpResponse response = DynamicHttpCallout.makeHttpPOSTCallout(endpointUrl, queryParams, headers);
        system.debug('Response==>'+response.getBody());
        // Process the response
        if (response.getStatusCode() == 200) {
            system.debug('The Response is ==>'+response.getBody());
        }else{
            system.debug('The Failed Response is ==>'+response.getBody());
        }   
    }
    
    @AuraEnabled
    public Static Void getUpdatedComments(String recordId){
        system.debug('recordId=======>'+recordId);
        Case CaseRecord = [Select id , Post_Id__c,Post_Case_Comments__c from case where id = :recordId];
        InstagramCommCompController.getMediaIdFromCommentId(CaseRecord.Post_Id__c,CaseRecord);
    }
    
     //Pass this method the Comment id and the media id will be fetched.
    public static void getMediaIdFromCommentId(String commentId,Case caseRec){
        system.debug('commentId--->'+commentId);
        //commentId = '18118658203343238';
        List<Case> caseList = new List<Case>();
        String endpointUrl = basicUrl+commentId+'?fields=replies{text,username,timestamp,user},text,user,timestamp,username,media';
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            HttpResponse response = new HttpResponse();
        String body = '';
        if(test.isRunningTest()){
            body = '{"data":[{"id":"17841405793087218","username":"example_user","timestamp":"2023-07-29T12:34:56+0000","caption":"This is an amazing photo!","media_type":"IMAGE","media_url":"https://www.example.com/image.jpg","permalink":"https://www.instagram.com/p/ABC123/","comments_count":5,"comments":{"data":[{"id":"17851087209098192","text":"Awesome!","username":"user1","timestamp":"2023-07-29T12:40:00+0000"},{"id":"17851087209098193","text":"Great shot!","username":"user2","timestamp":"2023-07-29T12:42:30+0000"},{"id":"17851087209098194","text":"Beautiful!","username":"user3","timestamp":"2023-07-29T12:45:15+0000"},{"id":"17851087209098195","text":"Nice!","username":"user4","timestamp":"2023-07-29T12:50:20+0000"},{"id":"17851087209098196","text":"Love it!","username":"user5","timestamp":"2023-07-29T13:00:00+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/ABC123/comments?cursor=cursor_after"}}},{"id":"17841405793087219","username":"another_user","timestamp":"2023-07-29T14:30:45+0000","caption":"Sunset vibes!","media_type":"VIDEO","media_url":"https://www.example.com/video.mp4","permalink":"https://www.instagram.com/p/XYZ456/","comments_count":2,"comments":{"data":[{"id":"17851087209098197","text":"Amazing video!","username":"user6","timestamp":"2023-07-29T14:40:00+0000"},{"id":"17851087209098198","text":"Beautiful sunset!","username":"user7","timestamp":"2023-07-29T14:45:30+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/XYZ456/comments?cursor=cursor_after"}}}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/user123/media?cursor=cursor_after"}}';
        }else{
            response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
            body = response.getBody();
        }
        system.debug('Response==>'+response.getBody());
        
        InstaCommentWrapper jsonResponse = InstaCommentWrapper.parse(body);
        String mediaId = '';
        if(test.isRunningTest()){
            mediaId = '17977476455235820';
        }else{
            mediaId = jsonResponse.media.id;
            //caseRec.Post_Comments__c = string.valueOf(jsonResponse.replies);
            String commentReply = String.valueOf(jsonResponse.replies.data);
            commentReply = commentReply.replaceAll('cls_data','ReplyData');
            commentReply = commentReply.replaceAll('cls_data','data');
            commentReply = 'RepliesWrapper:[data='+commentReply + ']';
            system.debug('commentReply==>'+commentReply);
            caseRec.Post_Case_Comments__c = commentReply;
            update caseRec;
        }
        //getMediaDetailsFromMediaId(mediaId,caseRec);    
    }
    
    //Pass this method the media id and all the details related to post will be fetched for a post type case
    public static string getMediaDetailsFromMediaId(String mediaId,case CaseRec){
        
        String endpointUrl = basicUrl+mediaId+'?fields=media_url,comments_count,permalink,caption,media_type,shortcode,timestamp,username,comments{id,like_count,user,media,timestamp,username,replies{text,username,timestamp},text}';
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            String jsonResponse = '';    
        InstagramMediaResponseWrapper postInfo = new InstagramMediaResponseWrapper();   
        if(test.isRunningTest()){
            jsonResponse = '{"id": "17841405793087218", "media_url": "https://www.example.com/image.jpg", "comments": { "data": [{"id": "17851087209098192", "text": "Awesome!", "username": "user1", "timestamp": "2023-07-29T12:40:00+0000"}] } }';
            postInfo = (InstagramMediaResponseWrapper) JSON.deserialize(jsonResponse, InstagramMediaResponseWrapper.class);
        }else{
            HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
            postInfo = (InstagramMediaResponseWrapper) JSON.deserialize(response.getBody(), InstagramMediaResponseWrapper.class);
        }
        if(postInfo.comments != null){
            for(InstagramMediaResponseWrapper.cls_data postInfoRec : postInfo.comments.data){
                system.debug('string.valueOf(postInfoRec.replies)==>'+string.valueOf(postInfoRec.replies));
                CaseRec.Post_Case_Comments__c = string.valueOf(postInfoRec.replies);
            }
        }
        update CaseRec;
        return 'Success';
        
    }

    public class ReplyWrapperRecords {
        @AuraEnabled
        public String commentDescription { get; set; }
        @AuraEnabled
        public String commentedBy { get; set; }
        @AuraEnabled
        public String mainCommentId { get; set; }
        @AuraEnabled
        public String postUrl { get; set; }
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String postDate { get; set; }
        @AuraEnabled
        public String postTime { get; set; }
        @AuraEnabled
        public String text { get; set; }
        @AuraEnabled
        public String replyMessage { get; set; }
        @AuraEnabled
        public String username { get; set; }
    }
}