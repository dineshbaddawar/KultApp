import { LightningElement, api, track,wire } from 'lwc';
import getCaseById from '@salesforce/apex/RefundController.getCaseById';
import getUsersByProfileName from '@salesforce/apex/RefundController.getUsersByProfileName';
//import sendEmailAlertToRecordOwner from '@salesforce/apex/RefundController.sendEmailAlertToRecordOwner';
//import getProfileName from '@salesforce/apex/RefundController.getProfileName';
import userUpdate from '@salesforce/apex/RefundController.userUpdate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import USER_ID from '@salesforce/user/Id';

export default class NewRefund extends LightningElement {
    @api recordId; 
    @track caseRecord;
    @track error;
    @track ListOfCaseRecords;
    @track allUsers=[];
    @track userdata;
    @track UserName;
    userId = USER_ID;
    @track profileName;
    filter = {};
    @track  showAccountNumber = false;
    @track showOrderNumber = false;

    //@api AccountIdForLWC = '00eF3000000LBmYIAW';
   // @api AccountIdForLWC = '00eF3000000LBmYIAW';

    caseData;
    error;
    caseNumber;
    AccountName;
    Ordernumber;
    Recordtype;
    subject;

    @track userId;
    @track listofEmail=[];

    connectedCallback(){
        debugger;
        var url = window.location.href.toString();
        const queryParams = url.split("&");
        const recordIdParam = queryParams.find(param => param.includes("recordId"));
        const recordIdKeyValue = recordIdParam.split("=");
        const recordId = recordIdKeyValue.pop();
        this.recordId = recordId;
      //  this.recordaccountid = this.recordId;

        console.log('recordId====>'+this.recordId);
        setTimeout(() =>{
            this.callApexMethod();

        },500);
    }

    callApexMethod() {
        debugger;
        getCaseById({ caseId: this.recordId })
            .then(result => {
                this.getUsersByProfileName();
                this.caseData = result;
                if (result.CaseNumber != undefined) {
                    this.caseNumber = result.CaseNumber;
                }
                if (result.Account.Name != undefined) {
                    this.AccountName = result.Account.Name;
                    this.showAccountNumber = true;
                }
                if(result.OrderId__r.OrderNumber != undefined){
                    this.Ordernumber = result.OrderId__r.OrderNumber;
                    this.showOrderNumber = true;
                }
                if(result.RecordType.Name != undefined){
                    this.Recordtype = result.RecordType.Name;
                }
                if(result.Subject != undefined){
                    this.subject = result.Subject;
                }
            })
            .catch(error => {
                console.error('Error retrieving contacts:', error);
        })
        
    }

    // connectedCallback() {
    //     debugger;
    //     if (this.AccountIdForLWC) {
    //         this.filter = {
    //             criteria: [{
    //                 fieldPath: 'ProfileId',
    //                 operator: 'eq',
    //                 value: this.AccountIdForLWC,
    //             }],
    //         };
    //     }
    // }


    getUsersByProfileName() {
        getUsersByProfileName()
            .then((result) => {
                if (result) {
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



    handleChange(event){
        debugger;
        this.userdata = event.detail.recordId;
        console.log('userdata====>',this.userdata);
        
    }
    

        filter = {
            criteria: [{
                fieldPath: 'Id',
                operator: 'eq',
                value: 'this.userId',
             },
        ],
};


    

     handleSave() {
         debugger;
        userUpdate({
            recordId: this.recordId,
            UserName: this.userdata,
        })
        .then((result) => {
            if (result != null) {
                this.showToast('SUCCESS', '', 'success');
            } else {
                this.showToast('ERROR', 'Some unexpected error', 'error');
            }
        })
        .catch((error) => {
            this.error = error;
            this.showToast('ERROR', error.body.message, 'error');
        });
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