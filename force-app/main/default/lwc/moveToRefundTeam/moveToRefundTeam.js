import { LightningElement, track, api, wire } from 'lwc';
import getOrderLineItems from '@salesforce/apex/moveToRefundTeamController.getOrderLineItem';
import updateOrderAndCaseFields from '@salesforce/apex/moveToRefundTeamController.updateOrderAndCaseFields';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case from '@salesforce/schema/Case';
import refundReasons from '@salesforce/schema/Case.Refund_Reasons__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import { getRecordNotifyChange } from "lightning/uiRecordApi";


export default class MoveToRefundTeam extends LightningElement {

    // @api AccountIdForLWC = '00eF3000000LBmYIAW';
    @api AccountIdForLWC = '00eF3000000LBojIAG';
    @api recordId;
    @track records = [];
    @track records2 = [];
    @track refundReason;
    @track Coupon;
    @track caseRefund;
    @track contactNumber;
    @track isFullSelected = false;
    @track isPartialSelected = false;
    @track productName;
    @track totalQuantity;
    @track refundQuantity;
    @track ContactPhone;
    @track userdata;
    @track refundteamMemeber;
    @track refundamount;
    @track paidamount;
    @track optionsCategory = [];
    @track opportunityLineItems = [];
    @track selectedValues = [];
    @track checkboxVal = true;
    @track isCheckboxDisabled = true;
    @track checkboxVal2 = false;
    @track updatedRecords = [];
    inpName;
    refundreasonPickListValue
    //@track refundQuantity;
    @track totalprice;
    @track refundPrice;
    filter = {};
    @track type;
    @track subtype;


    @track refundOptions = [
        { label: 'Full', value: 'Full' },
        { label: 'Partial', value: 'Partial' }];


    @track refundtypeOLIOptions = [
        { label: 'Full', value: 'Full' },
        { label: 'Partial', value: 'Partial' }];


