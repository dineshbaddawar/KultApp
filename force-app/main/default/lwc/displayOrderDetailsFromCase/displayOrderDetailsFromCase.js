import { LightningElement, api, track } from 'lwc';
import getOrderDetailsFromCaseRecord from '@salesforce/apex/CaseHelperController.getOrderDetailsFromCaseRecord';
import getOrders from '@salesforce/apex/CaseHelperController.getOrder';
//import getCase from '@salesforce/apex/CaseHelperController.getCase';
//import updateCase from '@salesforce/apex/CaseHelperController.updateCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DisplayOrderDetailsFromCase extends LightningElement {
    @api recordId;
    @track caseOrderDetails;
    @track OrderDetail;
    @track showOrderSelectionModal = false;
    @track selectedOrderId;

    @track AllOrders;
    @track orderIdValue;
    @track caseRec;
    OrderNo;
    error;
    @track TotalOrders = [];

  

  connectedCallback() {
        debugger;
        this.callApexMethod();
        this.callApexMethod2();
       // this.callApexMethod3();
    }

    callApexMethod() {
        debugger;
        getOrderDetailsFromCaseRecord({ recId: this.recordId })
            .then(result => {
                this.caseOrderDetails = result;
               if(this.caseOrderDetails == null || this.caseOrderDetails == undefined || this.caseOrderDetails == ''){
                    this.OrderNo = '-';
                    this.OrderDetail = true;
                }else{
                    this.OrderNo = this.caseOrderDetails ;
                    this.OrderDetail = true;
                    this.orderIdValue = this.caseOrderDetails;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    callApexMethod2() {
        debugger;
        getOrders({ recId: this.recordId })
            .then(result => {
                this.TotalOrders = result;
                if (this.TotalOrders && this.TotalOrders.OrderNumber !== null) {
                    this.selectedOrderId = this.TotalOrders;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    
    //  callApexMethod3(){
    //       debugger;
    //       getCase({recId: this.recordId})
    //                     .then(result => {
    //                 if (result) {
    //                      this.caseRec = result;    
    //            }
    //            })
    //            .catch(error => {
    //                 this.error1 = error;
    //       })  
    //  }

    openOrderSelectionModal() {
        this.showOrderSelectionModal = true;
    }

    closeOrderSelectionModal() {
        this.showOrderSelectionModal = false;
    }
    // handleModalSave() {
    //     updateCase({ caseRec: this.caseRec })
    //         .then(result => {
    //             var retVal = result;
    //            if(retVal == 'Success'){
    //              this.closeOrderSelectionModal();
    //      const toastEvent = new ShowToastEvent({
    //           title: 'SUCCESS',
    //           message: 'Order Added Successfully !',
    //           variant: 'success',
    //           mode: 'dismissable'
    //       });
    //       this.dispatchEvent(toastEvent);   
    //            }else{
    //              this.closeOrderSelectionModal();
    //      const toastEvent = new ShowToastEvent({
    //           title: 'Fail',
    //           message: 'Failed To Add Order !',
    //           variant: 'error',
    //           mode: 'dismissable'
    //       });
    //       this.dispatchEvent(toastEvent);   
    //            }
    //         })
    //         .catch(error => {
    //             this.error = error;
    //         });
            
    //       }
        
        handleChange( event ) {
                debugger;
        console.log(event.detail.recordId);
        this.caseRec.OrderId__c = event.detail.recordId;
    } 
}