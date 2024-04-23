/*
* Test Class name : instaComponentControllerTest
* created Date     : 29/07/2023
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class contains all the api's related to instagram.
*/
public class instaComponentController {
    
    //Getting the basic details from custom setting
    private static Instagram_Api_Details__c fap = Instagram_Api_Details__c.getInstance();
    
    private static final String CLIENT_ID        = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET          = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI           = fap.REDIRECT_URI__c;
    private static String accessToken            = fap.accessToken__c;
    private static String basicUrl               = fap.basicUrl__c;
    private static String businessUserId         = fap.businessUserId__c;
    
    
 @AuraEnabled
    public Static List<ReplyWrapperRecords> getRepliesDetails(String commentId){
        List<ReplyWrapperRecords> repliesWrapperList = new List<ReplyWrapperRecords>();
        //List<ReplyWrapperRecords> replyDataList = new List<ReplyWrapperRecords>();
        List<Case_Communication__c> postCommentDetails = [Select Activity_Content__c,Activity_ID__c,Activity_Author__c,Platform_URL__c,Activity_Created_DateTime__c,Replied_Activities__c from Case_Communication__c where Activity_ID__c =:commentId];
        
        if(postCommentDetails.size() > 0){
            try{
                String jsonString = postCommentDetails[0].Replied_Activities__c;
                if(jsonString != null){
                    // Parse the JSON-like string
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
                        repliesWrapperList.add(wrapperRecord);
                    }
                    return repliesWrapperList;
                }else{ 
                    return repliesWrapperList;  
                }
            }
            catch(exception e){
                system.debug('Error is '+e.getMessage());
                return repliesWrapperList;  
            }
        }else{
            
            return repliesWrapperList;  
        }
        
    }
    //This is being called on page load..
    @AuraEnabled
    public Static List<instaWrapper> getCaseDetails(String recordId){
        List<instaWrapper> instaWrapperList = new List<instaWrapper>();
        List<Case> CaseDetails = [Select id,subject,Post_Id__c,Description,Type_of_Post__c,Caption__c,POST_URL__c,
                                  (Select  Activity_ID__c,Activity_Created_DateTime__c,Activity_Content__c,Activity_Author__c,Platform_URL__c
                                    from Case_Communications__r ) from case where id = :recordId];
        
        for(Case caseRec : CaseDetails){
            try{
            if(caseRec.Case_Communications__r.size() > 0){
                for(Case_Communication__c pcRec : caseRec.Case_Communications__r ){
                        instaWrapper iw = new instaWrapper();
                        iw.comment = pcRec.Activity_Content__c;
                        iw.CommentedBy = pcRec.Activity_Author__c;
                        iw.PostUrl = pcRec.Platform_URL__c;
                        iw.CommentId = pcRec.Activity_ID__c;
                        iw.postDateTime = String.valueOf(pcRec.Activity_Created_DateTime__c);
                        iw.postType = caseRec.Type_of_Post__c;
                        iw.postCaption = caseRec.Description;
                        instaWrapperList.add(iw);
                    }
                }else{
                    instaWrapper iw = new instaWrapper();
                    iw.PostUrl = caseRec.POST_URL__c;
                    iw.postCaption = caseRec.Description;
                    iw.postType = caseRec.Type_of_Post__c;
                    instaWrapperList.add(iw);
                }
            }
             catch(exception e){
                system.debug('Error is '+e.getMessage());
                return instaWrapperList;  
            }
        }
        return instaWrapperList;
    }
    @AuraEnabled
    public Static Void getUpdatedComments(String recordId){
        system.debug('recordId=======>'+recordId);
        Case CaseRecord = [Select id , Post_Id__c from case where id = :recordId];
        List<instaWrapper> instaWrapperList = new List<instaWrapper>();
        InstagramUtilityClass.getMediaDetailsFromMediaId(CaseRecord.Post_Id__c);
        
    }
    @AuraEnabled
    public Static void replyToComment(String commentId,String commentMessage){
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
    
    public class instaWrapper{
        @AuraEnabled
        public String comment{get;set;}
        @AuraEnabled
        public String postDateTime{get;set;}
        @AuraEnabled
        public String postCaption{get;set;}
        @AuraEnabled
        public String postType{get;set;}
        @AuraEnabled
        public String CommentedBy {get;set;}
        @AuraEnabled
        public String PostUrl{get;set;}
        @AuraEnabled
        public String CommentId{get;set;}
    }
    
    public class ReplyWrapperRecords {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String postDate { get; set; }
        @AuraEnabled
        public String postTime { get; set; }
        @AuraEnabled
        public String text { get; set; }
        @AuraEnabled
        public String username { get; set; }
    }
}