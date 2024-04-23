({
    doInit: function(component, event, helper){
        debugger;
        var action = component.get('c.getCaseAndOrderDetails');
        action.setParams({
            caseId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.caseRec', result.caseRec);
                component.set('v.oliList', result.oliList);
                component.set('v.showOrderItemList', true);
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    submitDetails: function(component, event, helper) {
        debugger;
        var toastEvent = $A.get("e.force:showToast");
        var oliList = component.get('v.oliList');
        for(var i in oliList){
            oliList[i].Quantity = oliList[i].newQty;
            oliList[i].OriginalOrderItemId = oliList[i].Id;
            oliList[i].Is_Duplicate_Order__c = true;
            delete oliList[i]['newQty'];
            delete oliList[i]['Id'];
        }
        var action = component.get('c.createDupOrder');
        action.setParams({
            oliList : oliList,
            caseId : component.get('v.recordId'),
            caseRec : component.get('v.caseRec')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
            	toastEvent.setParams({
            title : 'Info',
            message: 'Duplicate Order Created Successfully.',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
            }else{
               toastEvent.setParams({
            title : 'Error',
            message:'Some Error Occurred.',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        }); 
            }
            toastEvent.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
           },
})