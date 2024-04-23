import { LightningElement, api, track, wire } from 'lwc';
// import courierRelatedCase from '@salesforce/apex/CaseHelperControllers.courierRelatedCase';
import updateCaseAndOrderAddressAndNumber from '@salesforce/apex/CaseHelperControllers.updateCaseAndOrder';
// import getAllPickListVal from '@salesforce/apex/CaseHelperControllers.getAllPickListVal';
import getCaseFieldSetListForCourierIssue from '@salesforce/apex/CaseHelperControllers.getCaseFieldSetListForCourierIssue';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CouriersIssue extends LightningElement {

    @api recordId;
    @track data = [{}];
    @track orderResult;
    @track singleCase = {};
    @track allFields = [];
    @track caseFieldSet = [];
    @track CaseDataAvail = false;
    error;
    @track contactPhone;
    inpName;
    @track AddressCountryCodeValues = [];
    @track AddressStateCodeValues = [];
    countryValue;
    StateValue;





    // getAllPicklistValues() {
    //     getAllPickListVal()
    //         .then(result => {
    //             debugger;
    //             let options = [];
    //             console.log(JSON.stringify(result));
    //             for (var i = 0; i < result.length; i++) {
    //                 options.push({ label: result[i], value: result[i] });
    //             }
    //             this.AddressCountryCodeValues = options;
    //         })
    //         .catch(error => {
    //             console.error('Error for picklist==>' + JSON.stringify(error));
    //         });
    // }


    connectedCallback() {
        debugger;
        var url = window.location.href.toString();
        const queryParams = url.split("&");
        const recordIdParam = queryParams.find(param => param.includes("recordId"));

        if (recordIdParam) {
            const recordIdKeyValue = recordIdParam.split("=");
            if (recordIdKeyValue.length === 2) {
                const recordId = recordIdKeyValue[1];
                this.recordId = recordId;
            } else {
                console.error("Invalid recordId parameter format");
            }
        } else {
            console.error("recordId parameter not found in the URL");
        }
        this.callApexMethod();
        // this.getAllPicklistValues();
    }


    callApexMethod() {
        debugger;
        getCaseFieldSetListForCourierIssue()
             .then(result => {
                  if (result) {
                       this.allFields = result;
                       var TempArray = [];
                       for (var key in this.allFields) {           
                            TempArray.push({ key: key, value:(this.allFields)[key] });             
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

   handleClick(){
    const event = new ShowToastEvent({
        title: 'Case Updated',
        variant: 'success',
        message: 'The case has been Updated successfully.'
    });
    this.dispatchEvent(event);
    this.closeModal();
    getRecordNotifyChange([{ recordId: this.recordId }]);
    this.handleSave();
}

    // callApexMethod() {
    //     debugger;
    //     courierRelatedCase({ recId: this.recordId })
    //         .then(result => {
    //             this.singleCase = result;
    //             this.error = undefined;
    //             //this.contactPhone = this.data.Contact.Phone;
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             this.data = undefined;
    //         });
    // }

    //   // Wire service to get gender piklist
    //   @wire(getObjectInfo, { objectApiName: CaseObject })
    //   objectInfo;
    //   @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: RelationShipField })
    //   wiredRelationShipData({ error, data }) {
    //     debugger;
    //       if (data) {
    //           console.log('RelationShipField data:', data);
    //           this.lstGenderTypes = data.values;
    //           console.log('this.lstGenderTypes==>' + this.lstGenderTypes);
    //       } else if (error) {
    //           console.error('Error in RelationShipField picklist field', JSON.stringify(error));
    //       }
    //   }


    // hadleChange(event) {
    //     debugger;
    //     this.inpName = event.target.name;

    //     if (this.inpName == "Country") {
    //         this.countryValue = event.target.value;
    //         if (this.countryValue != null || this.countryValue != '') {
    //             this.getPicklistForState();
    //         }
    //     }
    //     if (this.inpName == 'State') {
    //         this.StateValue = event.target.value;
    //     }
    //     if (this.inpName == 'StreetName') {
    //         this.data.Address_With_Pin_Code__Street__s = event.target.value;
    //     }
    //     if (this.inpName == 'CityName') {
    //         this.data.Address_With_Pin_Code__City__s = event.target.value;
    //     }
    //     if (this.inpName == 'PinCode') {
    //         this.data.Address_With_Pin_Code__PostalCode__s = event.target.value;
    //     }
    //     // if (this.inpName == 'CountryName') {
    //     //     this.data.Address_With_Pin_Code__CountryCode__s = event.target.value;
    //     // }
    //     if (this.inpName == 'StateCode') {
    //         this.data.Address_With_Pin_Code__StateCode__s = event.target.value;
    //     }
    //     if (this.inpName == 'contactPhone') {
    //         this.contactPhone = event.target.value;
    //     }
    // }

    handleSave() {
        debugger;
        updateCaseAndOrderAddressAndNumber({
            recId: this.recordId,
        })
            .then((result) => {
                if (result) {
                    this.orderResult = result;
                }
            })
            .catch((error) => {
                this.error = error;
                console.log('error == >' + error);
            });
    }



    handleCancel() {
        this.closeModal();
    }
    closeModal() {

        this.dispatchEvent(new CloseActionScreenEvent());

    }
}