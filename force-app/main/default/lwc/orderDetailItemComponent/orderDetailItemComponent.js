import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getOrderLineItems from '@salesforce/apex/CaseHelperController.getOrderLineItems';

const FIELDS = ['Case.OrderId__c'];

export default class OrderDetailItems extends LightningElement {
    @api recordId;

    caseRecord;
    orderLineItems;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            this.caseRecord = data;
            this.loadOrderLineItems(data.fields.OrderId__c.value);
        } else if (error) {
            console.error('Error loading case record', error);
        }
    }

    loadOrderLineItems(orderId) {
        getOrderLineItems({ orderId: orderId })
            .then(result => {
                this.orderLineItems = result;
            })
            .catch(error => {
                console.error('Error loading order line items', error);
            });
    }
}