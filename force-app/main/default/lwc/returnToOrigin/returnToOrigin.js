import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import Case from '@salesforce/schema/Case';
import RelationShipField from '@salesforce/schema/Case.Reason_for_RTO__c';
import CaseReason from '@salesforce/schema/Case.RTO_Reso__c';
import CaseOrderId from '@salesforce/schema/Case.OrderId__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import returnToOrigin from '@salesforce/apex/CaseHelperControllers.returnToOrigin';
import showAllCaseData from '@salesforce/apex/CaseHelperControllers.showAllCaseData';
import { getRecordNotifyChange } from "lightning/uiRecordApi";

export default class ReturnToOrigin extends LightningElement {
    @api recordId;
    @track optionsCategory = [];
    @track lstRecordTypes = [];
    inpName;
    @track prodName = [];
    @track OrdName = [];
    @track ReOrdQuan = [];
    ReasonPickList;
    ResolutionPickList;
    allResult;
    IdOfOrder;
    @track OrderLineItem = [];
    @track OrderLineItemWired;
    enterReasonOfDuplicateOrder;
    @track createDuplicateOrder = false;    
    @track OrderDateIsThere = false;
    @track OrderStatusIsThere = false;
    @track OrderIsThere = false;
    @track caseRec;
    @track dataIsAvailable = false;
    ProductsName;
    OrderQuantity;
    Re_Order_Quantity;
    OrderNo;
    OrderStat;
    NewQuantity;

    

    @track CaseRec = {
        Id: '', 
        RTO_Reso__c: '', 
        Reason_for_RTO__c: '',
        Reason_For_Duplicate_Order__c: ''
   }

    @wire(getObjectInfo, { objectApiName: Case })
    objectInfoCase;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoCase.data.defaultRecordTypeId', fieldApiName: RelationShipField })
    wiredIndustryDataRelationShip({ error, data }) {
        if (data) {
            this.optionsCategory = data.values;
        } else if (error) {
            console.error('Error in Industry picklist field', JSON.stringify(error));
        }
    }

    @wire(getObjectInfo, { objectApiName: Case })
    objectInfoCaseReason;

    @wire(getPicklistValues, { recordTypeId: '$objectInfoCaseReason.data.defaultRecordTypeId', fieldApiName: CaseReason })
    wiredIndustryDataCaseReason({ error, data }) {
        if (data) {
            this.lstRecordTypes = data.values;
        } else if (error) {
            console.error('Error in Industry picklist field', JSON.stringify(error));
        }

        
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfoCaseReason.data.defaultRecordTypeId', fieldApiName: CaseOrderId })
    wiredCaseOrderId({ error, data }) {
        if (data) {
            this.IdOfOrder = data.OrderId__c;
            if(this.IdOfOrder == null){
                if (this.IdOfOrder == undefined || this.IdOfOrder == null || this.IdOfOrder == '') {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Select SubType',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            }
        } else if (error) {
            console.error('Error in Industry picklist field', JSON.stringify(error));
        }
    }

    handleClick() {
        debugger;
        returnToOrigin({
            recId: this.recordId,
            reasonForRto: this.ReasonPickList,
            //rtoResolution: this.ResolutionPickList
        })
        .then(result => {
            if (result) {
                this.allResult = result;
                this.showToast();
                this.dispatchEvent(new CloseActionScreenEvent());
                getRecordNotifyChange([{ recordId: this.recordId }]);

            }
        })
        .catch(error => {
            this.error = error;
            this.showErrorToast();
        })
    }

    handleInputChange(event) {
        debugger;
        this.inpName = event.target.name;
        if (this.inpName == 'Reason_for_RTO__c') {
            this.ReasonPickList = event.detail.value;
        }
        if (this.inpName == 'RTO_Reso__c') {
            this.ResolutionPickList = event.target.value;
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Toast message',
            message: 'Toast Message',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Some unexpected error',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}