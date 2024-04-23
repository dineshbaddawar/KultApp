import { LightningElement, track, wire, api } from 'lwc';
import getCaseList from '@salesforce/apex/showAllRelatedCasesController.getCaseList';
import { NavigationMixin } from 'lightning/navigation';

export default class showAllRelatedCases extends NavigationMixin(LightningElement){
@api recordId;
@track areCasesAvailable = false;
@track caseList = [];
@track relCaseAvail = false;
// @wire(getCaseList, {caseId: '$recordId'})
// wiredContacts({data, error}){
//     debugger;
//     if(data){
//         this.caseList = data;
//         areCasesAvailable = true;
//         this.error = undefined;
//     }
//     else if (error) {
//         this.error = error;
//         this.areCasesAvailable = false;
//         this.caseList = undefined;
//     }
// }

connectedCallback() {
    debugger;
    getCaseList({chatTranscripId: this.recordId})
    .then((result) => {
        if(result){
            if(result.length >0){
                this.relCaseAvail = true;
                this.caseList = result;
            }
        }
    })
    .catch((error) => {
        console.log('In connected call back error....');
this.error = error;
console.log('Error is', this.error);
    })
}

caseClicked(event){
    debugger;
    const recordId = event.currentTarget.dataset.id;
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            objectApiName: 'Case',
            actionName: 'view'
        }
    });
}
}