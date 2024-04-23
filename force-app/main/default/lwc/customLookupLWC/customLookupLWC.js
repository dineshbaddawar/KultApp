import {api, wire, LightningElement } from 'lwc';
import getLookupValues from '@salesforce/apex/CustomLookupLwcController.getLookupValues';
import getinitRecord from '@salesforce/apex/CustomLookupLwcController.getinitRecord';
import gerRecentlyCreatedRecords from '@salesforce/apex/CustomLookupLwcController.gerRecentlyCreatedRecords';
export default class CustomLookupLWC extends LightningElement {
//public properties
@api uniqueName = 'Order';
@api initialLookupValue = '';
@api objectAPIName = 'Order';
displayLabelField = 'Name';
@api iconName = 'standard:Order';
@api labelForComponent = 'Order'
@api placeHolder = 'Search Order'
@api recordLimit = 10;
@api labelHidden = false;
searchKeyWord = '';
@api selectedRecord = {}; // Use, for store SELECTED sObject Record
@api where = '';
 selectedCandidateId = '';

// private properties
selectedRecordLabel = '';
searchRecordList = []; // Use,for store the list of search records which returns from apex class
message = '';
spinnerShow = false;
error = '';
noRecordFound = false;
     
     @wire(getLookupValues, { searchKeyWord: '$searchKeyWord', objectAPIName: '$objectAPIName', whereCondition: '$where', fieldNames: '$displayLabelField', customLimit: '$recordLimit' })
     wiredsearchRecordList({ error, data }) {
     debugger;
     this.spinnerShow = true;
     if (data) {
          this.spinnerShow = false;
          this.searchRecordList = JSON.parse(JSON.stringify(data));
          this.error = undefined;
          this.hasRecord();
     } else if (error) {
          console.log('getLookupValues Error 2 —> ' + JSON.stringify(error));
          this.hasRecord();
          this.error = error;
          this.searchRecordList = undefined;
     }
  }

     connectedCallback() {
     debugger;
     if (this.initialLookupValue != '') {
          getinitRecord({ recordId: this.initialLookupValue, 'objectAPIName': this.objectAPIName, 'fieldNames': this.displayLabelField })
               .then((data) => {
                    if (data != null) {
                         console.log('getinitRecord —> ', JSON.stringify(data));
                         this.selectedRecord = data;
                         this.selectedRecordLabel = data.Name; //data[this.displayLabelField];
                         this.selectionRecordHelper();
                    }
               })
               .catch((error) => {
                    console.log('getinitRecord Error —> ' + JSON.stringify(error));
                    this.error = error;
                    this.selectedRecord = {};
               });
         }
     }

     handleClickOnInputBox(event) {
     // debugger;
     let container = this.template.querySelector('.custom-lookup-container');
     container.classList.add('slds-is-open');
     this.spinnerShow = true;
     console.log(this.where);
     if (typeof this.searchKeyWord === 'string' && this.searchKeyWord.trim().length === 0) {
          gerRecentlyCreatedRecords({ 'objectAPIName': this.objectAPIName, 'fieldNames': this.displayLabelField, 'whereCondition': this.where, 'customLimit': this.recordLimit })
               .then((data) => {
                    if (data != null) {
                         try {
                         console.log('gerRecentlyCreatedRecords —> ', JSON.stringify(data));
                         this.spinnerShow = false;
                         this.searchRecordList = JSON.parse(JSON.stringify(data));
                         this.hasRecord();
                         } catch (error) {
                         console.log(error);
                         this.hasRecord();
                         }
                    }
               })
               .catch((error) => {
                    console.log('gerRecentlyCreatedRecords Error —> ' + JSON.stringify(error));
                    this.error = error;
               });

     } else if (typeof this.searchKeyWord === 'string' && this.searchKeyWord.trim().length > 0) {
          let temp = this.searchKeyWord
          this.searchKeyWord = temp;
          getLookupValues({ 'searchKeyWord': this.searchKeyWord, 'objectAPIName': this.objectAPIName, 'whereCondition': this.where, 'fieldNames': this.displayLabelField, 'customLimit': this.recordLimit })
               .then((data) => {
                    debugger;
                    if (data != null) {
                         console.log('getLookupValues —> ', JSON.stringify(data));
                         this.spinnerShow = false;
                         this.searchRecordList = JSON.parse(JSON.stringify(data));
                         this.error = undefined;
                         this.hasRecord();
                    }
               })
               .catch((error) => {
                    console.log('getLookupValues Error —> ' + JSON.stringify(error));
                    this.error = error;
                    this.selectedRecord = {};
               });
         }
     }

     fireLookupUpdateEvent(value) {
     debugger;
     const oEvent = new CustomEvent('customLookupUpdateEvent',{'detail': {'name': this.uniqueName,'selectedRecord': value}});
     this.dispatchEvent(oEvent);
     }

     handleKeyChange(event) {
     this.searchKeyWord = event.detail.value;
     console.log(this.searchKeyWord);
     if (typeof this.searchKeyWord === 'string' && this.searchKeyWord.trim().length > 0) {
          this.searchRecordList = [];
     }
   }

     handleOnblur(event) {
     debugger;
     let container = this.template.querySelector('.custom-lookup-container');
     container.classList.remove('slds-is-open');
     this.spinnerShow = false;
     this.searchRecordList = [];
     }

     handleSelectionRecord(event) {
     debugger;
     var recid = event.target.getAttribute('data-recid');
     this.selectedCandidateId = recid;
     console.log('recid ====> ', recid);
     let container = this.template.querySelector('.custom-lookup-container');
     container.classList.remove('slds-is-open');
     this.selectedRecord = this.searchRecordList.find(data => data.Id === recid);
     this.selectedRecordLabel = this.selectedRecord.Name;//this.selectedRecord[this.displayLabelField];
     console.log(this.selectedRecord);
     console.log(this.selectedRecordLabel);
     
     // Creates the event with the data.
          const selectedEvent = new CustomEvent("progressvaluechange", {
          detail: this.selectedCandidateId
          });
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);

     this.fireLookupUpdateEvent(this.selectedRecord);
     this.selectionRecordHelper();
     }

     selectionRecordHelper() {
     debugger;
     let custom_lookup_pill_container = this.template.querySelector('.custom-lookup-pill');
     custom_lookup_pill_container.classList.remove('slds-hide');
     custom_lookup_pill_container.classList.add('slds-show');
     let search_input_container_container = this.template.querySelector('.search-input-container');
     search_input_container_container.classList.remove('slds-show');
     search_input_container_container.classList.add('slds-hide');
     }

     clearSelection() {
     debugger;
     let custom_lookup_pill_container = this.template.querySelector('.custom-lookup-pill');
     custom_lookup_pill_container.classList.remove('slds-show');
     custom_lookup_pill_container.classList.add('slds-hide');
     let search_input_container_container = this.template.querySelector('.search-input-container');
     search_input_container_container.classList.remove('slds-hide');
     search_input_container_container.classList.add('slds-show');
     this.fireLookupUpdateEvent(undefined);
     this.clearSelectionHelper();
     }

     clearSelectionHelper() {
     this.selectedRecord = {};
     this.selectedRecordLabel = '';
     this.searchKeyWord = '';
     this.searchRecordList = [];
     }

     hasRecord() {
     debugger;
     if (this.searchRecordList && this.searchRecordList.length > 0) {
          this.noRecordFound = false;
     } else {
          this.noRecordFound = true;
     }
   }

}