import { LightningElement, wire, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import fetchDependentPicklist from '@salesforce/apex/CaseHelperControllers.fetchDependentPicklist';
import getCaseRecords from '@salesforce/apex/CaseHelperControllers.getCaseRecords';
import getFieldDependencies from '@salesforce/apex/CaseHelperControllers.dependentFields';
import getOrderItems from '@salesforce/apex/CaseHelperControllers.getOrderItems';
import createCaseInLiveChatTranscript from '@salesforce/apex/CaseHelperControllers.createCaseInLiveChatTranscript';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { getRecordNotifyChange } from "lightning/uiRecordApi";


export default class CustomRoutePage extends LightningElement {
    @track typeDependentPicklistWrapperArray = [{}];
    @track typeDependentPicklist = [{}]
    @track typeOptions;
    @track ratingOptions;
    @track industryOptions;
    selectedTypeValue;
    selectedRatingValue;
    selectedIndustryValue;
    selectedSalesUserId;
    selectedAcc;
    selectedCon;
    selectedUsr;
    inpName;
    selectedOrd;
    @track orderHasItemAvailable = false;
    @track AllOrderItems = [];
    @track isModalOpen = true;
    @track OrderList = [];
    @track selectedOrderId = [];
    @track show1stPage = true;
    @track show2ndPage = false;
    data;
    error;

    @api recordId;


    @track message;
    @track error;
    @track recordTypeId = '';

    connectedCallback() {
        setTimeout(() => {
            this.doSearch();
        }, 300);
    }
    @track contacts;
    doSearch() {
        debugger;
        getCaseRecords()

            .then(result => {
                this.contacts = result;
                if (this.contacts && Array.isArray(this.contacts)) {
                    this.contacts.forEach(element => {
                        if (element.OwnerId) {
                            element.Owner = element.Owner.Name;
                        }
                    });
                }
                this.contacts = result;
                console.log('this.contacts-', this.contacts);
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.contacts = undefined;
            });
    }
    callAllOrderItems() {
        debugger;
        getOrderItems({ OrdId: this.selectedOrd })

            .then(result => {
                result.forEach(item => {
                    this.AllOrderItems.push({
                        productName: item.Product2.Name,
                        Id: item.Id,
                        totalQuantity: item.Quantity,
                        totalprice: item.Total_Selling_Price__c,
                        skudetail: item.SKU__c,
                    });
                });


                this.error = undefined;
                this.orderHasItemAvailable = true;

            })
            .catch(error => {
                this.error = error;
                this.AllOrderItems = undefined;
            });
    }


    matchingInfo = {
        primaryField: { fieldPath: "Name" },
        additionalFields: [{ fieldPath: "Title" }],
    };
    displayInfo = {
        additionalFields: ["Title"],
    };

    @wire(fetchDependentPicklist, {})
    fetchDependentPicklist({ error, data }) {
        debugger;
        if (data) {
            debugger;
            try {
                this.typeDependentPicklistWrapperArray = data;
                let options = [];
                for (var key in data) {
                    options.push({ label: key, value: key });
                }
                this.typeOptions = options;
                this.ratingOptions = undefined;
                this.industryOptions = undefined;
            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
    }
    @wire(getFieldDependencies, {})
    getFieldDependencies({ error, data }) {
        debugger;
        if (data) {
            try {
                this.typeDependentPicklist = data;
                let options = [];
            }
            catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
    }

    handleTypeChange(event) {
        debugger;
        try {
            this.selectedRatingValue = undefined;
            this.selectedIndustryValue = undefined;
            this.ratingOptions = undefined;
            this.industryOptions = undefined;
            this.selectedTypeValue = event.detail.value;
            var typePicklist = this.typeDependentPicklistWrapperArray[this.selectedTypeValue];
            let options = [];
            for (var i = 0; i < typePicklist.length; i++) {
                options.push({ label: typePicklist[i], value: typePicklist[i] });
            }

            this.ratingOptions = options;
        } catch (error) {
            console.error('check error here', error);
        }
    }

    handleRatingChange(event) {
        debugger;
        try {
            this.selectedIndustryValue = undefined;
            this.industryOptions = undefined;
            this.selectedRatingValue = event.detail.value;
            var picklisType = this.typeDependentPicklist[this.selectedRatingValue];
            let options = [];
            for (var i = 0; i < picklisType.length; i++) {
                options.push({ label: picklisType[i], value: picklisType[i] });
            }
            this.industryOptions = options;
        } catch (error) {
            console.error('check error here', error);
        }

    }
    handleIndustryChange(event) {
        debugger;
        this.selectedIndustryValue = event.detail.value;
    }

    closeAction() {
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    closeModal() {
        debugger;
        this.isModalOpen = false;
    }
    handleNext() {
        debugger;
        this.show2ndPage = true;
        this.show1stPage = false;
    }

    handleBack() {
        debugger;
        this.show1stPage = true;
        this.show2ndPage = false;
    }
    handlesChange(event) {
        debugger;
        this.selectedSalesUserId = event.currentTarget.dataset.index;
        let selectedSalesUserId = event.currentTarget.dataset.id;
        this.inpName = event.target.name;

        if (this.inpName === 'Subject') {
            this.contacts.Subject = event.detail.value;
        }

        if (this.inpName === 'Contact-Number') {
            this.contacts.Contact_Number__c = event.detail.value;
        }

        if (this.inpName === 'checkbox') {
            const rowIndex = event.target.dataset.rowIndex;
            this.AllOrderItems = this.AllOrderItems.map((record, index) => {
                if (index === parseInt(rowIndex) && !event.target.checked) {
                    if (!event.target.checked) {
                        record.editable = true;
                        record.checkboxVal2 = event.target.checked;
                        record.disableReason = true;

                    }
                }
                return record;
            });
        }
    }



    handleChangeInPicker(event) {
        debugger;

        this.inpName = event.target.name;
        if (this.inpName == 'selectedContact') {
            this.selectedCon = event.detail.recordId;
        }
        if (this.inpName == 'selectedAccount') {
            this.selectedAcc = event.detail.recordId;
        }
        if (this.inpName == 'selectedUser') {
            this.selectedUsr = event.detail.recordId;
        }
        if (this.inpName == 'selectedOrder') {
            this.selectedOrd = event.detail.recordId;
            this.callAllOrderItems();

        }

    }


    handleClick() {
        debugger;
        if (this.selectedTypeValue != null && this.selectedTypeValue != 'Undefined' && this.selectedTypeValue != ' ') {
            if (this.selectedRatingValue != null && this.selectedRatingValue != 'Undefined' && this.selectedRatingValue != ' ') {
                if (this.selectedIndustryValue != null && this.selectedIndustryValue != 'Undefined' && this.selectedIndustryValue != ' ') {
                    createCaseInLiveChatTranscript({
                        RecordTypeName: this.selectedTypeValue,
                        Type: this.selectedRatingValue,
                        SubType: this.selectedIndustryValue,
                        Subjt: this.Subject,
                        recId: this.recordId,
                        ownId: this.selectedUsr,
                        AccId: this.selectedAcc,
                        conId: this.selectedCon,
                        conNumber: this.contacts.Contact_Number__c
                    })
                        .then(result => {
                            if (result) {
                                this.data = result;
                                this.isModalOpen = false;
                                const event = new ShowToastEvent({
                                    title: 'Case Created ',
                                    variant: 'success',
                                    message: 'The case has been created successfully.'
                                });
                                this.dispatchEvent(event);
                                this.dispatchEvent(new CloseActionScreenEvent());
                                this.dispatchEvent(new RefreshEvent());
                                getRecordNotifyChange([{ recordId: this.recordId }]);
                            }
                        })
                        .catch(error => {
                            this.error = error;
                            console.log('error == >' + error);
                        });
                } else {
                    const event = new ShowToastEvent({
                        title: 'Case Creation is Unsuccessfull',
                        variant: 'error',
                        message: 'Please Fill the Sub-Type.'
                    });
                    this.dispatchEvent(event);
                }
            } else {
                const event = new ShowToastEvent({
                    title: 'Case Creation is Unsuccessfull',
                    variant: 'error',
                    message: 'Please Fill the Type .'
                });
                this.dispatchEvent(event);
            }
        }
        else {
            const event = new ShowToastEvent({
                title: 'Case Creation is Unsuccessfull',
                variant: 'error',
                message: 'Please Fill the Record type.'
            });
            this.dispatchEvent(event);
        }
    }
}