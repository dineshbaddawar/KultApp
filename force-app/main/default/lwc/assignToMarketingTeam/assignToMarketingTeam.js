import { LightningElement, api, track, wire } from 'lwc';
import marketingTeamCaseController from '@salesforce/apex/marketingTeamCaseController.marketingTeamCase';
import getUsersByProfileName from '@salesforce/apex/marketingTeamCaseController.getUsersByProfileName';
import userUpdate from '@salesforce/apex/marketingTeamCaseController.userUpdate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import USER_ID from '@salesforce/user/Id';

export default class AssignToMarketingTeam extends LightningElement {
    @api recordId;
    @track caseRecord;
    @track error;
    @track CaseRecords;
    @track allUsers = {};
    @track userdata;
    @api profileId = '00eF3000000LCOc';
    errors;
    userId = USER_ID;
    @track profileName;
    marketingReason;
    filter = {};
    allUsersSet;
    name;

    inpName;

    @track userId;
    @track listofEmail = [];

    connectedCallback() {
        debugger;
        if (this.profileId) {
            this.filter = {
                criteria: [{
                    fieldPath: 'ProfileId',
                    operator: 'eq',
                    value: this.profileId,
                }],
            };
        }
        setTimeout(() => {
            marketingTeamCaseController({ recId: this.recordId })
                .then((result) => {
                    this.CaseRecords = result;
                    if(this.caseRecords.Sub_Type__c == null || this.caseRecords.Sub_Sub_Type__c == null){
                        const event = new ShowToastEvent({
                            title: 'Alert',
                            message: 'Please Enter Case Details before Assigning to Marketing Team',
                            variant: 'alert',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }
                })
                .catch((err) => {
                    this.errors = err;
                    console.error('Error retrieving contacts:', err);
                });
            this.getUsersByProfileName();
        }, 1700);
    }


    getUsersByProfileName() {
        debugger;
        getUsersByProfileName()
            .then((result) => {
                if (result) {
                    this.allUsers = result;
                    console.log('Users retrieved successfully:', result);
                    this.allUsers = result.map(user => ({
                        label: user.Name,
                        value: user.Id
                    }));
                    console.log('Users for profile:', this.allUsers);
                } else {
                    console.log('No users found for the profile');
                }


            }).catch((error) => {
                console.error('Error fetching users:', error);
            });
    }


    // getUsersByProfileName() {
    //     debugger;
    //     getUsersByProfileName()
    //         .then((result) => {
    //             if (result) {
    //                 this.allUsers = result;
    //                 console.log('Users retrieved successfully:', result);
    //                 this.allUsersSet = new Set();
    //                 result.forEach(user => {
    //                     this.allUsersSet.add({
    //                         name: user.name
    //                     });
    //                 });
    //                 this.allMarketingUsers = Array.from(this.allUsersSet).map(user => user.name);
    //                 console.log('Users for profile:', this.allUsersSet);
    //                 console.log('All marketing users:', this.allMarketingUsers);
    //             } else {
    //                 console.log('No users found for the profile');
    //             }
    //         }).catch((error) => {
    //             console.error('Error fetching users:', error);
    //         });
    // }


    handleChange(event) {
        debugger;
        this.inpName = event.target.name;

        if (this.inpName == 'Users') {
            this.userdata = event.detail.recordId;
        }
        if (this.inpName == 'ReasonName') {
            this.marketingReason = event.target.value;
        }
    }


    handleSave() {
        debugger;
        if ((this.userdata != null && this.userdata != ' ' && this.userdata != undefined)
            && (this.marketingReason  != null && this.marketingReason  != ' ' && this.marketingReason != undefined)) {
            userUpdate({
                recId: this.recordId,
                UserName: this.userdata,
                MarketingReason: this.marketingReason 
            })
                .then((result) => {
                    if (result != null) {
                        const event = new ShowToastEvent({
                            title: 'Toast message',
                            message: 'Case has Been Assigned to Marketing Team',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                    }
                    this.dispatchEvent(new CloseActionScreenEvent());
                    getRecordNotifyChange([{ recordId: this.recordId }]);
                })
                .catch((error) => {
                    this.error = error;
                    this.showToast('ERROR', error.body.message, 'error');
                });
        }else{
            alert('Please Fill All the Required Fields');
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        if (title === 'SUCCESS') {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
}