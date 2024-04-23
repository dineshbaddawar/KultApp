import { LightningElement, api, track } from 'lwc';
import courierRelatedCase from '@salesforce/apex/CaseHelperControllers.courierRelatedCase';
import updateCaseAndOrder from '@salesforce/apex/CaseHelperControllers.updateCaseAndOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CourierIssue extends LightningElement {

    @api recordId;
    AllCaseResult;
    error;
    err;
    inpName;

    connectedCallback() {
        setTimeout(() => {
            this.callApexMethod();
        }, 700);
    }

    callApexMethod() {
        debugger;
        courierRelatedCase({ recId: this.recordId })
            .then(result => {

                this.AllCaseResult = result;

                this.error = undefined;

            })
            .catch(error => {
                this.error = error;
                this.AllCaseResult = undefined;
            });
    }
    handleClick() {
        debugger;
        if (this.reOpen != null && this.reOpen != 'Undefined' && this.reOpen != ' ') {
            reOpenCase({ RecId: this.recordId, Reason: this.reOpen })
                .then((result) => {
                    this.reasonForReOpen = result;
                    const event = new ShowToastEvent({
                        title: 'Case Re-Open',
                        variant: 'Success',
                        message: 'Status Of The Case is Re-Opened',
                    });
                    this.dispatchEvent(event);
                    this.closeQuickAction();
                }).catch((err) => {
                    this.error = err;
                });
        } else {
            const event = new ShowToastEvent({
                title: 'Case Re-Open',
                variant: 'error',
                message: 'Please Fill the reason to re-Open the Case',
            });
            this.dispatchEvent(event);
        }

    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleChange(event) {
        this.inpName = event.target.name;
        console.log('inpName---->', this.inpName);

        if (this.inpName == 'contactNumber') {
            this.AllCaseResult.contact.phone = event.detail.value;

        }
        if (this.inpName == 'addStreet') {
            this.AllCaseResult.Address_With_Pin_Code__Street__c = event.target.value;
        }
        if (this.inpName == 'addPostal') {
            this.AllCaseResult.Address_With_Pin_Code__PostalCode__c = event.detail.value;

        }
        if (this.inpName == 'addCity') {
            this.AllCaseResult.Address_With_Pin_Code__City__c = event.target.value;
        }
        if (this.inpName == 'addState') {
            this.AllCaseResult.Address_With_Pin_Code__StateCode__c = event.detail.value;

        }
    }
     handleClick() {
         debugger;
        updateCaseAndOrder({
            recId: this.recordId,
            addStreet: this.AllCaseResult.Address_With_Pin_Code__Street__c,
            addPincodeNum: this.AllCaseResult.Address_With_Pin_Code__PostalCode__c,
            addCity:this.AllCaseResult.Address_With_Pin_Code__City__c,
            phoneNumer : this.AllCaseResult.contact.phone,
            addState:this.AllCaseResult.Address_With_Pin_Code__StateCode__c
        })
        .then((result) => {
            if (result != null) {
                this.showToast('SUCCESS', '', 'success');
            }
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch((error) => {
            this.error = error;
            this.showToast('ERROR', error.body.message, 'error');
        });
    }

}