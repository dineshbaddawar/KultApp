import { LightningElement, api, track, wire } from 'lwc';
import getFieldDependencies from '@salesforce/apex/CaseHelperControllers.dependentFields';
import fetchDependentPicklist from '@salesforce/apex/CaseHelperControllers.fetchDependentPicklist';
import createCaseUnderAccount from '@salesforce/apex/CaseHelperControllers.createCaseUnderAccount';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import INDUSTRY_FIELD from '@salesforce/schema/Case.Category__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Case';
import CaseBaseURL from '@salesforce/label/c.CaseBaseURL';

export default class InBoundCallFlow extends LightningElement {

    @api recordId;
    @track typeDependentPicklistWrapperArray;
    @track typeDependentPicklist;
    @track recordaccountid;
    @track caseRecordType;
    @track selectedTypeValue;
    @track selectedRatingValue;
    @track selectedIndustryValue;
    @track typeOptions;
    @track ratingOptions;
    @track industryOptions;
    @track isModalOpen;
    show1stPage = false;
    show2ndPage = false;
    showUsersRelatedToProfile= false;
    showProfile = false;
    @track ProfileValue;
    @track UserValue;
    @track selectedProfile;
    @track selectedUser;
    Userfilter = {};
    profileList=[];
    @track profiles;
    profileVL;
    @track Subject;
    @track Description
    IndustryPicklistValues = [];
    optionsCategory = [];
    selectedOrderId;
    data;
    @track inpName;
    CaseBaseURL = CaseBaseURL;


    
    @wire( getObjectInfo, { objectApiName: ACCOUNT_OBJECT } )
    objectInfo;

    @wire( getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: INDUSTRY_FIELD } )
    wiredIndustryData( { error, data } ) {
        console.log( 'Inside Industry Get Picklist Values' );
        if ( data ) {
            this.optionsCategory = data.values;
        } else if ( error ) {
            console.error( 'Error in Industry picklist field', JSON.stringify( error ) );
        }

    }

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
        
        this.recordaccountid = this.recordId;
    }
    

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
                this.show1stPage = true;
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
                this.show1stPage = true;
            } catch (error) {
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
            var picklistType = this.typeDependentPicklist[this.selectedRatingValue];
            let options = [];
            for (var i = 0; i < picklistType.length; i++) {
                options.push({ label: picklistType[i], value: picklistType[i] });
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

    handlechange(event){
        debugger;
        this.inpName = event.target.name;
        if(this.inpName == 'Subject'){
            this.Subject = event.target.value;
        } if(this.inpName == 'Description'){
            this.Description = event.target.value;
        }
        if(this.inpName == 'Category'){
            this.value1 = event.target.value;
        }
    }

    handleSave() {
        try {
            debugger;
            if (this.selectedTypeValue != null && this.selectedTypeValue != 'Undefined' && this.selectedTypeValue != ' ') {
                if (this.selectedRatingValue != null && this.selectedRatingValue != 'Undefined' && this.selectedRatingValue != ' ') {
                    if (this.selectedIndustryValue != null && this.selectedIndustryValue != 'Undefined' && this.selectedIndustryValue != ' ') {
                        if (this.value1 != null && this.value1 != undefined && this.value1 != ' ') {
                            createCaseUnderAccount({
                                RecordTypeName: this.selectedTypeValue,
                                Type: this.selectedRatingValue,
                                SubType: this.selectedIndustryValue,
                                Subjt: this.Subject,
                                Description: this.Description,
                                OrderId: this.selectedOrderId,
                                Category: this.value1,
                                recId: this.recordId,
                            })
                                .then(result => {
                                    if (result) {
                                        this.data = result;
                                        const event = new ShowToastEvent({
                                            title: 'Case Created ',
                                            variant: 'success',
                                            message: 'The case has been created successfully.'
                                        });
                                        this.dispatchEvent(event);
                                        this.dispatchEvent(new CloseActionScreenEvent());
                                        var BaseURl = this.CaseBaseURL;
                                        window.location.replace(this.CaseBaseURL + result.Id + '/view');
                                         
                                        this.dispatchEvent(new RefreshEvent());

                                    }
                                })
                                .catch(error => {
                                    this.error = error;
                                    console.log('error == >' + error);
                                });
                        } else {
                            const event = new ShowToastEvent({
                                title: 'Case Creation is Unsuccessful',
                                variant: 'error',
                                message: 'Please Fill the Category.'
                            });
                            this.dispatchEvent(event);
                        }
                    } else {
                        const event = new ShowToastEvent({
                            title: 'Case Creation is Unsuccessful',
                            variant: 'error',
                            message: 'Please Fill the Sub-Type.'
                        });
                        this.dispatchEvent(event);
                    }
                } else {
                    const event = new ShowToastEvent({
                        title: 'Case Creation is Unsuccessful',
                        variant: 'error',
                        message: 'Please Fill the Type.'
                    });
                    this.dispatchEvent(event);
                }
            } else {
                const event = new ShowToastEvent({
                    title: 'Case Creation is Unsuccessful',
                    variant: 'error',
                    message: 'Please Fill the Record type.'
                });
                this.dispatchEvent(event);
            }
        } catch (error) {
            console.error('check error here', error);
        }
    }
    
    

    handleLWCOrderLookUP(event) {
        debugger;
        this.selectedOrderId = event.detail.value;
    }
    
}