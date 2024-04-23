import { LightningElement,track } from 'lwc';
export default class LostInTransit extends LightningElement {

    @track LostIntranscit;




     @track LostInOption = [
        { label: 'Lost in Transit', value: 'Lost in Transit' },
        { label: 'Incorrect Addresses', value: 'Incorrect Addresses' },
        { label: 'Customer Unreachable', value: 'Customer Unreachable' }];


    handelreLostInChange(event){
        debugger;
        this.LostIntranscit = event.target.value;
    }

}