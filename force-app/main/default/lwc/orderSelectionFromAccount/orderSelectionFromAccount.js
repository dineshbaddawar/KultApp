import { LightningElement,api} from 'lwc';


export default class OrderSelectionFromAccount extends LightningElement {

    @api recordaccountid;
    filter = {};
    matchingInfo = {
        primaryField: { fieldPath: "OrderNumber" },
       
    };

    connectedCallback() {
        debugger;
        if (this.recordaccountid != null) {
            this.filter = {
                criteria: [{
                    fieldPath: 'AccountId',
                    operator: 'eq',
                    value: this.recordaccountid,
                }],
            };
        }
    }

    handleChange(event) {
        debugger;
        const value = event.detail.recordId;
        const auraEvent = new CustomEvent('sendidtoaura', {
            detail: { value }
        });
        this.dispatchEvent(auraEvent);
    }

}