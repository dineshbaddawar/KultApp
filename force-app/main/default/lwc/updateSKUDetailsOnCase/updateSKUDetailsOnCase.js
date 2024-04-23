import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getOrderIfItHasLineItems from '@salesforce/apex/CaseHelperControllers.getOrderIfItHasLineItems';
import getOrderItems from '@salesforce/apex/CaseHelperControllers.getOrderItems';
import updateSKUdetailsAndCreateRecordOfSKU from '@salesforce/apex/CaseHelperControllers.updateSKUdetailsAndCreateRecordOfSKU';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';


export default class UpdateSKUDetailsOnCase extends LightningElement {

    selectedSalesUserId;
    inpName;
    selectedOrd;
    @track orderHasItemAvailable = false;
    @track AllOrderItems = [];
    @track OrderList = [];
    @track selectedOrderId = [];
    selectedRows = [];
    @track show1stPage = true;
    @track show2ndPage = false;
    data;
    error;
    @track CaseOrderAndOrderLineItem = [];
    @track orderNameOrNumberAvailable = false;
    @track orderNumberOrName;
    ordersId;
    @api recordId;

    @track allKeys = '';
    @track message;
    @track error;
    @track recordTypeId = '';

    connectedCallback() {

        var url = window.location.href.toString();
        const queryParams = url.split("&");
        const recordIdParam = queryParams.find(param => param.includes("recordId"));

        if (recordIdParam) {
            const recordIdKeyValue = recordIdParam.split("=");
            if (recordIdKeyValue.length === 2) {
                const recordId = recordIdKeyValue[1];
                this.recordId = recordId;
            } else {
                console.error("Invalid recordId parameter format");
            }
        } else {
            console.error("recordId parameter not found in the URL");
        }
        this.doSearch();



    }

    callAllOrderItems() {
        debugger;
        this.AllOrderItems = [];
        getOrderItems({ OrdId: this.selectedRecordIdFromParent })
            .then(result => {
                result.forEach(item => {
                    this.AllOrderItems.push({
                        productName: item.Product2.Name,
                        Id: item.Id,
                        totalQuantity: item.Quantity,
                        totalprice: item.Total_Selling_Price__c,
                        skudetail: item.SKU__c,
                    });
                });
                this.error = undefined;
                this.orderHasItemAvailable = true;
            })
            .catch(error => {
                this.error = error;
                this.AllOrderItems = undefined;
            });
    }

    doSearch() {
        debugger;
        getOrderIfItHasLineItems({
            recId: this.recordId
        }).then(result => {
            this.CaseOrderAndOrderLineItem = result;

            if (this.CaseOrderAndOrderLineItem && this.CaseOrderAndOrderLineItem.length > 0) {

                // Order is available


                if (this.CaseOrderAndOrderLineItem[0].Order.Name != null) {
                    this.orderNumberOrName = this.CaseOrderAndOrderLineItem[0].Order.Name;
                    this.orderNameOrNumberAvailable = true;
                } else {
                    this.orderNumberOrName = this.CaseOrderAndOrderLineItem[0].Order.OrderNumber;
                    this.orderNameOrNumberAvailable = true;
                }

                if (this.CaseOrderAndOrderLineItem[0].OrderId != null) {
                    this.ordersId = this.CaseOrderAndOrderLineItem[0].OrderId;
                }

                this.CaseOrderAndOrderLineItem.forEach(item => {
                    this.AllOrderItems.push({
                        productName: item.Product2.Name,
                        Id: item.Id,
                        totalQuantity: item.Quantity,
                        totalprice: item.Total_Selling_Price__c,
                        skudetail: item.SKU__c
                    });
                });

                this.error = undefined;

                this.AllOrderItems = [];

                getOrderItems({
                    OrdId: this.ordersId
                }).then(result => {
                    result.forEach(item => {
                        this.AllOrderItems.push({
                            productName: item.Product2.Name,
                            Id: item.Id,
                            totalQuantity: item.Quantity,
                            totalprice: item.Total_Selling_Price__c,
                            skudetail: item.SKU__c
                        });
                    });

                    this.error = undefined;


                }).catch(error => {
                    this.error = error;
                    this.AllOrderItems = undefined;
                });
                if (this.ordersId != null) {
                    this.orderHasItemAvailable = true;
                }

            } else {
                // Order not found logic
                this.show2ndPage = true;
                this.show1stPage = false;
                this.error = 'Order not found'; // You can set an error message here
            }
        }).catch(error => {
            this.error = error;
            this.Case = undefined;
        });


    }


    displayInfo = {
        primaryField: 'Name'
    };

    closeAction() {
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    deselectRow(rowId) {
        const checkbox = this.template.querySelector(`[data-id="${rowId}"]`);
        if (checkbox) {
            checkbox.checked = false;
            this.handlesChange({ target: checkbox });
        }
    }

    handleEnter(event) {
        debugger;
        const keyPressed = event.key;

        // Concatenate the new key with the existing keys
        this.allKeys += keyPressed;

        if (this.allKeys) {
            this.filter = {
                criteria: [{
                    fieldPath: 'Name',
                    operator: 'eq',
                    value: this.allKeys,
                }],
            };
        }

    }

    hanldeProgressValueChange(event) {
        debugger;
        this.selectedRecordIdFromParent = event.detail;
        this.callAllOrderItems();
        // this.getRecordDetails();
    }

    handlesChange(event) {
        debugger;
        this.inpName = event.target.name;

        this.selectedSalesUserId = event.currentTarget.dataset.index;
        let selectedLineItemId = event.currentTarget.dataset.id; // Assuming this gives you the ID of the selected item

        if (event.target.type === 'checkbox') {
            if (event.target.checked) {
                this.selectedRows.push(selectedLineItemId); // Add to selectedRows if checked
            } else {
                const index = this.selectedRows.indexOf(selectedLineItemId);
                if (index !== -1) {
                    this.selectedRows.splice(index, 1); // Remove from selectedRows if unchecked
                }
            }
        }

        console.log('selectedRows==> ' + JSON.stringify(this.selectedRows));

        if (this.inpName == 'selectedOrder') {
            this.selectedOrd = event.detail.recordId;


        }

    }

    handleClick() {
        debugger;
        updateSKUdetailsAndCreateRecordOfSKU({
            recId: this.recordId,
            ordId: this.selectedRecordIdFromParent,
            ordLinItmList: this.selectedRows
        })
            .then(result => {
                if (result) {
                    this.data = result;
                    const event = new ShowToastEvent({
                        title: 'Case Updated SuccessFully ',
                        variant: 'success',
                        message: 'The case has been created successfully.'
                    });
                    this.dispatchEvent(event);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(new RefreshEvent());
                }
            })
            .catch(error => {
                this.error = error;
                console.log('error == >' + error);
            });
    }
}