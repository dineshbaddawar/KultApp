({
	doInit : function(component, event, helper) {
		debugger;
        var action = component.get('c.getTranscriptAndOrderDetails');
        action.setParams({
            recId : component.get('v.recordId') 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result.orderRec != null && result.orderRec != undefined){
                    component.set('v.isOrderTaggedOnCase', true);
                    component.set('v.orderNotFound', false);
                    component.set('v.orderRec', result.orderRec);
                    component.set('v.orderLineItems', result.orderLineItems);
                }else{
                    component.set('v.isOrderTaggedOnCase', false);
                    component.set('v.orderNotFound', true);
                }
            }
        });
        $A.enqueueAction(action);
	}
})