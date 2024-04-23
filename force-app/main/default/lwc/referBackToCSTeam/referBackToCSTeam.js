import { LightningElement, api, track, wire } from 'lwc';
import getCaseById from '@salesforce/apex/referBackToCsTeamController.getCaseById';
import getCaseAndOrderDetails from '@salesforce/apex/referBackToCsTeamController.getCaseAndOrderDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getPicklistValues} from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import REFERBACKREASON_FIELD from '@salesforce/schema/Case.Refer_Back_Reason__c'
export default class ReferBackToCSTeam extends LightningElement {



    @track ListOfCaseRecords = [];
    @track error;
    @track result;
    @track referBack;
    @track RequestApprove = false;
    @track RequestReject = false;
    @track NeedMoreInfo = false;
    @track referBackReason;
    @track refundAmount;
    @track approvalRemarks;
    @track rejectionRemarks;
    @track rejectionReason;
    @track describeInformationNeeded;
    @track orderId;
    @track orderRefundAmount;
    RefrebackOption=[];


    @api recordId;

    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: REFERBACKREASON_FIELD})
    referbackField({data,error}){
        if(data){
            console.log(data);
            this.RefrebackOption = this.getPicklist(data);
        }else{
            console.log(error);
        }
    }

    getPicklist(data){
        return data.values.map(item=>({label:item.label, value: item.value}));
    }


    handelreferbackChange(event) {
        debugger;
        this.referBack = event.target.value;
        this.referBackReason = this.referBack;

        if (this.referBack === 'Refund Processed' || this.referBack === 'Cancellation Processed') {
            this.RequestApprove = true;
            this.RequestReject = false;
            this.NeedMoreInfo = false;
        }
        else if (this.referBack === 'Refund Rejected' || this.referBack === 'Cancellation Rejected') {
            this.RequestApprove = false;
            this.RequestReject = true;
            this.NeedMoreInfo = false;
        }
        else if (this.referBack === 'Need More Info') {
            this.RequestApprove = false;
            this.RequestReject = false;
            this.NeedMoreInfo = true;
        }

    }

    handelApprovalremark(event) {
        debugger;
        this.approvalRemarks = event.target.value;
    }

    // handelRefundAmount(event) {
    //     debugger;
    //     this.refundAmount = event.target.value;
    // }

    // handelRejectionmark(event) {
    //     debugger;
    //     this.rejectionRemarks = event.target.value;
    // }

    handelRejectionreason(event) {
        debugger;
        this.rejectionReason = event.target.value;
    }

    handeldescribeInformation(event) {
        debugger;
        this.describeInformationNeeded = event.target.value;
    }

    // @wire(getCaseById, { caseId: '$recordId' })
    // wiredGetCase({ error, data }) {
    //     if (data) {
    //         this.ListOfCaseRecords = data;
    //         console.log('Cases retrieved successfully');
    //     } else if (error) {
    //         console.error('Error retrieving cases:', error);
    //     }
    // }


    connectedCallback() {
        debugger;
        console.log('recordId====>' + this.recordId);
        setTimeout(() => {
            this.getCaseDetails();
        }, 300);
    }

    getCaseDetails() {
        debugger;
        getCaseById({ caseId: this.recordId })
            .then((result) => {
                if (result) {
                    this.ListOfCaseRecords.push(result);
                    this.approvalRemarks = result.Approval_Remarks__c;
                    this.refundAmount = result.OrderId__r.Refund_Amount__c;

                    // this.rejectionRemarks = result.Rejection_Remarks__c;
                    this.rejectionReason = result.Rejection_Reason__c;

                    this.describeInformationNeeded = result.Describe_Information_Needed__c;


                    console.log('Cases retrieved successfully');
                } else {
                    console.log('No cases found for the provided ID');
                }
            }).catch((err) => {
                console.error('Error retrieving contacts:', err);
            });
    }


    handleSave() {
        debugger;

        if (this.referBack == undefined || this.referBack == null || this.referBack == '') {
            alert("Enter Refer Back Reason");
            return null;
        }

        if (this.referBack == 'Refund Processed' || this.referBack === 'Cancellation Processed') {
            if (this.approvalRemarks == undefined || this.approvalRemarks == null || this.approvalRemarks == '') {
                alert("Enter Approval Remarks");
                return null;
            }

            // if (this.refundAmount == undefined || this.refundAmount == null || this.refundAmount == '') {
            //     alert("Enter Refund Amount");
            //     return null;
            // }
        }

        if (this.referBack == 'Refund Rejected' || this.referBack === 'Cancellation Rejected') {
            // if (this.rejectionRemarks == undefined || this.rejectionRemarks == null || this.rejectionRemarks == '') {
            //     alert("Enter Rejection Remarks");
            //     return null;
            // }

            if (this.rejectionReason == undefined || this.rejectionReason == null || this.rejectionReason == '') {
                alert("Enter Rejection Reason");
                return null;
            }
        }


        if (this.referBack == 'Need More Info') {
            if (this.describeInformationNeeded == undefined || this.describeInformationNeeded == null || this.describeInformationNeeded == '') {
                alert("Enter Describe Info Needed");
                return null;
            }
        }




        getCaseAndOrderDetails({
            caseId: this.recordId,
            referBackReason: this.referBackReason,
            //refundAmount: this.refundAmount,
            approvalRemarks: this.approvalRemarks,
            //rejectionRemarks: this.rejectionRemarks,
            rejectionReason: this.rejectionReason,
            describeInformationNeeded: this.describeInformationNeeded,
            //orderId:this.orderId,
            orderRefundAmount: this.orderRefundAmount
        })
            .then((result) => {
                console.log("result===>" + JSON.stringify(result));
                this.ListOfCaseRecords = result;
                this.showToast('Success', 'Records saved successfully', 'success');
                this.handleClose();
            }).catch((err) => {
                console.log("err===>" + JSON.stringify(err));
                this.error = err;
                this.showToast('Error', 'Error occurred while saving records', 'error');
            });

    }

    handleCancel() {
        this.handleClose();
    }

    handleClose() {
        const closeActionEvent = new CloseActionScreenEvent();
        this.dispatchEvent(closeActionEvent);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}