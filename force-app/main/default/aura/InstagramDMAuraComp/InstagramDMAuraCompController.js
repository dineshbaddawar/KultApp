({
    doInit : function(component, event, helper) {
        debugger;
        component.set("v.showLwc",false);
        var recId = component.get("v.recordId");
        var action = component.get("c.getInstaDmDetails");
        action.setParams({
            recordId: recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.chatMessages",response.getReturnValue());     
                component.set("v.totalMessages",response.getReturnValue().length);
                component.set("v.senderName",response.getReturnValue()[0].sender);
                component.set("v.recipientId",response.getReturnValue()[0].senderId);
                component.set("v.chatInitiatedTime",response.getReturnValue()[0].timestamp);  
                component.set("v.showLwc",true);
            }else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    handleSendReply : function(component, event, helper) {
        debugger;
        component.set("v.showSpinner",true);
        var recipientId      = component.get("v.recipientId");
        var commentMessage = component.get("v.messageContext");
        var action         = component.get("c.sendMessage");
        
        action.setParams({
            recipientId: recipientId,
            messageText : commentMessage,
            caseId : component.get("v.recordId"),
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
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Something went wrong!"
                });
                toastEvent.fire();
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action); 
    },
    
    handleRecordUpdated : function(component, event, helper) {
		debugger;
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            var changedFields = eventParams.changedFields;
            var doInit = component.get('c.doInit');
            $A.enqueueAction(doInit);
        }
    }
})