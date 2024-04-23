/**
 * @author [Dinesh Baddawar]
 * @email dinesh.b@utilitarianLab.com
 * @create date 2024-03-06 13:48:39
 * @modify date 2024-03-12 18:53:55
 * @desc [description]
 */

import { LightningElement, api } from 'lwc';
import getAccountDetailsBasedPhone from '@salesforce/apex/InboungFlowHelper.getAccountDetailsBasedPhone';
import updateCTIPhonePrimaryPhoneOnAccount from '@salesforce/apex/InboungFlowHelper.updateCTIPhonePrimaryPhoneOnAccount';
import { CloseActionScreenEvent } from 'lightning/actions';
import getAccountFieldSetListss from '@salesforce/apex/InboungFlowHelper.getAccountFieldSetListss';
import findAccountUsingPhone from '@salesforce/apex/InboungFlowHelper.findAccountUsingPhone';
import createNewAccount from '@salesforce/apex/InboungFlowHelper.createNewAccount';
export default class InboundCallLogquickaction extends LightningElement {
     @api recordId;
     @api objectApiName = 'Account';
     data;
     error;
     updatedAccount;
     isShowPDFPreview = false;
     isShowAccountViewForm = false;
     NoAccountFound = false;
     ShowAccountDetailVFP = false;
     primPhone;
     aletNatePhone;
     accountId;
     oppFiedlSet = [];
     @api updatedaccountid;
     showCreateCase = false;
     pdfLink;
     defaultaccountId;
     currentPhoneValue;
     CreateAccountForm = false;
     accountName;
     
     accountPageURL = 'https://ruby-customization-1508--kultapp--c.sandbox.vf.force.com/apex/InboundAccountDetailForm?id=';
     connectedCallback() {
          setTimeout(() => {
               this.CallApexMethod();
               this.accountId = this.recordId;
          }, 500);
     }
     CallFiledSetMethod() {
          debugger;
          getAccountFieldSetListss()
               .then(result => {
                    if (result) {
                         this.data = result;
                         var TempArray = [];
                         for (var key in this.data) {           
                              TempArray.push({ key: key, value:(this.data)[key] });             
                         }  
                         this.oppFiedlSet = TempArray;
                         console.log('key', this.oppFiedlSet); 
                         this.isShowAccountViewForm = true;
               }
               })
               .catch(error => {
                    this.error = error;
          })
     }

     CallFiledSetMethodAccountFind() {
          debugger;
          getAccountFieldSetListss()
               .then(result => {
                    if (result) {
                         this.data = result;
                         var TempArray = [];
                         for (var key in this.data) {           
                              TempArray.push({ key: key, value:(this.data)[key] });             
                         }  
                         this.oppFiedlSet = TempArray;
                         console.log('key', this.oppFiedlSet); 
                        // this.isShowAccountViewForm = true;
               }
               })
               .catch(error => {
                    this.error = error;
          })
     }

     CallApexMethod() {
          debugger;
          getAccountDetailsBasedPhone({ InboundPhone: '8446557829' })
               .then(result => {
                    if (result !=null) {
                         this.data = result;
                         this.currentPhoneValue = result.Phone;
                         //  this.pdfLink = this.accountPageURL + this.data.Id; 
                         this.CallFiledSetMethodAccountFind();
                         this.defaultaccountId = this.data.Id;
                         // 1 this.ShowAccountDetailVFP = true;
                         this.NoAccountFound = true;
                        // this.isShowPDFPreview = true;
                    } else {
                        // this.NoAccountFound = true;
               }
               })
               .catch(error => {
                    this.error = error;
          })
     }

     handleAlertNatePhoneChange(event) {
          debugger;
           this.aletNatePhone = event.target.value;
     }
     handlePrimaryPhoneChange(event) {
          debugger;
           this.primPhone = event.target.value;
     }
     handleAccountName(event) {
          debugger;
          this.accountName = event.target.value;
     }
     handlePrimaryPhone(event) {
          debugger;
          this.primPhone = event.target.value;
     }
     NextButtonClick() {
          debugger;
          updateCTIPhonePrimaryPhoneOnAccount({ primaryPhone: this.primPhone, alternatePhone: this.aletNatePhone, recordId: this.accountId })
               .then(result => {
                    this.updatedAccount = result;
                    this.updatedaccountid = result.Id;
                   //  this.pdfLink = this.accountPageURL + result.Id;
                   // this.isShowAccountViewForm = true;
                    this.NoAccountFound = false;
                  this.CallFiledSetMethod();
               })
               .catch(error => {
               this.error = error;
          })
          
     }

     CreateCaseDetailPage() {
          debugger;
          this.showCreateCase = true;
          this.isShowAccountViewForm = false;
     }

     closeQuickAction() {
          this.dispatchEvent(new CloseActionScreenEvent());
     }
     
     FindAccount() {
          debugger;
          findAccountUsingPhone({ accountPrimaryPhone: this.primPhone })
               .then(result => {
                    if (result != null) {
                         this.updatedaccountid = result.Id;
                         this.isShowAccountViewForm = true;
                         this.NoAccountFound = false;

                    } else {
                         this.CreateAccountForm = true;
                         this.NoAccountFound = false;
               }
          })
     }

     CreateNewAccount() {
          debugger;
          createNewAccount({ Accountname: this.accountName, AccountPrimaryPhone: this.primPhone, alertnatePhone: this.currentPhoneValue })
               .then(result => {
                    if (result != null) {
                         this.updatedaccountid = result.Id;
                         this.isShowAccountViewForm = true;
                         this.CreateAccountForm = false;
                    } else {
                         console.log('Error find method createNewAccount == >' + error);
               }
          })
     }
}