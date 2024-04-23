({
    init : function(component, event, helper) {
        debugger;
        var action = component.get('c.getCaseDetailsAndPicklistValues');
        action.setParams({
            recId : component.get('v.recordId') 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                var cxReqOptions = result.customerRequestOptions;
                var cxRequestOriginal = [...cxReqOptions];
                var caseRec = result.caseRec;
                if(!caseRec.OwnerId.startsWith('005')){
                    helper.showToast('Case is in a queue', 'Error', 'error');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    return;
                }
                if(caseRec.Origin.includes('Outbound') || caseRec.Origin == 'Bulk Upload'){
                    component.set('v.showOutBound', true);
                }
                if(caseRec.Type_Of_Case__c != null && caseRec.Type_Of_Case__c != undefined && caseRec.Type_Of_Case__c != ''){
                    component.set('v.disableCxRequest', false);
                }
                var countryOptions = result.countryList;
                var statesByCountry = result.statesByCountry;
                var caseReasonOptions = result.caseReasonOptions;
                if(caseRec.Address_With_Pin_Code__CountryCode__s != null && caseRec.Address_With_Pin_Code__CountryCode__s != undefined && caseRec.Address_With_Pin_Code__CountryCode__s != ''){
                    var stateList = statesByCountry[caseRec.Address_With_Pin_Code__CountryCode__s];
                    component.set('v.stateList', stateList);
                }
                component.set('v.countryList', countryOptions);
                component.set('v.statesByCountry', statesByCountry);
                if(caseRec.Sub_Type__c == null || caseRec.Sub_Sub_Type__c == null){
                    helper.showToast('Please Enter Case Details Before Moving the Case', 'Alert', 'alert');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                if(caseRec.Customer_s_Request__c == 'Address Change'){
                    component.set('v.showAddressField', true);
                }
                var oliList = result.oliList;
                component.set('v.caseReasonOptions', caseReasonOptions);
                component.set('v.cxRequestOptionsOriginal', cxRequestOriginal);
                component.set('v.cxRequestOptions', cxReqOptions);
                component.set('v.caseRec', caseRec);
                component.set('v.oliList', oliList);
            }
        });
        $A.enqueueAction(action);
    },

    handleReason : function(component, event, helper){
        debugger;
        var selectedOption = component.get('v.caseRec.Type_Of_Case__c');
        var cxRequestOptions = component.get('v.cxRequestOptions');
        var cxRequestOptions2 = component.get('v.cxRequestOptionsOriginal');
        var newList=[];
        if(selectedOption == 'Out Of Stock (OOS)' || selectedOption == 'Lost In Transit' || selectedOption == 'Return to Origin (RTO)' || selectedOption == 'Delay In Delivery (DID)'){
            for(var i in cxRequestOptions){
                if(cxRequestOptions[i] != 'Address Change'){
                    newList.push(cxRequestOptions[i]);
                }
            }
            component.set('v.cxRequestOptions', newList);
        }else{
            component.set('v.cxRequestOptions', cxRequestOptions2);
        }
        if(selectedOption != null && selectedOption != undefined && selectedOption != ''){
            component.set('v.disableCxRequest', false);
        }else{
            component.set('v.disableCxRequest', true);
        }
    },
    
    handleCxRequest : function(component, event, helper) {
        debugger;
        var selectedOption = component.get('v.caseRec.Customer_s_Request__c');
        // if(selectedOption == 'Partial Cancellation'){
        //     component.set('v.showPartialWindow', true);}
         if(selectedOption == 'Address Change'){
            component.set('v.showAddressField', true);
        }else{
            component.set('v.showAddressField', false);
        }
    },

    handleCountrySelect : function(component, event, helper){
        debugger;
        var selectedCountry = component.get('v.caseRec.Address_With_Pin_Code__CountryCode__s');
        var statesByCountry = component.get('v.statesByCountry');
        var stateList = statesByCountry[selectedCountry];
        component.set('v.stateList', stateList);
    },
    
    handleSelectRow : function(component, event, helper){
        debugger;
        var index = event.getSource().get("v.name");
        var oliList = component.get('v.oliList');
        oliList[index].checked = true;
    },
    
    closeModel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    submitDetails: function(component, event, helper){
        debugger;
        var caseRec = component.get('v.caseRec');
        var isOutbound = component.get('v.showOutBound');
        if(isOutbound && (caseRec.Type_Of_Case__c == undefined || caseRec.Type_Of_Case__c == '' || caseRec.Type_Of_Case__c == null)){
            helper.showToast('Please Enter Reason for Assignment', 'Alert', 'warning');
            return;
        }else if(isOutbound && (caseRec.Customer_s_Request__c == undefined || caseRec.Customer_s_Request__c == '' || caseRec.Customer_s_Request__c == null)){
            helper.showToast('Please Select Customer Request', 'Alert', 'warning');
            return;
        }else if(isOutbound && (component.get('v.showAddressField') && (caseRec.Address_With_Pin_Code__Street__s == undefined || caseRec.Address_With_Pin_Code__Street__s == '' || caseRec.Address_With_Pin_Code__Street__s == null ||
        caseRec.Address_With_Pin_Code__City__s == undefined || caseRec.Address_With_Pin_Code__City__s == '' || caseRec.Address_With_Pin_Code__City__s == null || 
        caseRec.Address_With_Pin_Code__CountryCode__s == undefined || caseRec.Address_With_Pin_Code__CountryCode__s == '' || caseRec.Address_With_Pin_Code__CountryCode__s == null || 
        caseRec.Address_With_Pin_Code__StateCode__s == undefined || caseRec.Address_With_Pin_Code__StateCode__s == '' || caseRec.Address_With_Pin_Code__StateCode__s == null || 
        caseRec.Address_With_Pin_Code__PostalCode__s == undefined || caseRec.Address_With_Pin_Code__PostalCode__s == '' || caseRec.Address_With_Pin_Code__PostalCode__s == null ))){
            helper.showToast('Please Enter New Address', 'Alert', 'warning');
            return;
        }else if(isOutbound && (component.get('v.showAddressField') && (caseRec.Shipping_Mobile_No__c == undefined || caseRec.Shipping_Mobile_No__c == '' || caseRec.Shipping_Mobile_No__c == null))){
            helper.showToast('Please Enter Shipping Mobile Number', 'Alert', 'warning');
            return;
        }else if(caseRec.Remarks_mentioned__c == undefined || caseRec.Remarks_mentioned__c == '' || caseRec.Remarks_mentioned__c == null){
            helper.showToast('Please Enter Remarks', 'Alert', 'warning');
            return;
        }
        var action = component.get('c.moveToWHteams');
        action.setParams({
            caseRec : component.get('v.caseRec'),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var result = response.getReturnValue();
                if(result == 'Successful'){
                    helper.showToast('Case Successfully Moved to Warehouse Team', 'Success', 'success');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    helper.showToast('Some error occurred', 'Error', 'error');
                }
            }
        });
        $A.enqueueAction(action);
    }
})