import { LightningElement,api,track, wire } from 'lwc';
import getCaseFieldSetList from '@salesforce/apex/CaseHelperControllers.getCaseFieldSetListss';
import getAllCaseFields from '@salesforce/apex/CaseHelperControllers.getAllCaseFields';
import getRecrdTypeId from '@salesforce/apex/CaseHelperControllers.getRecrdTypeId';
import getCaseRecord from '@salesforce/apex/CaseHelperControllers.getCaseRec';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from "lightning/uiRecordApi";


export default class DynamicPageGenerator extends LightningElement {
 
    caseFieldSet = [];
    caseField = [];
    sendCaseField = [];
    data;
    data1;
    error1;
    error;
    selectedSubType;
    selectedSubSubType;
    showSubFields = false;
    @track showCaseRecordPage = true
    @api objectName;
    @api recordId;
    @api fieldSet;
    @track fields;
    @track contactId;
    @track accountid;
    @track recodTypeName;
    @track CaseDataAvail = false;
    @track caseType;
    @track caseSubType;

    connectedCallback() {
          setTimeout(() => {
               this.callApexMethod();
               this.callApexMethod2();
               this.callApexMethod3();
          }, 300);
          setTimeout(() => {
            this.callApexMethod4();
       }, 600);
     }
     callApexMethod() {
          debugger;
          getCaseFieldSetList()
               .then(result => {
                    if (result) {
                         this.data = result;
                         var TempArray = [];
                         for (var key in this.data) {    
                            if((this.data)[key] == 'Subject'){
                                TempArray.push({ key: key, value:(this.data)[key],  disabled:true});  
                            }else{
                                TempArray.push({ key: key, value:(this.data)[key],  disabled:false});
                            }       
                                         
                         }  
                         this.caseFieldSet = TempArray;
                         console.log('key', this.caseFieldSet); 
                         this.CaseDataAvail = true;
                         
               }
               })
               .catch(error => {
                    this.error = error;
          })
     }
     callApexMethod2(){
       debugger;
          getAllCaseFields()
               .then(result => {
                    if (result) {
                         this.data1 = result;
                         var TempArray = [];
                         for (var key in this.data1) {           
                              TempArray.push({ key: key, value:(this.data1)[key] });
                         }  
                         this.caseField = TempArray;
                         console.log('key', this.caseField); 
                         
               }
               })
               .catch(error => {
                    this.error1 = error;
          })
     }
     callApexMethod3(){
          debugger;
          getRecrdTypeId({recordId: this.recordId})
                        .then(result => {
                    if (result) {
                         this.recodTypeName = result;    
               }
               })
               .catch(error => {
                    this.error1 = error;
          })
          

     }

     callApexMethod4(){
        debugger;
        getCaseRecord({caseId: this.recordId})
                      .then(result => {
                  if (result) {
                    this.selectedSubType = result.Sub_Type__c;
                    this.selectedSubSubType = result.Sub_Sub_Type__c;
                    this.handleShowSubFields();  
             }
             })
             .catch(error => {
                  this.error1 = error;
        })
        

   }
     
    onchageInputOpp(event) {
        debugger;
    if (event.target.fieldName == 'Sub_Type__c') {
        this.selectedSubType = event.target.value;
    }
    if (event.target.fieldName == 'Sub_Sub_Type__c') {
        this.selectedSubSubType = event.target.value;
    }
    this.handleShowSubFields();
}

