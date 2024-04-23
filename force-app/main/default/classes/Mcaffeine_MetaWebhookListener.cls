/**
 * Author: DeaGle~
 * 30th  August, 23
 */

@RESTResource(urlMapping='/webhooklistener_mcaffine/*')
global without sharing class Mcaffeine_MetaWebhookListener {
    
    static String WEB_TOKEN;// = 'EAAKJz6xiZC6gBAEQ7Ub3pazJxFazWFUXEkbp2Hlg0W0EmblRJVhrLLr1WUwL81hqfSxRXJJ8otiGZAyQ66onZBoRFTOqdjZBKioZA5iy55N0rxyZBulbw1XVgu6ktZA0b0vs6uZAFG7SodcyHayN2id8WAktoJejpdCcaTLF9NwV6FkTvizWzYBZC';
    static String ORIGIN, OWNER_TYPE, OWNER_NAME;
    static Id RECORD_TYPE_ID, RECORD_OWNER_ID;

    static final String COMMENT_TYPE_TEXT = 'TEXT';
    static final String COMMENT_TYPE_VIDEO = 'VIDEO';
    static final String COMMENT_TYPE_PHOTO = 'PHOTO';
    private static final String PAGE_NAME;
    static {
        Meta_App_Credentials__c credentials = Meta_App_Credentials__c.getAll() != null ? Meta_App_Credentials__c.getAll().get('mcaffeine') : null; //TODO: make this dynamic
        if(credentials != null) {
            WEB_TOKEN = credentials.Webhook_Token__c;
            ORIGIN = credentials.Source__c;
            RECORD_TYPE_ID = getRecordTypeIdByName('Case', credentials.SObject_Record_Type__c);
            OWNER_TYPE = credentials.Owner_Type__c;
            OWNER_NAME = credentials.Record_Owner__c;
            PAGE_NAME = credentials.Page_Name__c;
            if(OWNER_TYPE != null && OWNER_NAME != null) {
                try{
                    if(OWNER_TYPE.equalsIgnoreCase('user')) 
                        RECORD_OWNER_ID = [SELECT Id FROM User WHERE UserName =:OWNER_NAME].Id;
                    else if(OWNER_TYPE.equalsIgnoreCase('queue'))
                        RECORD_OWNER_ID = [SELECT Id FROM Group WHERE Name = :OWNER_NAME AND Type = 'Queue'].Id;
                    else
                        RECORD_OWNER_ID = UserInfo.getUserId();
                }catch(Exception e) {
                    RECORD_OWNER_ID = UserInfo.getUserId();
                }
            }

        }
    }
    
    @HttpPost
    global static void webhookListener(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody.toString();
        
        try{
            if(requestBody != null) {
                requestBody = requestBody.replace('"object"','"object_c"');
                requestBody = requestBody.replace('"time"','"time_c"');
                requestBody = requestBody.replace('"from"','"from_c"');
                System.debug('--- WEBHOOK requestBody' +requestBody);
                Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(requestBody);

                if(responseMap != null && responseMap.containsKey('entry')) {

                    List<Object> changesList = (List<Object>)((Map<String, Object>)(((List<Object>)responseMap.get('entry'))[0])).get('changes');
                    List<Object> messagesList = (List<Object>)((Map<String, Object>)(((List<Object>)responseMap.get('entry'))[0])).get('messaging');
                    System.debug('--- changesList: '+changesList);

                    if(changesList != null && !changesList.isEmpty() && ((Map<String,Object>)changesList[0]).containsKey('field')) {
                        Map<String,Object> changeMap = (Map<String,Object>)changesList[0];
                        Map<String,Object> changeValueMap = changeMap.containsKey('value') ? (Map<String,ObjecT>)changeMap.get('value') : null;
                        if(changeValueMap != null && changeValueMap.get('reaction_type') == null) {
                            System.debug('--- '+changeValueMap);
                            System.debug('--- changeMap.get(video)'+changeValueMap.get('video'));
                            System.debug('--- changeMap.get(video)'+changeValueMap.get('message'));
                            System.debug('--- changeMap.get(video)'+changeValueMap.get('photo'));
                            if(changeMap.get('field') == 'feed' && changeValueMap.get('item') != 'comment' &&/* (changeValueMap.get('item') == 'status' || changeValueMap.get('item') == 'post') && */ changeValueMap.get('verb') == 'add') {
                                newPostRequest(requestBody);
                            }if(changeMap.get('field') == 'feed' && changeValueMap.get('item') != 'comment' &&/* changeValueMap.get('item') == 'status' && */ changeValueMap.get('verb') == 'edited' || changeValueMap.get('verb') == 'edit') {
                                editExistingCase(requestBody);
                            }else if(changeMap.get('field') == 'mention' && changeValueMap.get('item') == 'post' && changeValueMap.get('verb') == 'add') {
                                processMention(changeMap);
                            }else if(changeMap.get('field') == 'feed' && (changeValueMap.get('video') != null || changeValueMap.get('message') != null || changeValueMap.get('photo') != null) && changeValueMap.get('item') == 'comment' && changeValueMap.get('verb') == 'add') {
                                processComment(requestBody);
                            }else if(changeMap.get('field') == 'feed' && (changeValueMap.get('video') != null || changeValueMap.get('message') != null || changeValueMap.get('photo') != null) && changeValueMap.get('item') == 'comment' && changeValueMap.get('verb') == 'edited') {
                                editExistingComment(requestBody);
                            }else {
                                System.debug('--- not found');
                            }

                        }
                    }else if(messagesList != null && !messagesList.isEmpty()) {
                        processMessages(requestBody);
                    }
                }

            }

        }catch(Exception e) {
            System.debug('--- Exception'+ e.getMessage());
            System.debug('--- line no'+ e.getLineNumber());
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper('Received', WEB_TOKEN)));
    }


    private static void editExistingComment(String requestbody) {
        FBPageCommentWrapper postComment = (FBPageCommentWrapper) JSON.deserialize(requestBody, FBPageCommentWrapper.class);
        Map<String, FBPageCommentWrapper.cls_changes> commentXchangesMap = new Map<String, FBPageCommentWrapper.cls_changes>(); 
        if(postComment != null) {
            String timeStamp, entryId;
            for(FBPageCommentWrapper.cls_entry entry: postComment.entry) {
                timeStamp = String.valueOf(entry.time_c); //TODO convert this to readable format
                entryId = entry.id;
                for(FBPageCommentWrapper.cls_changes change: entry.changes) {
                    commentXchangesMap.put(change.value.comment_id, change);
                }
            }

            if(!commentXchangesMap.isEmpty()) {
                List<Case_Communication__c> postCommentList = [SELECT Id, Activity_ID__c FROM Case_Communication__c WHERE Activity_ID__c IN: commentXchangesMap.keySet()];
                if(!postCommentList.isEmpty()) {
                    for(Case_Communication__c pc: postCommentList) {
                        if(commentXchangesMap.containsKey(pc.Activity_ID__c)) {
                            pc.Activity_Content__c = commentXchangesMap.get(pc.Activity_ID__c).value.message;
                            pc.Attachment_URL__c = commentXchangesMap.get(pc.Activity_ID__c).value.video;
                            pc.Post_comment_Time__c = commentXchangesMap.get(pc.Activity_ID__c).value.created_time + '';
                            pc.Activity_Type__c = getcommentType(commentXchangesMap.get(pc.Activity_ID__c));
                        }
                    }
                    try{
                        system.debug('--- postCommentList: '+postCommentList);
                        update postCommentList;
                        system.debug('--- postCommentList: '+postCommentList);
                    }catch(DMLException e) {
                        System.debug('--- DML EXception on: '+e.getLineNumber());
                        System.debug('--- DML EXception message: '+e.getMessage());
                    }
                }
                


            }
        }
    }

     private static void editExistingCase(String requestbody) {
        List<Case> postCaseList = new List<Case>();
        FBFeedNotificationWrapper postNotification = (FBFeedNotificationWrapper) JSON.deserialize(requestBody, FBFeedNotificationWrapper.class);
        if(postNotification != null) {
            String timeStamp, entryId;
            Map<String, FBFeedNotificationWrapper.cls_changes> postChangeMap = new Map<String, FBFeedNotificationWrapper.cls_changes>();
            for(FBFeedNotificationWrapper.cls_entry entry: postNotification.entry) {
                timeStamp = String.valueOf(entry.time_c); //TODO convert this to readable format
                entryId = entry.id;
                for(FBFeedNotificationWrapper.cls_changes change: entry.changes) {
                    postChangeMap.put(change.value.post_id, change);
                }
            }
            
            if(!postChangeMap.isEmpty()) {
                List<Case> casesToUpdate = [SELECT Id,Post_Id__c,Created_Time__c,Description FROM Case WHERE Post_Id__c IN :postChangeMap.keySet()];
                if(casesToUpdate.isEmpty()) {
                    List<Case> caseToInsert = new List<Case>();
                    for(FBFeedNotificationWrapper.cls_changes change : postChangeMap.values()) {
                        Case postCase = new Case(Subject= 'New post on FB Page from:' + change.value.from_c != null ? change.value.from_c.name : '', Type_of_Post__c='Post', 
                    Origin = ORIGIN, RecordTypeId = RECORD_TYPE_ID,
                    OwnerId = RECORD_OWNER_ID, Post_Id__c = change.value.post_id, Description = change.value.message, Brand__c = PAGE_NAME, Created_Time__c = change.value.created_time + '');
                        if(change.value.item == 'photo' || change.value.item == 'video') {
                            postCase.Post_Attachment_Url__c = change.value.link;
                        }
                        caseToInsert.add(postCase);
                    }

                    if(!caseToInsert.isEmpty()) {
                        try {
                            System.debug('--- caseToInsert'+ caseToInsert);
                            insert caseToInsert;
                        }catch(DMLException e) {
                            System.debug('--- DML EXception on: '+e.getLineNumber());
                            System.debug('--- DML EXception message: '+e.getMessage());
                        }
                    }
                        
                }else {
                    for(Case postCase: casesToUpdate) {
                        if(postChangeMap.containsKey(postCase.Post_Id__c)) {
                            FBFeedNotificationWrapper.cls_changes change = postChangeMap.get(postCase.Post_Id__c);
                            postCase.Description = change.value.message;
                            postCase.Created_Time__c = change.value.created_time + '';
                            if(change.value.item == 'photo' || change.value.item == 'video') {
                                postCase.Post_Attachment_Url__c = change.value.link;
                            }
                            System.debug('--- new POST case:'+postCase);
                        }
                    
                    }
                    if(!casesToUpdate.isEmpty()) {
                        System.debug('--- updating case: '+casesToUpdate);
                        try{
                            Database.update(casesToUpdate, false);
                        }catch(DMLException e){
                            System.debug('--- e.Message:'+e.getMessage());
                        }
                    }

                }
            }

        }
    }

    private static void newPostRequest(String requestBody) {
        //process wrapper and create case
        Map<String, Case> caseListToUpsertMap = new Map<String, Case>();
        FBFeedNotificationWrapper postNotification = (FBFeedNotificationWrapper) JSON.deserialize(requestBody, FBFeedNotificationWrapper.class);
        if(postNotification != null) {
            String timeStamp, entryId;
            for(FBFeedNotificationWrapper.cls_entry entry: postNotification.entry) {
                timeStamp = String.valueOf(entry.time_c); //TODO convert this to readable format
                entryId = entry.id;
                for(FBFeedNotificationWrapper.cls_changes change: entry.changes) {
                    Case postCase = new Case();

                    if(change.value.item == 'photo' || change.value.item == 'video') {
                        postCase.Post_Attachment_Url__c = change.value.link;
                    }
                    postCase.Type_of_Post__c='Post';
                    postCase.Origin = ORIGIN;
                    postCase.Subject= 'New post on FB Page from:' + change.value.from_c != null ? change.value.from_c.name : '';
                    postCase.Post_Id__c = change.value.post_id;
                    postCase.Description = change.value.message;
                    postCase.RecordTypeId = RECORD_TYPE_ID;
                    postCase.OwnerId = RECORD_OWNER_ID;
                    postCase.Brand__c = PAGE_NAME;
                    postCase.Created_Time__c = change.value.created_time + '';
                    System.debug('--- new POST case:'+postCase);
                    caseListToUpsertMap.put(postCase.Post_Id__c, postCase);
                }
            }
            if(!caseListToUpsertMap.isEmpty()) {
                System.debug('--- creating case: '+caseListToUpsertMap);
                try{
                    List<Case> existingCaseList = [SELECT Id,Post_Id__c FROM Case WHERE Post_Id__c IN: caseListToUpsertMap.keySet()];
                    for(Case c: existingCaseList) {
                        if(caseListToUpsertMap.containsKey(c.Post_Id__c)) {
                            caseListToUpsertMap.get(c.Post_Id__c).Id = c.Id;
                        }
                    }
                    upsert caseListToUpsertMap.values();
                    System.debug(' --- postCaseList: '+caseListToUpsertMap.values());
                }catch(DMLException e){
                    System.debug('--- e.Message:'+e.getMessage());
                }
            }
        }
    }
    //set parent id based on external id field 
    public static void processComment(String requestBody) {
        FBPageCommentWrapper postComment = (FBPageCommentWrapper) JSON.deserialize(requestBody, FBPageCommentWrapper.class);
        List<Case> postCaseList = new List<Case>();
        if(postComment != null) {
            Map<String, List<FBPageCommentWrapper.cls_changes>> postXCommentMap = new Map<String, List<FBPageCommentWrapper.cls_changes>>();
            String timeStamp, entryId;
            Map<String, List<FBPageCommentWrapper.cls_changes>> replyCommentsMap = new Map<String, List<FBPageCommentWrapper.cls_changes>>(); 
            for(FBPageCommentWrapper.cls_entry entry: postComment.entry) {
                timeStamp = String.valueOf(entry.time_c); //TODO convert this to readable format
                entryId = entry.id;
                for(FBPageCommentWrapper.cls_changes change: entry.changes) {
                    if(change.value.post_id != change.value.parent_id) {
                        if(replyCommentsMap.containsKey(change.value.parent_id)) {
                            replyCommentsMap.get(change.value.parent_id).add(change);
                        }else {
                            replyCommentsMap.put(change.value.parent_id, new List<FBPageCommentWrapper.cls_changes> {change});
                        }
                        continue;
                    }
                    if(postXCommentMap.containsKey(change.value.post_id)) {
                        postXCommentMap.get(change.value.post_id).add(change);
                    }else {
                        postXCommentMap.put(change.value.post_id, new List<FBPageCommentWrapper.cls_changes> {change});
                    }
                }
            }
            List<Case_Communication__c> postCommentList = new List<Case_Communication__c>();
            Map<String, Case> postIdXCaseMap = new Map<String, Case>();
            if(!postXCommentMap.isEmpty()) {
                List<Case> existingPostCaseList = [SELECT Id,Post_Id__c FROM Case WHERE Post_Id__c IN : postXCommentMap.keySet()];
                for(Case fbPost: existingPostCaseList) {
                    postIdXCaseMap.put(fbPost.Post_Id__c, fbPost);
                }
                List<Case> newCaseToInsert = new List<Case>();
                for(String postId: postXCommentMap.keySet()) {
                    if(postIdXCaseMap.containsKey(postId)) {
                        List<FBPageCommentWrapper.cls_changes> changeList = postXCommentMap.get(postId);

                        for(FBPageCommentWrapper.cls_changes changeObj: changeList) {
                            System.debug('--- changeObj'+changeObj);
                            Case_Communication__c commentRec = new Case_Communication__c();
                            commentRec.Case__c = postIdXCaseMap.get(postId).Id;
                            commentRec.Activity_Content__c = changeObj.value.message;
                            commentRec.Attachment_URL__c = changeObj.value.video;
                            commentRec.Activity_ID__c = changeObj.value.comment_id;
                            commentRec.Activity_Author__c = changeObj.value.from_c.name;
                            if(changeObj.value.from_c.name == PAGE_NAME) {
                                commentRec.Sent_from_SFDC__c = true;
                            }
                            commentRec.Post_comment_Time__c = changeObj.value.created_time + '';
                            commentRec.Platform_URL__c	 = changeObj.value.post.permalink_url;
                            commentRec.Activity_Type__c = getCommentType(changeObj);
                            system.debug('commentRec --- '+commentRec);
                            postCommentList.add(commentRec);
                        }
                    }else {
                        //create new case and tag post here
                    }
                }
            }

            if(!replyCommentsMap.isEmpty()) {
                List<Case_Communication__c> pcList = [SELECT Id, Activity_ID__c, Case__c FROM Case_Communication__c WHERE Activity_ID__c IN :replyCommentsMap.keySet()];
                Map<String, Case_Communication__c> commentIdXcommentMap = new Map<String, Case_Communication__c>();
                for(Case_Communication__c pc: pcList) {
                    commentIdXcommentMap.put(pc.Activity_ID__c, pc);
                }

                for(String commentId: replyCommentsMap.keySet()) {
                    List<FBPageCommentWrapper.cls_changes> changeList = replyCommentsMap.get(commentId);
                    for(FBPageCommentWrapper.cls_changes changeObj: changeList) {
                        if(commentIdXcommentMap.containsKey(changeObj.value.parent_id)) {
                            Case_Communication__c commentRec = new Case_Communication__c();
                            commentRec.Case__c = commentIdXcommentMap.get(changeObj.value.parent_id).Case__c;
                            commentRec.Activity_Content__c = changeObj.value.message;
                            commentRec.Attachment_URL__c = changeObj.value.video;
                            commentRec.Activity_ID__c = changeObj.value.comment_id;
                            commentRec.Activity_Author__c = changeObj.value.from_c.name;
                            commentRec.Post_comment_Time__c = changeObj.value.created_time + '';
                            commentRec.Platform_URL__c = changeObj.value.post.permalink_url;
                            if(changeObj.value.from_c.name == PAGE_NAME) {
                                commentRec.Sent_from_SFDC__c = true;
                            }
                            commentRec.Case_Communication__c = commentIdXcommentMap.get(changeObj.value.parent_id).Id;
                            commentRec.Activity_Type__c = getcommentType(changeObj);
                            system.debug('commentRec --- '+commentRec);
                            postCommentList.add(commentRec);

                        }else if(postIdXCaseMap.containsKey(changeObj.value.post_id)){
                            //tag under case
                            Case_Communication__c commentRec = new Case_Communication__c();
                            commentRec.Case__c = postIdXCaseMap.get(changeObj.value.post_id).Id;
                            commentRec.Activity_Content__c = changeObj.value.message;
                            commentRec.Activity_ID__c = changeObj.value.comment_id;
                            commentRec.Attachment_URL__c = changeObj.value.video;
                            commentRec.Activity_Author__c = changeObj.value.from_c.name;
                            if(changeObj.value.from_c.name == PAGE_NAME) {
                                commentRec.Sent_from_SFDC__c = true;
                            }
                            commentRec.Post_comment_Time__c = changeObj.value.created_time + '';
                            commentRec.Platform_URL__c	 = changeObj.value.post.permalink_url;
                            commentRec.Activity_Type__c = getcommentType(changeObj);
                            system.debug('commentRec --- '+commentRec);
                            postCommentList.add(commentRec);
                        }else {

                            //create case and add comment here.
                            system.debug('ideally this shouldnt happen');
                        }
                    }
                }
            }
            System.debug(' --- postCommentList +'+postCommentList);
            //TODO: DML's and else Conditions
            if(!postCommentList.isEmpty()) {
                try{
                    insert postCommentList;
                    System.debug('--- postCommentList: '+postCommentList);
                }catch(DMLException e) {
                    System.debug('--- DML EXception on: '+e.getLineNumber());
                    System.debug('--- DML EXception message: '+e.getMessage());
                }
            }
        }
    }

    @TestVisible private static String getcommentType(FBPageCommentWrapper.cls_changes changeObj) {
        
        if(changeObj != null && changeObj.value.video != null)
            return COMMENT_TYPE_VIDEO;
        else if(changeObj != null && changeObj.value.photo != null)
            return COMMENT_TYPE_PHOTO;
        else
            return COMMENT_TYPE_TEXT;
    }

    private static void processMention(Map<String,Object> responseMap) {
        Map<String, Object> fbMentionObject = (Map<String, Object>) responseMap.get('value');
        if(fbMentionObject != null && fbMentionObject.get('post_id') != null) {
            List<Case> existingCase = [SELECT Id FROM Case WHERE Post_Id__c = :(String)fbMentionObject.get('post_id') ORDER BY CreatedDate DESC LIMIT 1];
            if(!existingCase.isEmpty()) {
               /*  Case_Communication__c cm = new Case_Communication__c();
                cm.Activity_Content__c = (String)fbMentionObject.get('message');
                cm.Case__c = existingCase[0].Id;
                cm.Activity_Author__c = (String)fbMentionObject.get('sender_name'); 
                cm.OwnerId = RECORD_OWNER_ID;
                try {
                    Database.insert(cm, false);
                }catch(DMLException e) {
                    System.debug('--- e.Message:'+e.getMessage());
                } */
            }else {
                Case newMentionCase = new Case(Brand__c = PAGE_NAME, Type_of_Post__c = 'Tags/Mentions', Description = (String)fbMentionObject.get('message'), Origin = ORIGIN, Subject= 'New mention on FB from: '+ (String)fbMentionObject.get('sender_name') != null ? (String)fbMentionObject.get('sender_name') : '', RecordTypeId = RECORD_TYPE_ID, OwnerId = RECORD_OWNER_ID);
                //Case_Communication__c cm = new Case_Communication__c(Activity_Content__c = (String)fbMentionObject.get('message'), Activity_Author__c = (String)fbMentionObject.get('sender_name')/* , OwnerId = RECORD_OWNER_ID */);
                try {
                    insert newMentionCase;
                    System.debug('--- postCommentList: '+newMentionCase);
                    /* cm.Case__c = cm.Id;
                    Database.insert(cm, false); */
                }catch(DMLException e) {
                    System.debug('--- e.Message:'+e.getMessage());
                }
            }

        }
    }

    public static void processMessages(String requestBody) {
        FBMessageWrapper messageWrapper = (FBMessageWrapper) JSON.deserialize(requestBody, FBMessageWrapper.class);
        if(messageWrapper != null) {
            Map<String,FBMessageWrapper.cls_messaging> senderToMessageMap = new Map<String, FBMessageWrapper.cls_messaging>();
            Map<String, FBMessageWrapper.cls_messaging> replyToMessageMap = new Map<String, FBMessageWrapper.cls_messaging>();
            
            Set<Id> senderIdSet = new Set<Id>();
            Map<String, List<Message_Attachment__c>> msgAttachmentsMap = new Map<String, List<Message_Attachment__c>>();

            for(FBMessageWrapper.cls_entry entry : messageWrapper.entry) {
                for(FBMessageWrapper.cls_messaging message : entry.messaging) {

                    if(message.message.reply_to != null && !String.isBlank(message.message.reply_to.mid)) {
                        replyToMessageMap.put(message.message.reply_to.mid, message);
                        continue;
                    }
                    senderToMessageMap.put(message.sender.id, message);

                    if(message.message.attachments != null) {
                        for(FBMessageWrapper.cls_attachments attachment : message.message.attachments) {
                            if(msgAttachmentsMap.containsKey(message.message.mid)) {
                                msgAttachmentsMap.get(message.message.mid).add(new Message_Attachment__c(Attachment_Type__c = attachment.type, Attachment_URL__c = attachment.payload.url));
                            }else {
                                msgAttachmentsMap.put(message.message.mid, new List<Message_Attachment__c>{ new Message_Attachment__c(Attachment_Type__c = attachment.type, Attachment_URL__c = attachment.payload.url )});
                            }
                        }
                    }
                }
            }

            Map<String, Case_Communication__c> commentsListToCreateMap = new Map<String, Case_Communication__c>();
            Map<String, Case> newConversationCaseMap = new Map<String, Case>();
            Map<String, Case_Communication__c> postCommentMapToInsert = new Map<String, Case_Communication__c>();
            System.debug('--- senderToMessageMap: '+senderToMessageMap);
            if(!senderToMessageMap.isEmpty()) {
                Map<String, Case> senderToCaseMap = new Map<String, Case>();
                List<Case> conversationCaseList = [SELECT Id, Post_Id__c FROM Case WHERE Post_Id__c IN:senderToMessageMap.keySet()];
                for(Case c: conversationCaseList) {
                    senderToCaseMap.put(c.Post_Id__c, c);
                }
                System.debug('--- senderToCaseMap: '+senderToCaseMap);
                for(String senderId : senderToMessageMap.keySet()) {
                    FBMessageWrapper.cls_messaging message = senderToMessageMap.get(senderId);
                    
                    if(senderToCaseMap.containsKey(senderId)) {

                        Case conversation = senderToCaseMap.get(senderId);
                        
                        Case_Communication__c commentRec = new Case_Communication__c();
                        commentRec.Case__c = conversation.Id;
                        commentRec.Activity_Content__c = message.message.text;
                        commentRec.Activity_ID__c = message.message.mid;
                        commentRec.Post_comment_Time__c = message.timestamp + '';
                        
                        commentsListToCreateMap.put(message.message.mid, commentRec);

                    }else {
                        //create case and tag post comment
                        newConversationCaseMap.put(senderId, new Case(Brand__c = PAGE_NAME, RecordTypeId = RECORD_TYPE_ID, Post_Id__c = senderId, OwnerId = RECORD_OWNER_ID, Subject = 'New Message From: '+senderId, Type_of_Post__c='DM', Origin = ORIGIN));
                        
                        Case_Communication__c commentRec = new Case_Communication__c();
                        commentRec.Activity_Content__c = message.message.text;
                        commentRec.Activity_ID__c = message.message.mid;
                        commentRec.Post_comment_Time__c = message.timestamp + '';
                        postCommentMapToInsert.put(senderId, commentRec);
                    }
                }


            }

            //handle reply to messages seperately
            Map<String, Case_Communication__c> replyDMToInsertMap = new Map<String, Case_Communication__c>();
            System.debug('--- replyToMessageMap:'+replyToMessageMap);
            if(!replyToMessageMap.isEmpty()) {
                List<Case_Communication__c> postCommentsListToAddReply = [SELECT Id, Case__c, Activity_ID__c FROM Case_Communication__c WHERE Activity_ID__c IN:replyToMessageMap.keySet()];
                if(!postCommentsListToAddReply.isEmpty()) {
                    Map<String, Case_Communication__c> midToDMMap = new Map<String, Case_Communication__c>();
                    for(Case_Communication__c pComment: postCommentsListToAddReply) {
                        midToDMMap.put(pComment.Activity_ID__c, pComment);
                    }

                    for(String messageId : replyToMessageMap.keySet()) {
                        FBMessageWrapper.cls_messaging message = replyToMessageMap.get(messageId);
                        if(midToDMMap.containsKey(messageId)) {
                            replyDMToInsertMap.put(message.message.mid, new Case_Communication__c(Activity_Content__c = message.message.text, Case__c = midToDMMap.get(messageId).Case__c,Activity_ID__c = message.message.mid, Case_Communication__c = midToDMMap.get(messageId).Id, Post_Comment_Time__c = message.timestamp + ''));
                        }//TODO: if not found then case and message creation, but this is only if case is deleted from SFDC.
                    }
                }
            }

            //DML's
            try {
                
                List<Message_Attachment__c> msgAttachmentToInsert = new List<Message_Attachment__c>();
                if(!newConversationCaseMap.isEmpty()) {
                    System.debug('--- newConversationCaseMap: '+newConversationCaseMap);
                    insert newConversationCaseMap.values();
                    if(!postCommentMapToInsert.isEmpty()) { //always True
                        for(String senderID : postCommentMapToInsert.keySet()) {
                            if(newConversationCaseMap.containsKey(senderID)) {
                                postCommentMapToInsert.get(senderID).Case__c = newConversationCaseMap.get(senderID).Id;
                            }
                        }
                        System.debug('--- newConversationCaseMap : '+newConversationCaseMap);
                        insert postCommentMapToInsert.values();

                        if(!msgAttachmentsMap.isEmpty()) {
                            for(String msgId : msgAttachmentsMap.keySet()) {
                                if(postCommentMapToInsert.containsKey(msgId)) {
                                    for(Message_Attachment__c msgAttachment : msgAttachmentsMap.get(msgId)) {
                                        msgAttachment.Case_Communication__c = postCommentMapToInsert.get(msgId).Id;
                                        msgAttachmentToInsert.add(msgAttachment);
                                    }
                                }
                            }
                        }
                    }
                }
                if(!replyDMToInsertMap.isEmpty()) {
                    System.debug('--- replyDMToInsertMap : '+replyDMToInsertMap);
                    insert replyDMToInsertMap.values();

                    if(!msgAttachmentsMap.isEmpty()) {
                        for(String msgId : msgAttachmentsMap.keySet()) {
                            if(replyDMToInsertMap.containsKey(msgId)) {
                                for(Message_Attachment__c msgAttachment : msgAttachmentsMap.get(msgId)) {
                                    msgAttachment.Case_Communication__c = replyDMToInsertMap.get(msgId).Id;
                                    msgAttachmentToInsert.add(msgAttachment);
                                }
                            }
                        }
                    }
                }
                if(!commentsListToCreateMap.isEmpty()) {
                    System.debug('--- commentsListToCreateMap : '+commentsListToCreateMap);
                    insert commentsListToCreateMap.values();

                    for(Case_Communication__c pc: commentsListToCreateMap.values()) {
                        if(msgAttachmentsMap.containsKey(pc.Activity_ID__c)) {
                            for(Message_Attachment__c msgAttachment : msgAttachmentsMap.get(pc.Activity_ID__c)) {
                                msgAttachment.Case_Communication__c = pc.Id;
                                msgAttachmentToInsert.add(msgAttachment);
                            }
                        }
                    }
                }
                System.debug('--- msgAttachmentToInsert: '+msgAttachmentToInsert);
                if(!msgAttachmentToInsert.isEmpty()) {
                    insert msgAttachmentToInsert;
                }
            }catch(DmlException e) {
                System.debug(' --- e.message :'+e.getMessage());
                System.debug(' --- e.lineno :'+e.getLineNumber());
            }
        }
    }


    public class ResponseWrapper {
        String message;
        String token;
        public ResponseWrapper(String message, String token) { 
            this.message = message;
            this.token = token;
        }
    }

    @HttpGet
    global static Integer verify() {
        System.debug('--- params '+RestContext.request.params);
        String token = RestContext.request.params.get('hub.verify_token');
        Integer challenge = Integer.valueOf(RestContext.request.params.get('hub.challenge'));
        if(token == WEB_TOKEN) {
            return challenge;
        }
        return null;
    }

    public static Id getRecordTypeIdByName(String objectName, String recordTypeName) {
        Id recordTypeId = null;

        // Retrieve the object schema
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();

        // Get all the available record types for the object as a map
        Map<String, Schema.RecordTypeInfo> recordTypeMap = objectDescribe.getRecordTypeInfosByName();

        // Get the Record Type ID directly from the map based on the name
        if (recordTypeMap.containsKey(recordTypeName)) {
            recordTypeId = recordTypeMap.get(recordTypeName).getRecordTypeId();
        }
 
        return recordTypeId;
    }
}