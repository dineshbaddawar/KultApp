import { LightningElement,api,track } from 'lwc';
import courierRelatedCase from '@salesforce/apex/CaseHelperControllers.courierRelatedCase';

export default class CouriersIssue extends LightningElement {

@api recordId;
@track casesResult;
error;

    connectedCallback(){
        debugger;
        setTimeout(() => {
            this.callApexMethod();
        },300);
    }

    callApexMethod(){
        debugger;
        courierRelatedCase({ recId: this.recordId })
            .then(result => {
                this.casesResult = result;
                console.log('outside this.recordId : ' + this.cases);
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.casesResult = undefined;
            });
    }
}