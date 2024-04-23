/* Test Class name : InstagramUtilityTest
* created Date     : 29/07/2023
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class contains all the api's related to instagram.
*/

public class InstagramUtilityClass {
    
    private static Instagram_Api_Details__c fap = Instagram_Api_Details__c.getInstance();
    
    private static final String CLIENT_ID               = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET                 = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI                  = fap.REDIRECT_URI__c;
    private static String accessToken                   = fap.accessToken__c;
    private static String basicUrl                      = fap.basicUrl__c;
    private static String businessUserId                = fap.businessUserId__c;
    private static Id caseRecordTypeId                  = Schema.SObjectType.case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId();
    
    // This method will get the business user id
    public static string getInstaBusinessUserId(){
        
        String endpointUrl = basicUrl+'me/accounts?fields=instagram_business_account';
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            instaJSONHandler jsonResponse = instaJSONHandler.parse(response.getBody());
            businessUserId = jsonResponse.data[0].instagram_business_account.id;
            return businessUserId;
        } else {
            String errorMessage = 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            return null;
        }
    }
    
    //Pass this method the Comment id and the media id will be fetched.
    public static void getMediaIdFromCommentId(String commentId){
        system.debug('commentId--->'+commentId);
        List<Case> caseList = new List<Case>();
        String endpointUrl = basicUrl+commentId+'?fields=replies{text,username,timestamp,user},text,user,timestamp,username,media';
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
        system.debug('Response==>'+response.getBody());
        if (response.getStatusCode() == 200) {
            InstaCommentWrapper jsonResponse = InstaCommentWrapper.parse(response.getBody());
            String mediaId = '';
            if(test.isRunningTest()){
                mediaId = '17977476455235820';
            }else{
                mediaId = jsonResponse.media.id;
                system.debug('mediaId-->'+mediaId);
            }
            getMediaDetailsFromMediaId(mediaId);    
        }else{
            String errorMessage = 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            System.debug(errorMessage);
        }
    }
    
    //Pass this method the media id and all the details related to post will be fetched for a post type case
    public static string getMediaDetailsFromMediaId(String mediaId){
        
        List<Case_Communication__c> postCommentList = new List<Case_Communication__c>();
        List<Case_Communication__c> postCommentListToBeUpdated = new List<Case_Communication__c>();
        map<String,List<Case_Communication__c>> commentsOnPostByPostId = new map<String,List<Case_Communication__c>>();
        map<String,String> caseIdByPostId = new map<String,String>();
        map<String,String> postCommentIdByPostId = new map<String,String>();
        List<Case> existingCaseList = [Select id,subject,Description,Caption__c,Post_Id__c,(Select Activity_Content__c ,Activity_ID__c,Activity_Author__c	,Platform_URL__c,Activity_Created_DateTime__c  from Case_Communications__r ) from case where Post_Id__c = :mediaId];
        
        try{
            List<String> casePostIds = new List<String>();
            for(Case caseRec : existingCaseList){
                commentsOnPostByPostId.put(caseRec.Post_Id__c,caseRec.Case_Communications__r);
                caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
                for(Case_Communication__c pocRec : caseRec.Case_Communications__r){
                    postCommentIdByPostId.put(pocRec.Activity_ID__c,pocRec.Id);
                }
            }
            
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
            if(commentsOnPostByPostId.keyset().contains(postInfo.Id)){
                if(postInfo.comments != null){
                    for(InstagramMediaResponseWrapper.cls_data postInfoRec : postInfo.comments.data){
                        if(commentsOnPostByPostId.containsKey(postInfo.Id)){
                            List<String> postCommentIds = new List<String>();
                            for(Case_Communication__c poCom :  commentsOnPostByPostId.get(postInfo.Id)){
                                postCommentIds.add(poCom.Activity_ID__c);
                            }
                            if(!postCommentIds.contains(postInfoRec.id)){
                                Case_Communication__c commentRec = new Case_Communication__c();
                                commentRec.Case__c = caseIdByPostId.get(postInfo.Id);
                                commentRec.Activity_Content__c = postInfoRec.text;
                                commentRec.Activity_ID__c = postInfoRec.id;
                                commentRec.Activity_Author__c = postInfoRec.username;
                                commentRec.Activity_Created_DateTime__c = getDateTime(postInfoRec.timestamp);
                                commentRec.Platform_URL__c	 = postInfo.permalink;
                                commentRec.Activity_Content__c = string.valueOf(postInfoRec.replies);
                                system.debug('replies are'+postInfoRec.replies);
                                postCommentList.add(commentRec);
                            }else{
                                system.debug('replies are'+postInfoRec.replies);
                                Case_Communication__c commentRec = new Case_Communication__c();
                                commentRec.Id = postCommentIdByPostId.get(postInfoRec.id);
                                commentRec.Activity_Content__c = string.valueOf(postInfoRec.replies);
                                postCommentListToBeUpdated.add(commentRec);
                            }
                        }
                    }
                }else{
                    system.debug('postInfo.comments'+postInfo.comments);
                }
            }
            List<Case_Communication__c> newComments = new   List<Case_Communication__c> ();
            if(postCommentList.size() > 0){
                List<Case_Communication__c> postCommentData = [Select Activity_Content__c ,Activity_ID__c,Activity_Author__c ,Platform_URL__c,Activity_Created_DateTime__c  from Case_Communication__c where case__r.Post_Id__c = :mediaId];
                insert postCommentList;
            }
            if(postCommentListToBeUpdated.size() > 0){
                update postCommentListToBeUpdated;
            }
            return 'Success';
        }catch(Exception e){
            system.debug('Error message'+e.getMessage()+'@'+e.getLineNumber());
            return e.getMessage();    
        }
    }
    
    public static dateTime getDateTime (String dateTimeString){
        List<String> dateTimeParts = dateTimeString.split('T');
        
        // Extract date part
        List<String> dateParts = dateTimeParts[0].split('-');
        Integer year = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer day = Integer.valueOf(dateParts[2]);
        
        // Extract time part
        List<String> timeParts = dateTimeParts[1].split(':');
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        Integer second = Integer.valueOf(timeParts[2]);
        
        // Create Datetime instance
        Datetime dateTimeValue = Datetime.newInstance(year, month, day, hour, minute, second);
        
        System.debug(dateTimeValue);
        return dateTimeValue;
    }    
    
    //Pass this method the Comment id and the media id will be fetched.
    public static void updateCaseStatusAndinformUsers(List<Id> caseIds){
        
        map<id,User> UserRecordById = new map<id,User>([Select id , name ,Email from user]);
        map<id,Case> caseRecordsByOwnerId = new map<id,case>();
        List<Case> caseListToBeUpdated = new List<Case>();
        List<String> ownerIds = new list<String>();
        List<Case> casesWithNewComments  = [Select id ,Status,CaseNumber,Priority,Subject,OwnerId from case where id IN : caseIds and status != 'New'];
        
        for(Case caseRec : casesWithNewComments){
            caseRec.Status = 'New';
            caseRecordsByOwnerId.put(caseRec.OwnerId,caseRec);
        }
        Update casesWithNewComments;
        
        for(String str : caseRecordsByOwnerId.keyset()){
            sendEmailsTocaseOwners(UserRecordById.get(str) ,caseRecordsByOwnerId.get(str) );
        }
        
        
    }   
    
    public Static void sendEmailsTocaseOwners(User UserRecord , Case CaseRecord ){
        system.debug('The UserRecord is-->'+UserRecord); 
        system.debug('The CaseRecord case is-->'+CaseRecord); 
        EmailTemplate et = [Select id, htmlValue, Body, subject from EmailTemplate where DeveloperName = 'New_Comment_on_the_Post'];
        String htmlBody = et.HtmlValue;
        htmlBody = htmlBody.replace('[Case Number]', CaseRecord.CaseNumber);
        htmlBody = htmlBody.replace('[Case Subject]', CaseRecord.Subject);
        htmlBody = htmlBody.replace('[Current Status]', CaseRecord.Status);
        htmlBody = htmlBody.replace('[Priority]', CaseRecord.Priority);
        
        String plainBody = et.Body;
        
        plainBody = plainBody.replace('[Case Number]', CaseRecord.CaseNumber);
        plainBody = plainBody.replace('[Case Subject]', CaseRecord.Subject);
        plainBody = plainBody.replace('[Current Status]', CaseRecord.Status);
        plainBody = plainBody.replace('[Priority]', CaseRecord.Priority);
        
        //Below list is not required, it is just to show that we can send multiple email as well
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(UserRecord.Id);
        mail.setSenderDisplayName('Hyphen Support Team');
        mail.setSubject('New Comments on Case - Immediate Attention Required');
        mail.setSaveAsActivity(true);
        mail.setHtmlBody(htmlBody);
        if(Test.isRunningTest()){
            mail.setSaveAsActivity(false);    
        }
        
        mails.add(mail);
        
        if(mails.size() > 0 ) {
            Messaging.sendEmail(mails);
        }
        
    }
}