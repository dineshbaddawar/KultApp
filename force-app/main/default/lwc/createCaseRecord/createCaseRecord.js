import { LightningElement,api,wire,track } from 'lwc';
import getCaseFieldSetList from '@salesforce/apex/CaseHelperControllers.getCaseFieldSetListss';
import getAllCaseFields from '@salesforce/apex/CaseHelperControllers.getAllCaseFields';
import getRecrdTypeId from '@salesforce/apex/CaseHelperControllers.getRecrdTypeId';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DynamicPageGenerator extends LightningElement {
 

    caseFieldSet = [];
    caseField = [];
    sendCaseField = [];
    data;
    data1;
    error1;
    error;
    createdCaseRecordId;
    opprecordid;
    selectedAccountId;
    selectedContactId;
    selectedSubType;
    selectedSubSubType;
    showCaseRecordPage = true;
    showSubmitButton = false;
    showNextButton = true;
    showAccountAddress = false;
    showSubFields = false;
    carValues;
   carColorValues;
   selectedCarValue = '';
   picklistValuesObj;
   selectedCarColorValue = '';
    @api objectName;
    @api recordId;
    @api fieldSet;
    @track fields;
    @track contactId;
    @track accountid;
    @track recodTypeName;
    showOpportunityRecordPage = true;
    @track CaseDataAvail = false;
    @api _txtBoxVal = '';
    @api availableActions = [];

@api
    get txtBoxVal(){
        return this._txtBoxVal;
    }
    set txtBoxVal(val){
        this._txtBoxVal = val;
    }
    handleChange(event) {
        this._txtBoxVal = event.target.value;
    }
    //Change attribute on Flow
    handleClick(event) {  
        const attributeChangeEvent = new FlowAttributeChangeEvent('txtBoxVal', this._txtBoxVal);
        this.dispatchEvent(attributeChangeEvent);  
    }
    //Hook to Flow's Validation engine
    @api validate() {
        if(!this._txtBoxVal.includes('oracle')) {
            return { isValid: true };
            } 
        //If the component is invalid, return the isValid parameter as false and return an error message.
        return {
            isValid: false,
            errorMessage:  'You cannot have string oracle in String'
            }; 
    }

 

     //Go to Next screen of Flow
    handleNext(event){
       const nextNavigationEvent = new FlowNavigationNextEvent();
       this.dispatchEvent(nextNavigationEvent);
    }




    connectedCallback() {
          setTimeout(() => {
               this.callApexMethod();
               this.callApexMethod2();
               this.callApexMethod3();
          }, 300);
     }
     callApexMethod() {
          debugger;
          getCaseFieldSetList()
               .then(result => {
                    if (result) {
                         this.data = result;
                         var TempArray = [];
                         for (var key in this.data) {           
                              TempArray.push({ key: key, value:(this.data)[key] });             
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
     
    onchageInputOpp(event) {
        debugger;
    if (event.target.fieldName == 'Sub_Type__c') {
        this.selectedSubType = event.target.value;
    }
    if (event.target.fieldName == 'Sub_Sub_Type__c') {
        this.selectedSubSubType = event.target.value;
    }

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
            if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
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
            if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
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
            if (this.caseField[i].value== "Error_Description__c" || this.caseField[i].value == "Screen_Shot__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'App Related' && this.selectedSubSubType === 'Product Description/Offer Issues ') {
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
    }else if (this.selectedSubType === 'Refund Issues ' && this.selectedSubSubType === 'Refund Issues') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Payment_ID__c" || this.caseField[i].value == "Error_message__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Mobile Number Change' && this.selectedSubSubType === 'Change in profile number') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Mobile_Number__c") {
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
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Product Price' && this.selectedSubSubType === 'Guided on App') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }Price_Shown__c
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Product Price' && this.selectedSubSubType === 'Price mistmatch ') {
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
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'Upcoming Campaign /Sales updates') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'How to check  product review') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'Giveaway inquiry') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Offers and Promotions' && this.selectedSubSubType === 'Use of Coupon codes') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
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
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Process to Purchase/Delivery Charges' && this.selectedSubSubType === 'Information Given') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Expected Delivery TAT /Preferred Delivery window ' && this.selectedSubSubType === 'Information Given') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Previous order OOS Req for benefit/code' && this.selectedSubSubType === 'Information Given') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
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
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Know more about products' && this.selectedSubSubType === 'Guided on App') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Product Suitability ' && this.selectedSubSubType === 'Guided to explore personalization on app') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Product Quantity or Ingredients or Description' && this.selectedSubSubType === 'Guided to explore personalization on app') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
     //            this.sendCaseField.push(this.caseField[i]);
     //        }
     //    }
     //    this.showSubFields = true;
    }else if (this.selectedSubType === 'Stock / Restock ' && this.selectedSubSubType === 'Guided on App') {
     //    for (var i = 0; i < this.caseField.length; i++) {
     //        if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
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
    }else if (this.selectedSubType === 'Collabration Request/Influencer queries' && this.selectedSubSubType === 'Collabration Request/Influencer queries') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Instagram_user_Id__c" || this.caseField[i].value == "Contact_Number__c" || this.caseField[i].value == "Email_Id__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Collabration service issues' && this.selectedSubSubType === 'Collabration service issues') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Instagram_ID__c" || this.caseField[i].value == "Contact_Number__c" || this.caseField[i].value == "Email_Id__c" || this.caseField[i].value == "Issue_Description__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Collabration Request' && this.selectedSubSubType === 'Collabration Request') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Content Issues - Cx' && this.selectedSubSubType === 'Content Issues - Cx') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Content Issues - Partners' && this.selectedSubSubType === 'Content Issues - Partners') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Order number confirmation') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Tracking details') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Delivery Delayed') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Mismatch is address details') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Address_With_Pin_Code__c" || this.caseField[i].value == "Landmark__c" || this.caseField[i].value == "Receiver_contact_number__c" ) {
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
    }else if (this.selectedSubType === 'Order Status' && this.selectedSubSubType === 'Change in delivery schedule') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Expected_Date_Time__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Gift Before Shipping' && this.selectedSubSubType === 'Send order as gift') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Receiver_Name__c" || this.caseField[i].value == "Address__c" || this.caseField[i].value == "Landmark_Receiver_Mobile_Number__c" || this.caseField[i].value == "Pincode") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Gift After Shipping' && this.selectedSubSubType === 'Send order as gift') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value== "Mobile_Number__c" || this.caseField[i].value == "Screen_Shot__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'OOS') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "OOS_SKU__c" || this.caseField[i].value == "Product_Name__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Other Internal Issues/Monitoring Reasons') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Describe_In_Free_Text__c") {
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
            if (this.caseField[i].value== "Reasons_to_describe_in_free_text__c" ) {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Price Issue') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value== "Reasons_to_describe_in_free_text__c" ) {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Bad review of product') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Website_App__c") {
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
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Others') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'OOS') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Website_App__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Other Internal Issues/Monitoring Reasons') {
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
            if (this.caseField[i].value == "Reasons_to_describe_in_free_text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Price Issue') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Reasons_to_describe_in_free_text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Bad review of product') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Website_App__c") {
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
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation After Shipping' && this.selectedSubSubType === 'Others') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Cancellation Before Shipping' && this.selectedSubSubType === 'Ecom Reason - Order lost in transit') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Address Change Before Shipping' && this.selectedSubSubType === 'Address Change - Before Shipping') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Address_With_Pin_Code__c" || this.caseField[i].value == "Landmark__c" || this.caseField[i].value == "Receiver_contact_number__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Address Change After Shipping' && this.selectedSubSubType === 'Information Given') {
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
    }else if (this.selectedSubType === 'Return and Refundt' && this.selectedSubSubType === 'Wrong order or SKU') {
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
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Reverse Pick Up' && this.selectedSubSubType === 'Wrong courier partner remarks') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Serviceable Area or PIN Code' && this.selectedSubSubType === 'Serviceable Area/PIN Code') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Required_PIN_code__c" || this.caseField[i].value == "City__c" ) {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Complaint About Rider or CSE' && this.selectedSubSubType === 'Complaint about Rider') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Complaint About Rider or CSE' && this.selectedSubSubType === 'Complaint about CSE') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Happy Customer' && this.selectedSubSubType === 'Appriciation for CSE') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "CSE_Name__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Happy Customer' && this.selectedSubSubType === 'Happy with order packaging') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Happy Customer' && this.selectedSubSubType === 'Happy with delivery time') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Service feedback' && this.selectedSubSubType === 'Delayed delivery') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Service feedback' && this.selectedSubSubType === 'Packaging issues ') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Service feedback' && this.selectedSubSubType === 'App features') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Looking for a Job' && this.selectedSubSubType === 'Information Given') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Missed / Incomplete Conversation' && this.selectedSubSubType === 'Missed / Incomplete Conversation') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Return/Cancellation/ Privacy /Terms of use' && this.selectedSubSubType === 'Guided on App') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'FAQs' && this.selectedSubSubType === 'Information Given') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'General Queries' && this.selectedSubSubType === 'General /Out of Box Enquiries') {
        this.sendCaseField = [];
        for (var i = 0; i < this.caseField.length; i++) {
            if (this.caseField[i].value == "Describe_In_Free_Text__c") {
                this.sendCaseField.push(this.caseField[i]);
            }
        }
        this.showSubFields = true;
    }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'PIN code not serviceable') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'Visit Request booking') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'No Elevator in premise') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'Non Perfume queries') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'Porduct /process enquiry only') {
        // for (var i = 0; i < this.caseField.length; i++) {
        //     if (this.caseField[i].value == "Website_App__c") {
        //         this.sendCaseField.push(this.caseField[i]);
        //     }
        // }
        // this.showSubFields = true;
    }else if (this.selectedSubType === 'Home Visit' && this.selectedSubSubType === 'Incomplete details') {
    //     for (var i = 0; i < this.caseField.length; i++) {
    //         if (this.caseField[i].value == "Website_App__c") {
    //             this.sendCaseField.push(this.caseField[i]);
    //         }
    //     }
    //     this.showSubFields = true;
    }
}

     handleSuccess(event) {
          debugger;
          console.log('onsuccess event recordEditForm', event.detail.id)
          this.createdCaseRecordId = event.detail.id;
          this.opprecordid = event.detail.id;
          this.showCaseRecordPage = false;
          this.showNextButton = false;
          this.showSubmitButton = true;
          const toastEvent = new ShowToastEvent({
              title: 'SUCCESS',
              message: 'Record Created Successfully !',
              variant: 'success',
              mode: 'dismissable'
          });
          this.dispatchEvent(toastEvent);        
          }

          handleError(event) {
          debugger;
          let message = event.detail.detail;
     }
     handleSubmit(event) {
          debugger;
          console.log('onsubmit event recordEditForm'+ event.detail.fields);
     }
     handleSubmitForOtherFields(){
        debugger;
        console.log('onsubmit event recordEditForm'+ event.detail.fields);
     }
           successToastMessage() {
          const event = new ShowToastEvent({
              title: 'SUCCESS',
              message: 'Record Created Successfully !',
              variant: 'success',
              mode: 'dismissable'
          });
          this.dispatchEvent(event);
     }
     
}