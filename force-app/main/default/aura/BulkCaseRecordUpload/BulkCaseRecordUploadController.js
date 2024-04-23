({
    onchange: function(component, event, helper) {
        debugger;
        event.stopPropagation();
        event.preventDefault();
        debugger;
        var fileName = 'No File Selected.';
        if (event.getSource().get("v.files").length > 0) { 
            fileName = event.getSource().get("v.files")[0];
        }
        var textFileName = fileName['name'];
        const parts = textFileName.split('.');
        const extension = parts[parts.length - 1];
        if(extension == 'xlsx' || extension == 'xls'){
            var lwcComponent = component.find("lwcComponent");
            lwcComponent.handleFileUpload(event);   
        }
        component.set("v.FileNameRecord", fileName['name']);
        helper.readFile(component,helper,fileName);
    },
    processFileContent : function(component,event,helper){
        debugger;
        helper.saveRecords(component,event);
    },
    cancel : function(component,event,helper){
        component.set("v.showFirstScreen",true);
        component.set("v.showMain",false);
    },
    
    handleClickOutOfStock : function(component,event,helper){
        debugger;
        var tempName = 'OutOfStock';
        component.set("v.tempNameToDownload",tempName); 
        component.set("v.showScondScreen",true);
        component.set("v.showFirstScreen", false);
        //  component.set("v.showFourthscreen",true);
    },
    handleClickPincodeNotservice : function(component,event,helper){
        debugger;
        var tempName = 'PinCodeService';
        component.set("v.tempNameToDownload",tempName);
        component.set("v.showScondScreen",true);
        component.set("v.showFirstScreen",false);
    },
    handleClickCourierDeliveryIssue : function(component,event,helper){
        debugger;
        var tempName = 'DeliveryIssue';
        component.set("v.tempNameToDownload",tempName);
        component.set("v.showScondScreen",true);
        component.set("v.showFirstScreen",false);
    },
    handleClickLostInTransit : function(component,event,helper){
        debugger;
        var tempName = 'LostInTransit';
        component.set("v.tempNameToDownload",tempName);
        component.set("v.showScondScreen",true);
        component.set("v.showFirstScreen",false);
    },
    handleClickDelayInDelivery : function(component,event,helper){
        debugger;
        var tempName = 'DeleayInDelivery';
        component.set("v.tempNameToDownload",tempName);
        component.set("v.showScondScreen",true);
        component.set("v.showFirstScreen",false);
    },
    handleClickRToOrders : function(component,event,helper){
        debugger;
        var tempName = 'RToOrders';
        component.set("v.tempNameToDownload",tempName);
        component.set("v.showScondScreen",true);
        component.set("v.showFirstScreen",false);
    },
    
    onChangeFileType: function (component, event, helper) {
        debugger;
        var selectedFileType = component.find('select').get('v.value');
        if (selectedFileType == 'csv') {
            component.set("v.showScondScreen", true); 
            component.set("v.showFourthscreen",false);
        } else {
            component.set("v.showScondScreen",false);
        }
        if (selectedFileType == 'xls') {
            component.set("v.showFifthscreen", true); 
            component.set("v.showFourthscreen",false);
        } else {
            component.set("v.showFifthscreen", false); 
        }
    }
    
})