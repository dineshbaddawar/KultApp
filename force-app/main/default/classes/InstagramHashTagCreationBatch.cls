/* 
* Test Class name : InstagramHashTagCreationBatchTest
* created Date     : 29/07/2023
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class contains all the api's related to instagram.
*/
public class InstagramHashTagCreationBatch  implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    private static Instagram_Api_Details__c fap = Instagram_Api_Details__c.getInstance();
    private static final String CLIENT_ID                                    = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET                                      = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI                                       = fap.REDIRECT_URI__c;
    private static String accessToken                                        = fap.accessToken__c;
    private static String basicUrl                                           = fap.basicUrl__c;
    private static String businessUserId                                     = fap.businessUserId__c;
    private static String hashTagName                                        = fap.HashTag__c;
    private static List<case> existingCaseList                               = new List<case> ();
    private static List<case> insertedCaseList                               = new List<case>();
    private static List<Case_Communication__c> newpostCommentList                            = new List<Case_Communication__c>();
    private static List<Case_Communication__c> newpostCommentForExistingPosts                = new List<Case_Communication__c>();
    private static List<Case_Communication__c> postCommentsForExistingPostsToBeInserted      = new List<Case_Communication__c>();
    private static List<Case_Communication__c> postCommentListToBeUpdated                    = new List<Case_Communication__c>();
    private static List<Id> caseIdsToBeUpdated                               = new List<Id>();
    private static map<String,List<Case_Communication__c>> commentsOnPostByPostId = new map<String,List<Case_Communication__c>>();
    private static map<String,String> caseIdByPostId                         = new map<String,String>();
    private static map<String,String> postCommentIdByPostId                  = new map<String,String>();
    private static map<String,String> caseIdByPostCommentId                  = new map<String,String>();
    List<String> casePostIds                                                 = new List<String>();
    List<Case> ExistingCaseRecords                                           = new List<Case>();
    //Getting the record Type Id
    private static Id caseRecordTypeId                                       = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String origin = 'Instagram';
        String Brand='Hyphen';
        String query = 'Select id,subject,Description,Caption__c,Post_Id__c,(Select Activity_Content__c,Activity_ID__c,case__c,Case__r.Post_Id__c,Activity_Author__c,Post_Url__c,Activity_Created_DateTime__c from Case_Communications__r) from case where Origin = :origin and recordTypeId = :caseRecordTypeId AND Brand__c=:Brand';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<case> caseRecordsList) {
        for(case caseRec : caseRecordsList){
            ExistingCaseRecords.add(caseRec);
        }
    }
    
    public void finish(Database.BatchableContext context){
        Set<Id> CaseIdsToBeDeleted = new Set<Id>();
        for(case caseRec : ExistingCaseRecords){
            for(Case_Communication__c postCommRec : caseRec.Case_Communications__r){
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
        }
        for(Case caseRec : ExistingCaseRecords){
            list<Case_Communication__c> postCommNewList = new list<Case_Communication__c>();
            caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
            if(!commentsOnPostByPostId.keyset().contains(caseRec.Post_Id__c)){
                commentsOnPostByPostId.put(caseRec.Post_Id__c,postCommNewList);
            }
        }
        String hashTagId = InstagramAuthHelper.getHashtagIdFromInsta(hashtagName);
        String body = '';
        String endpointUrl = basicUrl+hashTagId+'/recent_media?fields=media_url,media_type,caption,permalink,timestamp&user_id='+businessUserId;
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            if (test.isRunningTest()){
                body = '{"data":[{"id":"17841405793087218","username":"example_user","timestamp":"2023-07-29T12:34:56+0000","caption":"This is an amazing photo!","media_type":"IMAGE","media_url":"https://www.example.com/image.jpg","permalink":"https://www.instagram.com/p/ABC123/","comments_count":5,"comments":{"data":[{"id":"17851087209098192","text":"Awesome!","username":"user1","timestamp":"2023-07-29T12:40:00+0000"},{"id":"17851087209098193","text":"Great shot!","username":"user2","timestamp":"2023-07-29T12:42:30+0000"},{"id":"17851087209098194","text":"Beautiful!","username":"user3","timestamp":"2023-07-29T12:45:15+0000"},{"id":"17851087209098195","text":"Nice!","username":"user4","timestamp":"2023-07-29T12:50:20+0000"},{"id":"17851087209098196","text":"Love it!","username":"user5","timestamp":"2023-07-29T13:00:00+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/ABC123/comments?cursor=cursor_after"}}},{"id":"17841405793087219","username":"another_user","timestamp":"2023-07-29T14:30:45+0000","caption":"Sunset vibes!","media_type":"VIDEO","media_url":"https://www.example.com/video.mp4","permalink":"https://www.instagram.com/p/XYZ456/","comments_count":2,"comments":{"data":[{"id":"17851087209098197","text":"Amazing video!","username":"user6","timestamp":"2023-07-29T14:40:00+0000"},{"id":"17851087209098198","text":"Beautiful sunset!","username":"user7","timestamp":"2023-07-29T14:45:30+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/XYZ456/comments?cursor=cursor_after"}}}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/user123/media?cursor=cursor_after"}}';
            }else{
                HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
                body = response.getBody();
            }
        instaJSONHandler jsonResponse = instaJSONHandler.parse(body);
        for(instaJSONHandler.cls_data postInfo : jsonResponse.data){
            if(!commentsOnPostByPostId.keyset().contains(postInfo.Id)){
                Case newCase = new case();
                newCase.User_Name__c    = postInfo.username;
                newCase.Brand__c         = 'Hyphen';
                newCase.Origin           = 'Instagram';
                newCase.Post_Id__c       = postInfo.id;
                newcase.Created_Time__c  = String.valueOf(postInfo.timestamp).removeEnd('+0000');
                newcase.POST_URL__c      = postInfo.permalink;
                newcase.Comments_JSON__c = string.valueOf(postInfo.repliesOnPost);
                newcase.OwnerId          = userinfo.getuserId();
                newcase.Priority         = 'High';
                newcase.Type_of_Post__c  = 'HashTags';
                newcase.RecordTypeId     = caseRecordTypeId;
                newcase.Subject          = 'Hash Tag Post from instagram.Related to #'+hashtagName+'. Created Date-Time : '+newcase.Created_Time__c;
                newcase.Description      = postInfo.caption;
                newcase.HashTag__c       = hashtagName;
                newcase.Hash_Tag_Id__c   = hashTagId;
                if(!commentsOnPostByPostId.keyset().contains(newCase.Post_Id__c)){
                    insertedCaseList.add(newCase);
                }
            }
        }
        if(insertedCaseList.size() > 0){
            upsert insertedCaseList Post_Id__c;
        }
    }
}