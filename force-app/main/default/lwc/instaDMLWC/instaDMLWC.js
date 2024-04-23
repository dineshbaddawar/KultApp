import getInstaDmDetails from '@salesforce/apex/instaDmLWCCompController.getInstaDmDetails';
import refreshChat from '@salesforce/apex/instaDmLWCCompController.refreshChat';
import sendMessage from '@salesforce/apex/instaDmLWCCompController.sendMessage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track } from 'lwc';

export default class InstaDmLWC extends LightningElement {
    @api recordId;
    @api chatMessages = [];
    @api senderName;
    @api chatInitiatedTime;
    @api recipientId;
    
    @track showSpinner = false;
    @track messageContext;

    
    doInit() {
        debugger;
        this.showSpinner = true;
        getInstaDmDetails({ recordId: this.recordId })
            .then(result => {
                debugger;
                this.chatMessages = result;
                this.senderName = result[0].sender;
                this.chatInitiatedTime = result[0].timestamp;
                this.totalMessages = result.length;
                for (let i = 0; i < result.length; i++) {
                    if (result[i].sender !== 'Kult App') {
                        this.recipientId = result[i].senderId;
                    }
                }
                this.showSpinner = false;
                this.messageContext = '';
            })
            .catch(error => {
                this.showSpinner = false;
                console.error('Error fetching chat messages:', error);
            });
    }

    handleSendReply() {
        this.showSpinner = true;
        sendMessage({
            recipientId: this.recipientId,
            messageText: this.messageContext,
            caseId: this.recordId
        })
        .then(result => {
            const event = new ShowToastEvent({
                title: 'Success!',
                message: 'Message sent successfully!!',
                variant: 'success'
            });
            this.dispatchEvent(event);
            this.doInit();
        })
        .catch(error => {
            console.error('Error sending message:', error);
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Something went wrong!',
                variant: 'error'
            });
            this.dispatchEvent(event);
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }

    refreshChat() {
        this.showSpinner = true;
        refreshChat({
            recipientId: this.recipientId,
            caseId: this.recordId
        })
        .then(result => {
            this.doInit();
        })
        .catch(error => {
            console.error('Error sending message:', error);
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Something went wrong!',
                variant: 'error'
            });
            this.dispatchEvent(event);
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }

    handleMessageChange(event) {
        this.messageContext = event.target.value;
    }
}