    @track couponOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }];

    handelCouponTypeChange(event) {
        debugger;
        this.Coupon = event.target.value;

    }

    handelRefundAmountChange(event) {
        debugger;
        this.paidamount = event.target.value;
    }

    handleChange(event) {
        debugger;
        this.userdata = event.detail.recordId;
    }

    handelOLIRefundReasonChange(event) {
        debugger;
        this.OliRefundReason = event.target.value;
        const rowIndex = parseInt(event.target.dataset.rowIndex);
        this.records[rowIndex].OliRefundReason = event.target.value;
    }

    handelOLIRefundReasonChange1(event) {
        debugger;
        this.OliRefundReason = event.target.value;
        const rowIndex = parseInt(event.target.dataset.rowIndex);
        this.records2[rowIndex].OliRefundReason = event.target.value;
    }

    handleRefundReason(event) {
        debugger;
        this.inpName = event.target.name;
        if (this.inpName == 'RefundReasonFull') {
            const rowIndex = parseInt(event.target.dataset.rowIndex);
        this.records[rowIndex].refundreasonPickListValue = event.target.value;
        }
        if (this.inpName == 'RefundReasonPartial') {
        const rowIndex = parseInt(event.target.dataset.rowIndex);
        this.records2[rowIndex].refundreasonPickListValue = event.target.value;
        }
    }


    connectedCallback() {
        debugger;
        if (this.AccountIdForLWC) {
            this.filter = {
                criteria: [{
                    fieldPath: 'ProfileId',
                    operator: 'eq',
                    value: this.AccountIdForLWC,
                }],
            };
        }
    }



    // Wire service to get object info and picklist values
    @wire(getObjectInfo, { objectApiName: Case })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: refundReasons })
    wiredIndustryData({ error, data }) {
        if (data) {
            this.optionsCategory = data.values;
        } else if (error) {
            console.error('Error in Industry picklist field', JSON.stringify(error));
        }
    }


    @wire(getOrderLineItems, { caseId: '$recordId' })
    wiredAccount({ error, data }) {
        debugger;
        if (data) {
            if(data.orderRecord == null){
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'No Order Found on the Case.',
                    variant: 'error',
                });
                this.dispatchEvent(event);
                this.dispatchEvent(new CloseActionScreenEvent());
                getRecordNotifyChange([{ recordId: this.recordId }]);
            }
            this.caseRefund = data.orderRecord.Refund_Type__c;
            this.refundReason = data.orderRecord.Refund_Reason__c;
            this.Coupon = data.orderRecord.Coupon__c;
            this.ContactPhone = data.caseRecord.Contact_Number__c;
            this.refundteamMemeber = data.caseRecord.RefundTeamMember__c;
            this.userdata = data.caseRecord.RefundTeamMember__c;
            this.refundamount = data.caseRecord.RefundTeamMember__c;
            this.paidamount = data.caseRecord.OrderId__r.Paid_Amount__c;



            if ((data.caseRecord.Sub_Type__c == undefined || data.caseRecord.Sub_Type__c == null || data.caseRecord.Sub_Type__c == '') || (data.caseRecord.Sub_Sub_Type__c == undefined || data.caseRecord.Sub_Sub_Type__c == null || data.caseRecord.Sub_Sub_Type__c == '')) {
                    const event = new ShowToastEvent({
                        title: 'Alert',
                        message: 'Please Enter Case Details before Assigning to Refund Team.',
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    getRecordNotifyChange([{ recordId: this.recordId }]);
            }


            if (this.caseRefund == 'Full') {
                this.refundtypeOli = 'Full';
                this.isFullSelected = true;
                this.isPartialSelected = false;
            } else if (this.caseRefund === 'Partial') {
                this.isFullSelected = false;
                this.isPartialSelected = true;
            } else {
                this.isFullSelected = false;
                this.isPartialSelected = false;
            }

            this.records = data.orderItems.map(item => ({
                productName: item.Product2.Name,
                Id: item.Id,
                totalQuantity: item.Quantity,
                refundQuantity: item.Quantity,
                totalprice: item.TotalPrice,
                isAlreadyUtilized : item.Is_Already_Utilized__c,
                //totalprice: item.Total_Selling_Price__c,
                refundreasonPickListValue: item.Refund_Reasons__c,
                // refundPrice: item.TotalPrice,
                skudetail: item.SKU__c,
                OliRefundReason: item.Refund_Reason__c,
                refundtypeOli: 'Full'
            }));
            debugger;

            this.records2 = data.orderItems.map(item => ({
                productName: item.Product2.Name,
                Id: item.Id,
                totalQuantity: item.Quantity,
                refundQuantity: item.Refund_Quantity__c,
                totalprice: item.TotalPrice,
                isAlreadyUtilized : item.Is_Already_Utilized__c,
                //totalprice: item.Total_Selling_Price__c,
                // refundPrice: item.Refund_Price__c,
                skudetail: item.SKU__c,
                OliRefundReason: item.Refund_Reason__c,
                refundtypeOli: item.Refund_Type__c,
                refundreasonPickListValue: item.Refund_Reasons__c,
                editable: true,
                checkboxVal2: false,
                disableReason: true
            }));

        } else{
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'No Order Found on the Case.',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.dispatchEvent(new CloseActionScreenEvent());
            getRecordNotifyChange([{ recordId: this.recordId }]);
        }
    }
    handelRefundTypeChange(event) {
        debugger;
        if (event.target.value == 'Full') {
            this.caseRefund = 'Full';
            for (var i = 0; i < this.records.length; i++) {
                this.records[i].refundQuantity = this.records[i].totalQuantity;
            }
            this.refundtypeOli = 'Full';
            this.isFullSelected = true;
            this.isPartialSelected = false;
        }
        else {
            this.caseRefund = 'Partial';
            for (var i = 0; i < this.records2.length; i++) {
                if(this.records2[i].refundQuantity == null){
                    this.records2[i].refundQuantity = 0;
                }
            }
            this.refundtypeOli = 'Partial';
            this.isFullSelected = false;
            this.isPartialSelected = true;
        }

    }

    handelrefundChange(event) {
        debugger;
        const rowIndex = event.target.dataset.rowIndex;
        if (parseInt(event.target.value) > this.records2[rowIndex].totalQuantity) {
            alert('Refund Quantity Cannot be Greater Than Total Quantity!');
            this.records2[rowIndex].refundQuantity = null;
        } else {
            this.records2[rowIndex].refundQuantity = parseInt(event.target.value);
            console.log('test');
            if (this.records2[rowIndex].refundQuantity != null && this.records2[rowIndex].totalQuantity != null && this.records2[rowIndex].totalprice != null) {
                this.records2[rowIndex].refundPrice = (this.records2[rowIndex].totalprice / this.records2[rowIndex].totalQuantity) * this.records2[rowIndex].refundQuantity;
            }
            this.records2 = [...this.records2];
        }
        //this.refundQuantity = event.target.value;
    }


    handelRefundTypeOLIChange(event) {
        debugger;
        const rowIndex = event.target.dataset.rowIndex;
        this.records2[rowIndex].refundtypeOli = event.target.value;
        if (this.records2[rowIndex].refundtypeOli == 'Full') {
            this.records2[rowIndex].refundPrice = this.records2[rowIndex].totalprice;
            this.records2[rowIndex].refundQuantity = this.records2[rowIndex].totalQuantity;
            this.records2[rowIndex].editable = true;
            this.records2[rowIndex].disableReason = false;
        }
        else {
            if (this.records2[rowIndex].refundQuantity != null && this.records2[rowIndex].totalQuantity != null && this.records2[rowIndex].totalprice != null) {
                this.records2[rowIndex].refundPrice = (this.records2[rowIndex].totalprice / this.records2[rowIndex].totalQuantity) * this.records2[rowIndex].refundQuantity;
            } else {
                this.records2[rowIndex].refundPrice = 0;
            }
            this.records2[rowIndex].refundtypeOli = event.target.value;
            this.records2[rowIndex].editable = false;
            // if (this.totalprice != undefined && this.totalQuantity != null && this.refundQuantity != '') {
            // this.refundPrice = (this.totalprice / this.totalQuantity) * this.refundQuantity;
            // console.log('refund price' ,this.refundPrice);
            // }
        }
    }

    handelRefundReasonChange(event) {
        debugger;
        this.refundReason = event.target.value;
    }

    handelContactPhoneChange(event) {
        debugger;
        this.ContactPhone = event.target.value;
    }


    handleCheckboxChange1(event) {
        debugger;
        this.selectedValues = event.target.value;
    }

    handleCheckboxChange2(event) {
        debugger;
        const rowIndex = event.target.dataset.rowIndex;
        this.records2 = this.records2.map((record, index) => {
            if (index === parseInt(rowIndex) && event.target.checked) {
                 if(event.target.checked ){
                record.editable = false;
                record.checkboxVal2 = event.target.checked;
                record.disableReason = false;
                // console.log('record.editable===>'+record.editable);
            }
        }else if (index === parseInt(rowIndex) && !event.target.checked) {
            if(!event.target.checked ){
           record.editable = true;
           record.checkboxVal2 = event.target.checked;
           record.disableReason = true;
           // console.log('record.editable===>'+record.editable);
       }
   }
            // }else{
            //     record.editable = true;
            //          record.checkboxVal2 = !event.target.checked;
            // }

            return record;
        });
    }

    handleSave() {
        debugger;

        if (this.caseRefund == undefined || this.caseRefund == null || this.caseRefund == '') {
            alert("Please Select Refund Type");
            return null;
        }
        if (this.refundReason == undefined || this.refundReason == null || this.refundReason == '') {
            alert("Please Enter Refund Reason");
            return null;
        }


        if (this.Coupon == undefined || this.Coupon == null || this.Coupon == '') {
            alert("Please Select Coupon Option");
            return null;
        }


        // if (!this.ContactPhone || this.ContactPhone.length !== 10 || isNaN(this.ContactPhone)) {
        //     alert("Logging Mobile Number should be exactly 10 digits and contain only numbers.");
        //     return false;
        // }


        if (this.userdata == undefined || this.userdata == null || this.userdata == '') {
            alert("Please Select Refund Team Member");
            return null;
        }

        // if (this.caseRefund == 'Full') {
        //     if (this.OliRefundReason == undefined || this.OliRefundReason == null || this.OliRefundReason == '') {
        //         alert("Please Fill Refund description");
        //         return null;
        //     }
        // }
        // if(this.caseRefund == 'Full'){
        //     if (this.refundreasonPickListValue == undefined || this.refundreasonPickListValue == null || this.refundreasonPickListValue == '') {
        //         alert("Please Fill Refund Reason");
        //         return null;
        //     }
        // }
        // if(this.caseRefund == 'Partial'){
        //     if (this.refundreasonPickListValue == undefined || this.refundreasonPickListValue == null || this.refundreasonPickListValue == '') {
        //         alert("Please Fill Refund Reason");
        //         return null;
        //     }
        // }


        // if (this.caseRefund == 'Partial') {
        //     if (this.OliRefundReason == undefined || this.OliRefundReason == null || this.OliRefundReason == '') {
        //         alert("Please Fill Refund description");
        //         return null;
        //     }
        // }

        // if (this.caseRefund === 'Partial') {
        //     for (let i = 0; i < this.records2.length; i++) {
        //         let partialrecord = this.records2[i];
        //         if (partialrecord.OliRefundReason == undefined || partialrecord.OliRefundReason == null || partialrecord.OliRefundReason == '') {
        //             alert("Please Fill Refund Reason for record " + (i + 1));
        //             return;
        //         }
        //         if (this.caseRefund === 'Partial') {
        //             partialrecord.refundtypeOli = event.target.value;
        //         }

        //     }
        // }



        let updatedRecords = [];
        if (this.caseRefund == 'Partial') {
            var isAtleastOneSelected = false;
            for (let i = 0; i < this.records2.length; i++) {
                let obj = this.records2[i];
                if (!obj.editable || ! obj.disableReason) {
                    isAtleastOneSelected = true;
                    if(obj.refundtypeOli == null || obj.refundtypeOli == undefined || obj.refundtypeOli == ''){
                        alert("Please Fill Refund Type for Product " + (i + 1));
                    return;
                    }else if(obj.refundQuantity == undefined || obj.refundQuantity == null || obj.refundQuantity == 0){
                        alert("Please Fill Refund Quantity for record " + (i + 1));
                        return;
                    }else if(obj.refundreasonPickListValue == undefined || obj.refundreasonPickListValue == null || obj.refundreasonPickListValue == ''){
                        alert("Please Fill Refund Reason for record " + (i + 1));
                        return;
                    }                  
                    else if(obj.OliRefundReason == undefined || obj.OliRefundReason == null || obj.OliRefundReason == ''){
                        alert("Please Fill Refund Reason Description for record " + (i + 1));
                    return;
                    }
                    updatedRecords.push({
                        //Refund_Price__c: obj.refundPrice,
                        Refund_Quantity__c: obj.refundQuantity,
                        Refund_Reason__c: obj.OliRefundReason,
                        Refund_Type__c: obj.refundtypeOli,
                        Refund_Reasons__c: obj.refundreasonPickListValue,
                        Is_Already_Utilized__c : obj.isAlreadyUtilized,
                        Id: obj.Id
                    });
                }
                else {
                    updatedRecords.push({
                        //Refund_Price__c: 0,
                        Refund_Quantity__c: 0,
                        Refund_Reason__c: null,
                        Refund_Type__c: null,
                        Refund_Reasons__c:null,
                        Is_Already_Utilized__c : false,
                        Id: obj.Id
                    });
                }
            }if(!isAtleastOneSelected){
                alert("Please Select Atleast 1 Record");
                return;
            }

            console.log(JSON.stringify(updatedRecords));
            this.sendData(updatedRecords);
        } else {
            for (let i = 0; i < this.records.length; i++) {
                let obj = this.records[i];
                if(obj.refundtypeOli == null || obj.refundtypeOli == undefined || obj.refundtypeOli == ''){
                    alert("Please Fill Refund Type for Product " + (i + 1));
                return;
                }else if(obj.refundreasonPickListValue == undefined || obj.refundreasonPickListValue == null || obj.refundreasonPickListValue == ''){
                    alert("Please Fill Refund Reason for record " + (i + 1));
                    return;
                }                  
                else if(obj.OliRefundReason == undefined || obj.OliRefundReason == null || obj.OliRefundReason == ''){
                    alert("Please Fill Refund Reason Description for record " + (i + 1));
                return;
                }
                updatedRecords.push({
                    //Refund_Price__c: obj.refundPrice,
                    Refund_Quantity__c: obj.refundQuantity,
                    Refund_Reason__c: obj.OliRefundReason,
                    Refund_Type__c : obj.refundOptions,
                    Refund_Reasons__c: obj.refundreasonPickListValue,
                    Is_Already_Utilized__c : obj.isAlreadyUtilized,
                    Id: obj.Id

                });
            }

            console.log(JSON.stringify(updatedRecords));
            this.sendData(updatedRecords);
        }
    }


    sendData(oliList) {
        debugger;

        updateOrderAndCaseFields({
            caseId: this.recordId,
            caseRefund: this.caseRefund,
            refundReason: this.refundReason,
            coupon: this.Coupon,
            refundValue :this.refundreasonPickListValue,
            refundTeamMemberId: this.userdata,
            paidamount: this.paidamount,
            //contactNumber : this.ContactPhone
            orderItemsToUpdate: oliList
        }).then((result) => {
            if (result == 'success') {
                this.showToast('Success', 'Records saved successfully', 'success');
            }

            //this.records2 = updatedRecords;

            const closeActionEvent = new CloseActionScreenEvent();
            this.dispatchEvent(closeActionEvent);
            //this.dispatchEvent(new RefreshEvent());
            getRecordNotifyChange([{ recordId: this.recordId }]);
        }).catch(error => {
            console.error(error);
            this.showToast('Error', 'Error occurred while saving records', 'error');
        });
    }

    handleCancel() {
        const closeActionEvent = new CloseActionScreenEvent();
        this.dispatchEvent(closeActionEvent);
        this.dispatchEvent(new RefreshEvent());
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}