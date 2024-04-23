({
    doInit : function(component, event, helper) {
        debugger;
    },
    downloadFormat : function(component, event, helper){
        debugger;
        var csvMetaData = component.get("v.admCSVFileFormat");  
        var csv = helper.convertArrayToCSV(component,csvMetaData);    
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
         var tempName = component.get("v.docTempName");
        if(tempName == 'OutOfStock'){
            hiddenElement.download = 'OOS Case Upload Temp.csv';
        }
         if(tempName == 'PinCodeService'){
            hiddenElement.download = 'PinCodeService Case Upload Temp.csv';
        }
        if(tempName == 'DeliveryIssue'){
            hiddenElement.download = 'DeliveyIssue Case Upload Temp.csv';
        }
        if(tempName == 'LostInTransit'){
            hiddenElement.download = 'LostInTransit Case Upload Temp.csv';
        }
        if(tempName == 'DeleayInDelivery'){
            hiddenElement.download = 'DeleayInDelivery Case Upload Temp.csv';
        }
         if(tempName == 'RToOrders'){
            hiddenElement.download = 'RTO Orders Case Upload Temp.csv';
        }
          
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
        
    }
})