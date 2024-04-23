({
    doInit : function(component, event, helper) {
        debugger;
        var recId = component.get("v.recordId");
        var action = component.get("c.getRepliesDetails");
        
        action.setParams({
            recordId: recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var paginationList = [];
                var temResult=[];
                var temResultSize;
                console.log(serverresponse);
                var serverresponse = response.getReturnValue();
                component.set("v.commentDescription",serverresponse[0].commentDescription);
                component.set("v.commentedBy",serverresponse[0].commentedBy);
                component.set("v.urlToPost",serverresponse[0].postUrl);
                component.set("v.mainCommentId",serverresponse[0].mainCommentId);
                component.set("v.relatedReplyList",serverresponse);
                if(serverresponse.length > 0){
                    var recordsPerPage = component.get("v.numberOfRecordsToBeShown");
                    component.set("v.TotalPages",Math.round(serverresponse.length/recordsPerPage));
                    var serverResp = [];
                    if(serverresponse.length < recordsPerPage){
                        for (let i = 0; i < serverresponse.length; i++) {
                            serverResp.push(serverresponse[i]);
                        }   
                    }else{
                        for (let i = 0; i < recordsPerPage; i++) {
                            serverResp.push(serverresponse[i]);
                        }    
                    }
                    
                    component.set("v.paginationCommentList",serverResp);
                    component.set("v.TotalRecords",serverresponse.length);
                }
            }
        });
        $A.enqueueAction(action); 
    },
    
    replyToComment : function(component, event, helper) {
        debugger;
        component.set("v.showSpinner",true);
        var rowIndex = event.target.value;
        var relatedReplyList = component.get("v.relatedReplyList");
        var currentTargetRow  = relatedReplyList[rowIndex];
        var action = component.get("c.replyToCommentOnInsta");
        if(currentTargetRow.replyMessage == undefined || currentTargetRow.replyMessage == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'error',
                message: 'please type some message to proceed!!',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set("v.showSpinner",false);
            $A.get('e.force:refreshView').fire();
            return;
        }
        action.setParams({
            "commentId" : currentTargetRow.id ,
            "commentMessage" : currentTargetRow.replyMessage
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner",false);
                component.set("v.isModalOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Reply posted to Comment!!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
    navigateToPost : function(component, event, helper) {
        debugger;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get("v.urlToPost")
        });
        urlEvent.fire();
    },
    
    refreshFeed : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var recId = component.get("v.recordId");
        var action = component.get("c.getUpdatedComments");
        action.setParams({
            recordId: recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.showSpinner",false);
                window.location.reload();
            }else{
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action); 
    },
    
    openModel : function(component, event, helper) {
        debugger;
        var comment       = event.getSource().get('v.value');
        var commentedBy   = event.getSource().get('v.name');
        var commentId     = event.getSource().get('v.title');
        var serverresponse     =  component.get("v.relatedReplyList")
        component.set("v.selectedCommentId",commentId);
        component.set("v.selectedCommentValue",comment);
        component.set("v.selectedCommentRepliedBy",commentedBy);
        
        if(serverresponse.length > 0){
            var recordsPerPage = component.get("v.numberOfRecordsToBeShown");
            if(recordsPerPage < serverresponse.length){
                component.set("v.TotalPages",serverresponse.length/recordsPerPage);
                var serverResp = [];
                for (let i = 0; i < recordsPerPage; i++) {
                    serverResp.push(serverresponse[i]);
                }
                component.set("v.paginationCommentList",serverResp);
            }
            component.set("v.TotalRecords",serverresponse.length);
            component.set("v.RecordStart",1);
            component.set("v.RecordEnd",recordsPerPage);
        }
        
        component.set("v.showReplies",true);
    },
    
    closeModel : function(component, event, helper) {
        debugger;
        component.set("v.isModalOpen",false);
        component.set("v.showReplies",false);
    },
    
    handleNext: function(component, event, helper) {
        debugger;
        var pageNumber = component.get("v.PageNumber");  
        var commentsList = component.get("v.relatedReplyList");
        var recordsPerPage = component.get("v.numberOfRecordsToBeShown") ;
        var recordsToBeSkipped = pageNumber * recordsPerPage;
        if(recordsToBeSkipped < commentsList.length){
            var serverResp = [];
            for (let i = recordsToBeSkipped; i < (recordsToBeSkipped+recordsPerPage); i++) {
                serverResp.push(commentsList[i]);
            }
            component.set("v.paginationCommentList",serverResp);
        }
        pageNumber++;
        component.set("v.RecordStart",component.get("v.RecordStart") + recordsPerPage );
        component.set("v.RecordEnd",component.get("v.RecordEnd") + recordsPerPage);
        component.set("v.PageNumber",pageNumber);
    },
    
    handlePrev: function(component, event, helper) {
        debugger;
        var pageNumber = component.get("v.PageNumber");
        var commentsList = component.get("v.relatedReplyList");
        var recordsPerPage = component.get("v.numberOfRecordsToBeShown") ;
        
        var serverResp = [];
        for (let i = (pageNumber-2)*recordsPerPage; i < (pageNumber-1)*recordsPerPage ; i++) {
            serverResp.push(commentsList[i]);
        }
        component.set("v.paginationCommentList",serverResp);
        
        pageNumber--;
        component.set("v.PageNumber",pageNumber);
        component.set("v.RecordStart",component.get("v.RecordStart") - recordsPerPage );
        component.set("v.RecordEnd",component.get("v.RecordEnd") - recordsPerPage);
    } ,
    openModel : function(component, event, helper) {
        debugger;
        component.set("v.isModalOpen",true);
    },
    postComment : function(component, event, helper) {
        debugger;
        component.set("v.spinner",true);
        var commentId      = component.get("v.mainCommentId");
        var commentMessage = component.get("v.replyMessage");
        
        var action         = component.get("c.replyToComment");
        action.setParams({
            commentId: commentId,
            commentMessage : commentMessage
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The comment has been posted successfully!!"
                });
                toastEvent.fire();
                component.set("v.isModalOpen",false);
            }else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    
})