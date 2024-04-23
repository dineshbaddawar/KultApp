import { LightningElement, wire, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import fetchDependentPicklist from '@salesforce/apex/CaseHelperControllers.fetchDependentPicklist';
import getCaseRecord from '@salesforce/apex/CaseHelperControllers.getCaseRecord';
import getFieldDependencies from '@salesforce/apex/CaseHelperControllers.dependentFields';
import createChildCase from '@salesforce/apex/CaseHelperControllers.createChildCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';

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
    inpName;
    @track isModalOpen = true;
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
        getCaseRecord({ caseId: this.recordId })

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
                this.selectedAcc = result.AccountId;
                this.selectedCon = result.ContactId;
                console.log('this.contacts-', this.contacts);
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.contacts = undefined;
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

    handlesChange(event) {
        this.selectedSalesUserId = event.detail.recordId;
        this.inpName = event.target.name;
        if (this.inpName == 'Subject') {
            this.selectedSubject = event.detail.value;
        }
        if (this.inpName == 'Contact-Number') {
            this.selectedConNumber = event.detail.value;
        }

    }

    handleChangeInPicker(event) {
        this.inpName = event.target.name;
        if (event.target.name == 'selectedContact') {
            this.selectedCon = event.detail.value;   
        }
        if (event.target.name == 'selectedAccount') {
            
            this.selectedAcc = event.detail.value;
        }
    }

    handleClick() {
        debugger;
        if (this.selectedTypeValue != null && this.selectedTypeValue != 'Undefined' && this.selectedTypeValue != ' ') {
            if (this.selectedRatingValue != null && this.selectedRatingValue != 'Undefined' && this.selectedRatingValue != ' ') {
                if (this.selectedIndustryValue != null && this.selectedIndustryValue != 'Undefined' && this.selectedIndustryValue != ' ') {
                    createChildCase({
                        RecordTypeName: this.selectedTypeValue,
                        Type: this.selectedRatingValue,
                        SubType: this.selectedIndustryValue,
                        Subjt: this.selectedSubject,
                        recId: this.recordId,
                        ownId: this.contacts.OwnerId,
                        AccId: this.selectedAcc,
                        conId: this.selectedCon,
                        conNumber: this.selectedConNumber
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