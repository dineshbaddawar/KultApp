({
    convertArrayToCSV : function(component,metaDataRecord){
        debugger;
        var csvStringResult, counter, keys, columnDivider, lineDivider; 
        columnDivider = ',';
        lineDivider =  '\n';
        var tempName =  component.get("v.docTempName"); 
        if(tempName == 'OutOfStock'){
            keys = ['Order No','Date Of Order','Shipping Mobile No','Reason','Item','OOS Quantity','OOS SKU Code','Remarks'];
        }
        if(tempName == 'PinCodeService'){
             keys = ['Order No','Date Of Order','Shipping Mobile No','Reason','Current PIN Code'];
        }
        if(tempName == 'DeliveryIssue'){
             keys = ['Order No','Date Of Order','Shipping Mobile No','Reason','Current PIN Code','City Name'];
        }
         if(tempName == 'LostInTransit'){
             keys = ['Order No','Date Of Order','Shipping Mobile No','Reason','Courier Partner','AWB Number'];
        }
         if(tempName == 'DeleayInDelivery'){
             keys = ['Order No','Date Of Order','Shipping Mobile No','Reason','Courier Partner','AWB Number'];
        }
        if(tempName == 'RToOrders'){
             keys = ['Order No','Date Of Order','Shipping Mobile No','Reason','Remarks','Order Status'];
        }
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider; 
        return csvStringResult;        
    },
    
})