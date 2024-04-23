import { LightningElement, api, track } from 'lwc';
import getRelatedCases from '@salesforce/apex/CaseHelperControllers.getRelatedCases';
import { CloseActionScreenEvent } from 'lightning/actions';
import mergeSelectedCasesOfOneOrder from '@salesforce/apex/CaseHelperControllers.mergeSelectedCases';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from "lightning/uiRecordApi";

const Casecolumns = [
    { label: 'Case Number', fieldName: 'CaseNumber', type: 'AuotNumber' },
    { label: 'Subject', fieldName: 'Subject', type: 'text' },
    { label: 'Order No', fieldName: 'orderNumber', type: 'text' },
    { label: 'Case Origin', fieldName: 'Origin', type: 'PickList' },
    { label: 'Case Status', fieldName: 'Status', type: 'PickList' },
    { label: 'Type', fieldName: 'Sub_Type__c', type: 'PickList' },
    { label: 'Sub Type', fieldName: 'Sub_Sub_Type__c', type: 'PickList' },
];

export default class MergeCasesComponent extends LightningElement {
    @api recordId;
    casesData;
    error;
    errors
    @track selectedCase;
    @track recordIds;
    columns = Casecolumns;
    CaseList = [];
    selectedCaseId = [];
    @track preSelectedRows;
    show1stPage = false;
    show2ndPage = false;
    @track selectedRowsFromPage1 = [];
    @track selectedRowsObjects = [];
    onlyOneRowWhichIsSelectedId;
    connectedCallback() {
        debugger;
        setTimeout(() => {
            this.callApexMethod();
            this.callApexMethod2();
        }, 300);
    }

    callApexMethod() {
        debugger;
        getRelatedCases({ recId: this.recordId, types: this.types, subTypes: this.SubTypes })
            .then(result => {
                if (result) {
                    result.forEach(element => {
                        if (element.OrderId__c) {
                            element.orderNumber = element.OrderId__r.OrderNumber;
                        }
                    });
                }
                this.casesData = result;
                console.log('casesData', this.casesData);
                this.error = undefined;
                this.show1stPage = true;
            })
            .catch(error => {
                this.error = error;
                this.casesData = undefined;
            });
    }

    handleBack() {
        debugger;
        this.show1stPage = true;
        this.show2ndPage = false;
    }
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleRowSelection(event) {
        debugger;
        var selectedRows = event.detail.selectedRows;
        this.CaseList = selectedRows;
        var CaseListToIterate = this.CaseList;
        var CaseIdList = [];
        for (var i in CaseListToIterate) {
            CaseIdList.push(CaseListToIterate[i].Id);
        }
        this.selectedCaseId = CaseIdList;
        this.selectedRowsFromPage1 = event.detail.selectedRows;

    }
    handleNext() {
        debugger;
        this.show2ndPage = true;
        this.show1stPage = false;
        //this.preSelectedRows = this.selectedRows;
        var selectdRowsIds = this.selectedCaseId;
        var allCases = this.casesData;
        var selectdCases = [];
        for (var i = 0; i < allCases.length; i++) {
            if (selectdRowsIds.includes(allCases[i].Id)) {
                selectdCases.push(allCases[i]);
            }
        }

        this.selectedRowsObjects = selectdCases;

    }
    OnlyOneSelection = event => {
        debugger;
        var selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 1) {
            var el = this.template.querySelector('lightning-datatable');
            selectedRows = el.selectedRows = el.selectedRows.slice(1);
            event.preventDefault();
            return;
        }
        if(selectedRows.length > 0){
            this.onlyOneRowWhichIsSelectedId = selectedRows[0].Id;
        }
    }
    mergeRelatedCases() {
        debugger; 
        mergeSelectedCasesOfOneOrder({ caseId: this.onlyOneRowWhichIsSelectedId, cases: this.selectedRowsObjects })
            .then(result => {
                this.selectedCase = result;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Record updated!",
                        variant: "success",
                    })
                );
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch(error => {
                this.errors = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "This case cannot be both a parent and a child of another case!!",
                        variant: "Error",
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
                getRecordNotifyChange([{ recordId: this.recordId }]);
            });
    }

}