    handleShowSubFields(){
        debugger;
        if (this.selectedSubType === 'Order Related' && this.selectedSubSubType === 'Order Confirmation /Status Issues') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Amount_Paid__c" || this.caseField[i].value == "Payment_ID__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }
        else if (this.selectedSubType === 'App Related' && this.selectedSubSubType === 'Login issues/Login number error') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'App Related' && this.selectedSubSubType === 'Invalid Email/Phone Number') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Email_Id__c" || this.caseField[i].value == "Screen_Shot__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'App Related' && this.selectedSubSubType === 'Invalid Coupon Code') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Coupon_Code__c" || this.caseField[i].value == "Screen_Shot__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'App Related' && this.selectedSubSubType === 'App Stuck or Hanged') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Version__c" || this.caseField[i].value == "Handset_model__c" || this.caseField[i].value == "Screen_Shot__c" ) {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'App Related' && this.selectedSubSubType === 'Error while adding in cart') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Description" || this.caseField[i].value == "Screen_Shot__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'App Related' && this.selectedSubSubType === 'Product Description/Offer Issues') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "App_Version__c" || this.caseField[i].value == "Device_Handset__c" || this.caseField[i].value == "OS_Version__c" || this.caseField[i].value == "Logging_Mobile_number__c" || this.caseField[i].value == "Screen_Shot_Of_The_Issue__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'App Related' && this.selectedSubSubType === 'Addition of More Payment options or COD') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Required_payment_option__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Refund Issues' && this.selectedSubSubType === 'Refund Issues') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Payment_ID__c" || this.caseField[i].value == "Error_message__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Mobile number change' && this.selectedSubSubType === 'Change in profile number') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Contact_Number__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Update Email id' && this.selectedSubSubType === 'Updation of new email id') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Email_Id__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Update Email id' && this.selectedSubSubType === 'Change in mail id') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Email_Id__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Process to add or update more addresses' && this.selectedSubSubType === 'Process to add/update more addresses') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
         }
        //else if (this.selectedSubType === 'Product Price' && this.selectedSubSubType === 'Guided on App') {
        //     this.sendCaseField = [];
        //     for (var i = 0; i < this.caseField.length; i++) {
        //         if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
        //             this.sendCaseField.push(this.caseField[i]);
        //         }
        //     }Price_Shown__c
        //     this.showSubFields = true;
        //}
        else if (this.selectedSubType === 'Product Price' && this.selectedSubSubType === 'Price mismatch') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Brand__c" || this.caseField[i].value == "Product_Name__c" || this.caseField[i].value == "Price_Shown__c" || this.caseField[i].value == "Actual_Price__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Comparison with Competitor' && this.selectedSubSubType === 'Comparison with Competitor') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "App_Name__c" || this.caseField[i].value == "Brand_Name__c" || this.caseField[i].value == "Product_Name__c"  || this.caseField[i].value == "Price_Differnece__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'Ongoing Campaign/Sales updates') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'Upcoming Campaign /Sales updates') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'How to check  product review') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'Giveaway inquiry') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'Use of Coupon codes') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'Coupon/Freebie /Discount/Cashback Issuance') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Campaign_Name__c" || this.caseField[i].value == "Discount__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Gift /Pre book' && this.selectedSubSubType === 'Gift an Order') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Process to Purchase/Delivery Charges' && this.selectedSubSubType === 'Information Given') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Expected Delivery TAT /Preferred Delivery window ' && this.selectedSubSubType === 'Information Given') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Previous order OOS Req for benefit/code' && this.selectedSubSubType === 'Information Given') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Missed campaign Req. for Benefit/code' && this.selectedSubSubType === 'Information Given') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Previous_order_number__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Word of Mouth on Order Cancellation' && this.selectedSubSubType === 'Information Given') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Know more about products' && this.selectedSubSubType === 'Guided on App') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Product Suitability ' && this.selectedSubSubType === 'Guided to explore personalization on app') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Product Quantity or Ingredients or Description' && this.selectedSubSubType === 'Guided to explore personalization on app') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Stock / Restock ' && this.selectedSubSubType === 'Guided on App') {
            this.sendCaseField = [];
         //    for (var i = 0; i < this.caseField.length; i++) {
         //        if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
         //            this.sendCaseField.push(this.caseField[i]);
         //        }
         //    }
         //    this.showSubFields = true;
        }else if (this.selectedSubType === 'Product life /Expiry/Authencity /Others' && this.selectedSubSubType === 'Information Given') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Brand__c" || this.caseField[i].value == "Product_Name__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Collaboration Request/Influencer queries' && this.selectedSubSubType === 'Collabration Request/Influencer queries') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Instagram_ID__c" || this.caseField[i].value == "Contact_Number__c" || this.caseField[i].value == "Email_Id__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Collaboration service issues' && this.selectedSubSubType === 'Collabration service issues') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Instagram_ID__c" || this.caseField[i].value == "Contact_Number__c" || this.caseField[i].value == "Email_Id__c" || this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Collabration Request' && this.selectedSubSubType === 'Collabration Request') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Content Issues - Cx' && this.selectedSubSubType === 'Content Issues - Cx') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Content Issues - Partners' && this.selectedSubSubType === 'Content Issues - Partners') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Order number confirmation') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Tracking details') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Delivery Delayed') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Mismatch in address details') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Address_With_Pin_Code__Street__s" || this.caseField[i].value== "Address_With_Pin_Code__City__s" || this.caseField[i].value== "Address_With_Pin_Code__StateCode__s" || this.caseField[i].value== "Address_With_Pin_Code__PostalCode__s"
                || this.caseField[i].value== "Address_With_Pin_Code__CountryCode__s" || this.caseField[i].value == "Landmark__c" || this.caseField[i].value == "Receiver_contact_number__c" ) {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Wrong courier partner remarks') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Remarks_mentioned__c" || this.caseField[i].value == "Actual_Order_Status__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
    
        }else if (this.selectedSubType === 'Collaboration Request' && this.selectedSubSubType === 'Collabration Request') {
                this.sendCaseField = [];
                for (var i = 0; i < this.caseField.length; i++) {
                    if (this.caseField[i].value== "Brand_Details__c" || this.caseField[i].value == "Contact_Number__c" || this.caseField[i].value == "Email_Id__c") {
                        this.sendCaseField.push(this.caseField[i]);
                    }
                }
                this.showSubFields = true;
    
        }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Change in delivery schedule') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Expected_Date_Time__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Gift Before Shipping' && this.selectedSubSubType === 'Send order as a gift') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Receiver_Name__c" || this.caseField[i].value == "Address_With_Pin_Code__Street__s" || this.caseField[i].value == "Address_With_Pin_Code__City__s" || this.caseField[i].value == "Address_With_Pin_Code__StateCode__s" 
                || this.caseField[i].value == "Address_With_Pin_Code__PostalCode__s"  || this.caseField[i].value == "Address_With_Pin_Code__CountryCode__s" || this.caseField[i].value == "Landmark__c" || this.caseField[i].value == "Receiver_contact_number__c" || this.caseField[i].value == "Pincode") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Gift After Shipping' && this.selectedSubSubType === 'Send order as a gift') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value== "Contact_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'OOS') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "OOS_SKU_Code__c" || this.caseField[i].value == "Product_Name__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
    
        }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Other Internal Issues/Monitoring Reasons') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'CX out of town') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Availability_Window__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Not required any more/Wrongly Ordered') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Description" ) {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Price Issue') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value== "Description" ) {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Bad review of product') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_Source__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Expected shorter delivery TAT') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Expected_Delivery_By__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Offer / discount issues') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Others') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'OOS') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Product_Name__c" || this.caseField[i].value == "OOS_SKU_Code__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Other Internal Issues/Monitoring Reasons') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'CX out of town') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Availability_Window__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Not required any more/Wrongly Ordered') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Price Issue') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Bad review of product') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_Source__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Not required anymore/Wrongly Ordered') {
                this.sendCaseField = [];
                for (var i = 0; i < this.caseField.length; i++) {
                    if (this.caseField[i].value == "Description") {
                        this.sendCaseField.push(this.caseField[i]);
                    }
                }
                this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Expected shorter delivery TAT') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Expected_Delivery_By__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Offer / discount issues') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Others') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Ecom Reason - Order lost in transit') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
          }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Offer/discount issues') {
                this.sendCaseField = [];
                for (var i = 0; i < this.caseField.length; i++) {
                    if (this.caseField[i].value == "Description") {
                        this.sendCaseField.push(this.caseField[i]);
                    }
                }
                this.showSubFields = true;
    
            }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Offer/discount issues') {
                this.sendCaseField = [];
                for (var i = 0; i < this.caseField.length; i++) {
                    if (this.caseField[i].value == "Description") {
                        this.sendCaseField.push(this.caseField[i]);
                    }
                }
                this.showSubFields = true;  
    
            }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Not required anymore/Wrongly Ordered') {
                    this.sendCaseField = [];
                    for (var i = 0; i < this.caseField.length; i++) {
                        if (this.caseField[i].value == "Description") {
                            this.sendCaseField.push(this.caseField[i]);
                        }
                    }
                    this.showSubFields = true;               
    
        }else if (this.selectedSubType === 'Address Change Before Shipping' && this.selectedSubSubType === 'Address Change - Before Shipping') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                //this.caseField[i].value == "Address_With_Pin_Code__c" 
                if (this.caseField[i].value == "Address_With_Pin_Code__City__s" || this.caseField[i].value == "Address_With_Pin_Code__StateCode__s" || this.caseField[i].value== "Address_With_Pin_Code__CountryCode__s" || 
                this.caseField[i].value == "Address_With_Pin_Code__Street__s " || this.caseField[i].value == "Address_With_Pin_Code__PostalCode__s" || this.caseField[i].value == "Landmark__c" || this.caseField[i].value == "Receiver_contact_number__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Address Change After Shipping' && this.selectedSubSubType === 'Information Given') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Return & Replacement' && this.selectedSubSubType === 'Wrong order or SKU') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "OrderId__c" || this.caseField[i].value == "Brand__c" || this.caseField[i].value == "Product__c	" || this.caseField[i].value == "SKU_Details__c" || this.caseField[i].value == "Order_Image__c" || this.caseField[i].value == "Invoice_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return & Replacement' && this.selectedSubSubType === 'Missing Order or SKU') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "OrderId__c" || this.caseField[i].value == "Brand__c" || this.caseField[i].value == "Product__c	" || this.caseField[i].value == "SKU_Details__c" || this.caseField[i].value == "Order_Image__c" || this.caseField[i].value == "Invoice_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return & Replacement' && this.selectedSubSubType === 'Damaged/Defective Packaging') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "OrderId__c" || this.caseField[i].value == "Brand__c" || this.caseField[i].value == "Product__c	" || this.caseField[i].value == "SKU_Details__c" || this.caseField[i].value == "Order_Image__c" ) {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return & Replacement' && this.selectedSubSubType === 'Damaged/Defective Product') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "OrderId__c" || this.caseField[i].value == "Brand__c" || this.caseField[i].value == "Product__c	" || this.caseField[i].value == "SKU_Details__c" || this.caseField[i].value == "Order_Image__c" ) {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return & Replacement' && this.selectedSubSubType === 'No Damage /No Wrong - Special Approval') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_SKU_details__c" || this.caseField[i].value == "Order_Image__c" || this.caseField[i].value == "Invoice_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return & Replacement' && this.selectedSubSubType === 'Wrong/Damage/Missing- CX wants to keep') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_SKU_details__c" ) {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'Wrong order or SKU') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_SKU_details__c" || this.caseField[i].value == "Order_Image__c" || this.caseField[i].value == "Invoice_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'Missing Order or SKU') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_SKU_details__c" || this.caseField[i].value == "Order_Image__c" || this.caseField[i].value == "Invoice_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'Damaged/Defective Packaging') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_SKU_details__c" || this.caseField[i].value == "Order_Image__c" || this.caseField[i].value == "Invoice_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'Damaged/Defective Product') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_SKU_details__c" || this.caseField[i].value == "Order_Image__c" || this.caseField[i].value == "Invoice_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'No Damage /No Wrong - Special Approval') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_SKU_details__c" || this.caseField[i].value == "Order_Image__c" || this.caseField[i].value == "Invoice_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'Wrong/Damage/Missing- CX wants to keep') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Order_SKU_details__c" || this.caseField[i].value == "Order_Image__c" || this.caseField[i].value == "Invoice_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'Expiry <8 months') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "OrderId__c" || this.caseField[i].value == "Brand__c" || this.caseField[i].value == "Product__c" || this.caseField[i].value == "SKU__c"  || this.caseField[i].value == "Expiry_Date__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'Brand Packaging/ Authencity/Others') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "OrderId__c" || this.caseField[i].value == "Brand__c" || this.caseField[i].value == "Product__c" || this.caseField[i].value == "SKU__c"  || this.caseField[i].value == "Product_Image__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'Product Returned - Refund Awaited') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "RVP_Date__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Return and Refund' && this.selectedSubSubType === 'Refund Processed- Not credited') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Reverse Pick Up' && this.selectedSubSubType === 'RVP delayed') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Expected_RVP_date__c" || this.caseField[i].value == "Customer_s_Availability__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Reverse Pick Up' && this.selectedSubSubType === 'Tracking details') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Reverse Pick Up' && this.selectedSubSubType === 'Cancel RVP') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Reverse Pick Up' && this.selectedSubSubType === 'Wrong courier partner remark') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Remarks_mentioned__c" || this.caseField[i].value == "Actual_Order_Status__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Serviceable Area or PIN Code' && this.selectedSubSubType === 'Serviceable Area/PIN Code') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Required_PIN_code__c" || this.caseField[i].value == "Address_With_Pin_Code__City__s" || this.caseField[i].value == "Address_With_Pin_Code__StateCode__s") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Complaint About Rider or CSE' && this.selectedSubSubType === 'Complaint about Rider') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Complaint About Rider or CSE' && this.selectedSubSubType === 'Complaint about CSE') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Happy Customer' && this.selectedSubSubType === 'Appreciation for CSE') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "CSE_Name__c") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Happy Customer' && this.selectedSubSubType === 'Happy with order packaging') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Happy Customer' && this.selectedSubSubType === 'Happy with delivery time') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Service feedback' && this.selectedSubSubType === 'Delayed delivery') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Service feedback' && this.selectedSubSubType === 'Packaging issues ') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Service feedback' && this.selectedSubSubType === 'App features') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Looking for a Job' && this.selectedSubSubType === 'Information Given') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Missed / Incomplete Conversation' && this.selectedSubSubType === 'Missed / Incomplete Conversation') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Return/Cancellation/ Privacy /Terms of use' && this.selectedSubSubType === 'Guided on App') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'FAQs' && this.selectedSubSubType === 'Information Given') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'General Queries' && this.selectedSubSubType === 'General/Out of Box Enquiries') {
            this.sendCaseField = [];
            for (var i = 0; i < this.caseField.length; i++) {
                if (this.caseField[i].value == "Description") {
                    this.sendCaseField.push(this.caseField[i]);
                }
            }
            this.showSubFields = true;
        }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'PIN code not serviceable') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'Visit Request booking') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'No Elevator in premise') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'Non Perfume queries') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'Porduct /process enquiry only') {
            this.sendCaseField = [];
            // for (var i = 0; i < this.caseField.length; i++) {
            //     if (this.caseField[i].value == "Website_App__c") {
            //         this.sendCaseField.push(this.caseField[i]);
            //     }
            // }
            // this.showSubFields = true;
        }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'Incomplete details') {
            this.sendCaseField = [];
        //     for (var i = 0; i < this.caseField.length; i++) {
        //         if (this.caseField[i].value == "Website_App__c") {
        //             this.sendCaseField.push(this.caseField[i]);
        //         }
        //     }
        //     this.showSubFields = true;
        }
    }

    handleClick(){
        const event = new ShowToastEvent({
            title: 'Case Updated',
            variant: 'success',
            message: 'The case has been Updated successfully.'
        });
        this.dispatchEvent(event);
        this.closeQuickAction();
    }
    handleCancel(){
        this.closeQuickAction();
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        getRecordNotifyChange([{ recordId: this.recordId }]);
    }
}