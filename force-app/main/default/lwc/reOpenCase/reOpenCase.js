import { LightningElement, api, track } from 'lwc';
import reOpenCase from '@salesforce/apex/CaseHelperControllers.reOpenCase';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from "lightning/uiRecordApi";

export default class ReOpenCase extends LightningElement {
    @api recordId;
    @track reOpen;
    reasonForReOpen;
    error;

    handleChange(event) {
        this.reOpen = event.detail.value;
    }
    handleClick() {
        debugger;
        if(this.reOpen != null && this.reOpen!= 'Undefined' && this.reOpen != ' '){
            reOpenCase({ RecId: this.recordId, Reason: this.reOpen })
            .then((result) => {
                this.reasonForReOpen = result;
                 const event = new ShowToastEvent({
            title: 'Case Re-Open',
            variant: 'Success',
            message:'Status Of The Case is Re-Opened',
        });
        this.dispatchEvent(event);
        this.closeQuickAction();
        getRecordNotifyChange([{ recordId: this.recordId }]);
            }).catch((err) => {
                this.error = err;
            });
        }else{
            const event = new ShowToastEvent({
                title: 'Case Re-Open',
                variant: 'error',
                message:'Please enter the reason to Re-Open the Case',
            });
            this.dispatchEvent(event);
        }
        
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}