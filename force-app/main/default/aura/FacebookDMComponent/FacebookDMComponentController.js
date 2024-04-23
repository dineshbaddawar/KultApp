({
    doInit : function(component, event, helper) {
        debugger;
        var recId = component.get("v.recordId");
        var action = component.get("c.getCaseDetails");
        
        action.setParams({
            recordId: recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var serverresponse = response.getReturnValue();
            if (state === 'SUCCESS' && serverresponse) {
                component.set("v.tweetDescription",serverresponse.description);
                component.set("v.recepientid", serverresponse.recepientId);
                component.set("v.brand", serverresponse.brand);
                component.set("v.relatedCommentList",serverresponse.commentWrapperList);
                var commList = serverresponse.commentWrapperList;
                if(commList.length > 0){
                    var recordsPerPage = component.get("v.numberOfRecordsToBeShown");
                    if(recordsPerPage < serverresponse.commentWrapperList.length){
                        component.set("v.TotalPages",commList.length/recordsPerPage);
                        var serverResp = [];
                        if(serverresponse.length < recordsPerPage){
                            for (let i = 0; i < serverresponse.length; i++) {
                                serverResp.push(serverresponse[i]);
                            }   
                        }else{
                            for (let i = 0; i < recordsPerPage; i++) {
                                serverResp.push(commList[i]);
                            }    
                        }
                        
                        component.set("v.PaginationList",serverResp);
                    }else{
                        component.set("v.TotalPages",1);
                        var serverResp = [];
                        for (let i = 0; i < commList.length; i++) {
                            serverResp.push(commList[i]);
                        }
                        component.set("v.PaginationList",serverResp);
                    }
                    component.set("v.TotalRecords",commList.length);
                }
            }
        });
        $A.enqueueAction(action); 
    },
    
    handleSearch: function(component, event, helper) {
        debugger;
        var searchKeyword = event.currentTarget.value;
        if(searchKeyword && searchKeyword.length < 2){
            return;   
        }
        var data = component.get("v.relatedCommentList");
        searchKeyword = searchKeyword.toLowerCase();
        var filteredData = data.filter(item => {
            debugger;
            const { comment, CommentedBy } = item;
            const lowerCaseName = comment ? comment.toLowerCase() : '';
            const lowerCaseBy = CommentedBy ? CommentedBy.toLowerCase() : '';
            return lowerCaseName.includes(searchKeyword) || lowerCaseBy.includes(searchKeyword);
        });
        component.set("v.PaginationList", filteredData);
    },
    
    openModel : function(component, event, helper) {
        debugger;
        var comment       = event.getSource().get('v.value');
        var commentedBy   = event.getSource().get('v.name');
        var commentId     = event.getSource().get('v.title');
        var parentId      = event.getSource().get('v.variant');
        var serverresponse     =  component.get("v.relatedCommentList");
        component.set("v.parentCommentId",parentId);
        component.set("v.selectedCommentId",commentId);
        component.set("v.selectedCommentValue",comment);
        component.set("v.selectedCommentRepliedBy",commentedBy);
        component.set("v.isModalOpen",true);
    },
    
    closeModel : function(component, event, helper) {
        debugger;
        component.set("v.isModalOpen",false);
        component.set("v.showReplies",false);
    },
    
    postComment : function(component, event, helper) {
        debugger;
        component.set("v.spinner",true);
        var commentId      = component.get("v.selectedCommentId");
        var recId      = component.get("v.recepientid");
        var commentMessage = component.get("v.replyMessage");
        var parentSFID     = component.get("v.parentCommentId");
        var brand          = component.get("v.brand");
        var action         = component.get("c.sendMessage");
        
        action.setParams({
            config: brand,
            recipientId: recId,
            messageText : commentMessage,
            caseId : component.get("v.recordId"),
            parentCommentId: parentSFID,
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Message sent successfully!!"
                });
                toastEvent.fire();
                component.set("v.replyMessage","");
                component.set("v.isModalOpen",false);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Something went wrong!"
                });
                toastEvent.fire();
            }
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action); 
    },
    
    viewCommentReplies : function(component, event, helper) {
        debugger;
        component.set("v.spinner",true);
        var comment       = event.getSource().get('v.value');
        var commentedBy   = event.getSource().get('v.name');
        var commentId     = event.getSource().get('v.title');
        component.set("v.selectedCommentId",commentId);
        component.set("v.selectedCommentValue",comment);
        component.set("v.selectedCommentRepliedBy",commentedBy);
        var action         = component.get("c.getRepliesDetails");
        action.setParams({
            commentId: commentId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var serverresponse = response.getReturnValue();
                if(serverresponse.length > 0){
                    component.set("v.relatedReplyList",serverresponse);
                    component.set("v.showReplies",true);
                    component.set("v.spinner",false);    
                    if(serverresponse.length > 0){
                        var recordsPerPage = component.get("v.numberOfRecordsToBeShown");
                        var serverResp = [];
                        for (let i = 0; i < recordsPerPage; i++) {
                            serverResp.push(serverresponse[i]);
                        }
                        component.set("v.PaginationList",serverResp);
                        component.set("v.TotalRecords",serverresponse.length);
                        component.set("v.PageNumber",1);
                        if(serverresponse.length > recordsPerPage){
                            component.set("v.TotalPages",serverresponse.length/recordsPerPage);    
                        }else{
                            component.set("v.TotalPages",1);
                        }
                    }
                }else{
                    component.set("v.relatedReplyList",[]);
                    component.set("v.showReplies",true);
                    component.set("v.spinner",false);  
                }
                
            }else{
                
            }
        });
        $A.enqueueAction(action); 
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
            component.set("v.PaginationList",serverResp);
        }
        pageNumber++;
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
        component.set("v.PaginationList",serverResp);
        
        pageNumber--;
        component.set("v.PageNumber",pageNumber);        
    },
    
})