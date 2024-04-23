/* 
* Test Class name : InstagramPostCreationBatchTest
* created Date     : 29/07/2023
* Created By       : shubham kumar
* Last Modfied By  : shubham kumarp
* Descritpion      : This class contains all the api's related to instagram.
*/

public class InstagramPostCreationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    private static Instagram_Api_Details__c fap                                         = Instagram_Api_Details__c.getInstance();
    private static final String CLIENT_ID                                               = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET                                                 = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI                                                  = fap.REDIRECT_URI__c;
    private static String accessToken                                                   = fap.accessToken__c;
    private static String basicUrl                                                      = fap.basicUrl__c;
    private static String businessUserId                                                = fap.businessUserId__c;
    private static List<case> existingCaseList                                          = new List<case> ();
    private static List<case> insertedCaseList                                          = new List<case>();
    private static List<Case_Communication__c> newpostCommentList                            = new List<Case_Communication__c>();
    private static List<Case_Communication__c> newpostCommentForExistingPosts                = new List<Case_Communication__c>();
    private static List<Case_Communication__c> postCommentsForExistingPostsToBeInserted      = new List<Case_Communication__c>();
    private static List<Case_Communication__c> postCommentListToBeUpdated                    = new List<Case_Communication__c>();
    private static String nextPaginationPostToken                                       = fap.next_Pagination_Post_Token__c;
    private static String nextPaginationMentionToken                                    = fap.next_Pagination_Mention_Token__c;
    private static String nextPaginationHashTagToken                                    = fap.next_pagination_hashtag_Token__c;
    private static String hashtagName                                                   = fap.HashTag__c; 
    private static List<Id> caseIdsToBeUpdated                                          = new List<Id>();
    private static map<String,List<Case_Communication__c>> commentsOnPostByPostId            = new map<String,List<Case_Communication__c>>();
    private static map<String,String> caseIdByPostId                                    = new map<String,String>();
    private static map<String,String> postCommentIdByPostId                             = new map<String,String>();
    private static map<String,String> caseIdByPostCommentId                             = new map<String,String>();
    List<String> casePostIds                                                            = new List<String>();
    List<Case> ExistingCaseRecords                                                      = new List<Case>();
    List<Case_Communication__c> ExistingPostCommRecords                                      = new  List<Case_Communication__c>();
    //Getting the record Type Id
    private static Id caseRecordTypeId                                                  = Schema.SObjectType.case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        ExistingCaseRecords = [Select id,subject,Description,Caption__c,Post_Id__c from case where recordTypeId = :caseRecordTypeId and Origin = 'Instagram' AND Brand__c='Hyphen'];
        String query = 'Select Activity_Content__c,Activity_ID__c,case__c,Case__r.Post_Id__c,Activity_Author__c,Platform_URL__c,Activity_Created_DateTime__c from Case_Communication__c where case__c IN :ExistingCaseRecords';
        return Database.getQueryLocator(query);
    }
    
    
    public void execute(Database.BatchableContext context, List<Case_Communication__c> postCommentsList) {
        for(Case_Communication__c postCommRec : postCommentsList){
            ExistingPostCommRecords.add(postCommRec);
        }
    }
    
    
    
    public void finish(Database.BatchableContext context) {
        
        if(nextPaginationPostToken != null){
            try {
                Set<Id> CaseIdsToBeDeleted = new Set<Id>();
                for(Case_Communication__c postCommRec : ExistingPostCommRecords){
                    postCommentIdByPostId.put(postCommRec.Activity_ID__c,postCommRec.Id);
                    caseIdByPostCommentId.put(postCommRec.Activity_ID__c,postCommRec.Case__c);
                    if(commentsOnPostByPostId.containsKey(postCommRec.Case__c)){
                        commentsOnPostByPostId.get(postCommRec.Case__r.Post_Id__c).add(postCommRec);
                    }else{
                        list<Case_Communication__c> postCommNewList = new list<Case_Communication__c>();
                        postCommNewList.add(postCommRec);
                        commentsOnPostByPostId.put(postCommRec.Case__r.Post_Id__c,postCommNewList);
                    }
                }
                
                for(Case caseRec : existingCaseList){
                    list<Case_Communication__c> postCommNewList = new list<Case_Communication__c>();
                    caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
                    if(!commentsOnPostByPostId.keyset().contains(caseRec.Post_Id__c)){
                        commentsOnPostByPostId.put(caseRec.Post_Id__c,postCommNewList);
                    }
                    
                }
                
                String endpointUrl = 'https://graph.facebook.com/v17.0/'+businessUserId+'/media';
                String fieldsParam = 'fields=media_url,comments_count,permalink,caption,media_type,shortcode,timestamp,username,comments.limit(50){id,like_count,user,media,timestamp,username,replies{text,username,timestamp},text}&limit=50&after='+nextPaginationPostToken;
                String fullUrl = endpointUrl + '?' + fieldsParam + '&access_token=' + accessToken;
                system.debug('fullUrl==>'+fullUrl);
                String body = '';
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(fullUrl);
                request.setMethod('GET');
                
                
                if (test.isRunningTest()){
                    body = '{"data":[{"id":"17841405793087218","username":"example_user","timestamp":"2023-07-29T12:34:56+0000","caption":"This is an amazing photo!","media_type":"IMAGE","media_url":"https://www.example.com/image.jpg","permalink":"https://www.instagram.com/p/ABC123/","comments_count":5,"comments":{"data":[{"id":"17851087209098192","text":"Awesome!","username":"user1","timestamp":"2023-07-29T12:40:00+0000"},{"id":"17851087209098193","text":"Great shot!","username":"user2","timestamp":"2023-07-29T12:42:30+0000"},{"id":"17851087209098194","text":"Beautiful!","username":"user3","timestamp":"2023-07-29T12:45:15+0000"},{"id":"17851087209098195","text":"Nice!","username":"user4","timestamp":"2023-07-29T12:50:20+0000"},{"id":"17851087209098196","text":"Love it!","username":"user5","timestamp":"2023-07-29T13:00:00+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/ABC123/comments?cursor=cursor_after"}}},{"id":"17841405793087219","username":"another_user","timestamp":"2023-07-29T14:30:45+0000","caption":"Sunset vibes!","media_type":"VIDEO","media_url":"https://www.example.com/video.mp4","permalink":"https://www.instagram.com/p/XYZ456/","comments_count":2,"comments":{"data":[{"id":"17851087209098197","text":"Amazing video!","username":"user6","timestamp":"2023-07-29T14:40:00+0000"},{"id":"17851087209098198","text":"Beautiful sunset!","username":"user7","timestamp":"2023-07-29T14:45:30+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/XYZ456/comments?cursor=cursor_after"}}}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/user123/media?cursor=cursor_after"}}';
                }else{
                    HttpResponse response = http.send(request);
                    body = response.getBody();
                }
                
                FacebookApiResponse responseWrapper = (FacebookApiResponse) JSON.deserialize(body, FacebookApiResponse.class);
                if( responseWrapper.data.size() == 50){
                    Instagram_Api_Details__c instaSetting = Instagram_Api_Details__c.getOrgDefaults();
                    instaSetting.Id = instaSetting.Id;
                    instaSetting.next_Pagination_Post_Token__c = responseWrapper.paging.cursors.after;
                    update instaSetting;
                }else{
                    Instagram_Api_Details__c instaSetting = Instagram_Api_Details__c.getOrgDefaults();
                    instaSetting.Id = instaSetting.Id;
                    instaSetting.next_Pagination_Post_Token__c = null;
                    update instaSetting;
                }
                for(FacebookApiResponse.DataWrapper postInfo : responseWrapper.data){                                                    
                    
                    if(!commentsOnPostByPostId.keyset().contains(postInfo.Id)){
                        Case newCase = new case();
                        newCase.User_Name__c = postInfo.username;
                        newCase.Brand__c      = 'Hyphen';
                        newCase.Origin        = 'Instagram';
                        newCase.Post_Id__c = postInfo.id;
                        newcase.Created_Time__c = String.valueOf(postInfo.timestamp).removeEnd('+0000');
                        newcase.POST_URL__c = postInfo.permalink;
                        newcase.recordtypeId = caseRecordTypeId;
                        if((postInfo.comments != null)){
                            newcase.Comments_JSON__c = string.valueOf(postInfo.comments.data);
                        }
                        newcase.Priority = 'High';
                        if(!string.isBlank(postInfo.permalink) && postInfo.permalink.Contains('reel')){
                            newcase.Type_of_Post__c = 'Reel';    
                        }else{
                            newcase.Type_of_Post__c = 'Post';
                        }
                        newcase.Subject = 'Post from instagram.Related to '+postInfo.username+'. Created Date-Time : '+newcase.Created_Time__c;
                        newcase.Description = postInfo.caption;
                        if(!commentsOnPostByPostId.keyset().contains(newCase.Post_Id__c)){
                            upsert newcase Post_Id__c;
                        }
                        if((postInfo.comments != null)){
                            if(newcase.Id != null){
                                for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                                    Case_Communication__c commentRec = new Case_Communication__c();
                                    commentRec.Case__c = newcase.Id;
                                    commentRec.Activity_Content__c = postInfoRec.text;
                                    commentRec.Activity_ID__c = postInfoRec.Id;
                                    commentRec.Activity_Author__c = postInfoRec.username;
                                    commentRec.Activity_Created_DateTime__c = getDateTime(postInfoRec.timestamp);
                                    commentRec.Replied_Activities__c = string.valueOf(postInfoRec.replies);
                                    commentRec.Platform_URL__c	 = postInfo.permalink;
                                    newpostCommentList.add(commentRec);
                                }      
                            }
                        }
                    }else{
                        if(postInfo.comments != null){
                            for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                                if(commentsOnPostByPostId.containsKey(postInfo.Id)){
                                    List<String> postCommentIds = new List<String>();
                                    if(commentsOnPostByPostId.get(postInfo.Id).size() > 0){
                                        for(Case_Communication__c poCom :  commentsOnPostByPostId.get(postInfo.Id)){
                                            postCommentIds.add(poCom.Activity_ID__c);
                                        }    
                                    }
                                    if(!postCommentIds.contains(postInfoRec.Id)){
                                        Case_Communication__c commentRec = new Case_Communication__c();
                                        commentRec.Case__c = caseIdByPostId.get(postInfo.Id);
                                        commentRec.Activity_Content__c = postInfoRec.text;
                                        commentRec.Activity_ID__c = postInfoRec.Id;
                                        commentRec.Activity_Author__c = postInfoRec.username;
                                        commentRec.Activity_Created_DateTime__c = getDateTime(postInfoRec.timestamp);
                                        commentRec.Platform_URL__c	 = postInfo.permalink;
                                        commentRec.Replied_Activities__c = string.valueOf(postInfoRec.replies);
                                        newpostCommentForExistingPosts.add(commentRec);
                                    }else{
                                        Case_Communication__c commentRec = new Case_Communication__c();
                                        commentRec.Id = postCommentIdByPostId.get(postInfoRec.Id);
                                        if(caseIdByPostCommentId.ContainsKey(postInfoRec.Id)){
                                            caseIdsToBeUpdated.add(caseIdByPostCommentId.get(postInfoRec.Id));    
                                        }
                                        commentRec.Replied_Activities__c = string.valueOf(postInfoRec.replies);
                                        postCommentListToBeUpdated.add(commentRec);
                                        
                                    }
                                }
                            }
                        }else{
                            
                        }
                    }
                }
                for(Case_Communication__c postCommRec : newpostCommentForExistingPosts){
                    if(postCommentIdByPostId.keySet().contains(postCommRec.Activity_ID__c)){
                        
                    }else{
                        postCommentsForExistingPostsToBeInserted.add(postCommRec);
                    }
                }
                if(newpostCommentList.size() > 0){
                    upsert newpostCommentList Activity_ID__c;
                }
                if(postCommentsForExistingPostsToBeInserted.size() > 0){
                    upsert postCommentsForExistingPostsToBeInserted Activity_ID__c;
                }
                
                if(postCommentListToBeUpdated.size() > 0){
                    Database.update(postCommentListToBeUpdated,false);
                }
            }catch(exception e){
                System.debug('An error occurred: ' + e.getMessage()+'---@-----'+e.getLineNumber()); 
            } 
        }else{
            InstagramAuthHelper.getAllPostsFromInstaForUserId();
        }
    }
    
    public static dateTime getDateTime (String dateTimeString){
        system.debug('dateTimeString==>'+dateTimeString);
        dateTimeString = dateTimeString.remove('+0000');
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
}