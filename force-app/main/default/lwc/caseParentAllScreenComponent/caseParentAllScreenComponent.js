import { LightningElement, api, track } from 'lwc';
import getCaseRecordDetails from '@salesforce/apex/CaseHelperController.getCaseRecordDetails';
import getCaseDetails from '@salesforce/apex/CaseHelperController.getCaseDetails';
import brandLogo from '@salesforce/resourceUrl/brandLogo';
import campaignLogo from '@salesforce/resourceUrl/campaignLogo';
import contentLogo from '@salesforce/resourceUrl/contentLogo';
import faqLogo from '@salesforce/resourceUrl/faqLogo';
import marketingLogo from '@salesforce/resourceUrl/marketingLogo';
import Moneybag2 from '@salesforce/resourceUrl/Moneybag2';
import OrderBox from '@salesforce/resourceUrl/OrderBox';
import orderLogo from '@salesforce/resourceUrl/orderLogo';
import perfumeLogo from '@salesforce/resourceUrl/perfumeLogo';
import preOrderLogo from '@salesforce/resourceUrl/preOrderLogo';
import pricingLogo from '@salesforce/resourceUrl/pricingLogo';
import queryLogo from '@salesforce/resourceUrl/queryLogo';
import serRelLogo from '@salesforce/resourceUrl/serRelLogo';
import techLogo from '@salesforce/resourceUrl/techLogo';
import userLogo from '@salesforce/resourceUrl/userLogo';
export default class CaseParentAllScreenComponent extends LightningElement {

      @api recordId;
      @track caseDetails;
      data;
      error;

      isBrandRecordType = false;
      isCampaignReviewRecordType = false;
      isContentRecordType = false;
      isCustomerProfileRecordType = false;
      isGeneralQueryRecordType = false;
      isMarketingRecordType = false;
      isOrderRecordType = false;
      isOrderRelatedIssues = false;
      isPerfumeCategoryRecordType = false;
      isPolicyFAQRecordType = false;
      isPreOrderRecordType = false;
      isPricingRecordType = false;
      isRefundRecordType = false;
      isServiceRealtedRecordType = false;
      isTechRecordType = false;

      refundReason;
      orderNumber;
      accountName;
      caseOrigin;
      caseType;
      @track CaseIsNotNull = false;
      @track subType;
      @track subSubType;
      @track isshowRefund = false;

      //importing image from static resource n passing to variable in html
      brandLogo = brandLogo;
      campaignLogo = campaignLogo;
      contentLogo = contentLogo;
      faqLogo = faqLogo;
      marketingLogo = marketingLogo;
      moneybag2 = Moneybag2;
      OrderBox = OrderBox;
      orderLogo = orderLogo;
      perfumeLogo = perfumeLogo;
      preOrderLogo = preOrderLogo;
      pricingLogo = pricingLogo;
      queryLogo = queryLogo;
      serRelLogo = serRelLogo;
      techLogo = techLogo;
      userLogo = userLogo;



      connectedCallback() {
            debugger;
            setTimeout(() => {
                  this.callCaseMethod();
                  this.getCardDetails();
            }, 300);
      }

      getCardDetails() {
            debugger;
            getCaseDetails({ recId: this.recordId })
                  .then(result => {
                        console.log('Result from refund Issues ===>', result);
                        if (result) {

                              this.caseDetails = result;


                              if (this.caseDetails.Refund_Reason__c == null || this.caseDetails.Refund_Reason__c == undefined || this.caseDetails.Refund_Reason__c == '') {
                                    this.refundReason = '-';
                              } else {
                                    this.refundReason = this.caseDetails.Refund_Reason__c;
                              }
                              if (this.caseDetails.Case_Sub_Status__c == null || this.caseDetails.Case_Sub_Status__c == undefined || this.caseDetails.Case_Sub_Status__c == '') {
                                    this.caseSubStatus = '-';
                              } else {
                                    this.caseSubStatus = this.caseDetails.Case_Sub_Status__c;
                              }
                              if (this.caseDetails.OrderId__c == null || this.caseDetails.OrderId__c == undefined || this.caseDetails.OrderId__c == '') {
                                    this.orderNumber = '-';
                              } else {
                                    this.orderNumber = this.caseDetails.OrderId__r.OrderNumber;
                              }
                              if (this.caseDetails.Origin == null || this.caseDetails.Origin == undefined || this.caseDetails.Origin == '') {
                                    this.caseOrigin = '-';
                              } else {
                                    this.caseOrigin = this.caseDetails.Origin;
                              }
                              if (this.caseDetails.AccountId == null || this.caseDetails.AccountId == undefined || this.caseDetails.AccountId == '')  {
                                    this.accountName = '-';
                              } else {
                                    this.accountName = this.caseDetails.Account.Name;
                              }
                              if (this.caseDetails.Type == null || this.caseDetails.Type == undefined || this.caseDetails.Type == '') {
                                    this.caseDetails.Type = '-';
                              } else {
                                    this.caseDetails.Type = this.caseDetails.Type;
                              }
                              if (this.caseDetails.Sub_Type__c == null || this.caseDetails.Sub_Type__c == undefined || this.caseDetails.Sub_Type__c == '') {
                                    this.caseDetails.Sub_Type__c = '-';
                              } else {
                                    this.subType = this.caseDetails.Sub_Type__c;
                              }
                              if (this.caseDetails.Sub_Sub_Type__c == null || this.caseDetails.Sub_Sub_Type__c == undefined || this.caseDetails.Sub_Sub_Type__c == '') {
                                    this.caseDetails.Sub_Sub_Type__c = '-';
                              } else {
                                    this.subSubType = this.caseDetails.Sub_Sub_Type__c;
                              }
                              if (this.subType == 'Refund Issues' && this.subSubType == 'Refund Issues') {
                                    this.isshowRefund = true;
                              }
                              if (this.caseDetails.Type_Of_Case__c != null && this.caseDetails.Type_Of_Case__c != undefined && this.caseDetails.Type_Of_Case__c != '') {
                                    this.caseType = this.caseDetails.Type_Of_Case__c;
                                    this.CaseIsNotNull = true;
                              }
                        }
                  })
                  .catch(error => {
                        this.error = error;
                  })

      }



      callCaseMethod() {
            debugger;
            getCaseRecordDetails({ recordId: this.recordId })
                  .then(result => {
                        if (result) {
                              if (result != null) {
                                    this.data = result;
                                    if (this.data.RecordType.Name == 'Tech') {
                                          this.isTechRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Brand') {
                                          this.isBrandRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Campaign /Reviews') {
                                          this.isCampaignReviewRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Content') {
                                          this.isContentRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Customer Profile') {
                                          this.isCustomerProfileRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'General Queries') {
                                          this.isGeneralQueryRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Marketing') {
                                          this.isMarketingRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Order Related') {
                                          this.isOrderRelatedIssues = true;
                                    }
                                    if (this.data.RecordType.Name == 'Pricing') {
                                          this.isPricingRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Policies and FAQs') {
                                          this.isPolicyFAQRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Pre Order') {
                                          this.isPreOrderRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Perfume - category') {
                                          this.isPerfumeCategoryRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Service Related') {
                                          this.isServiceRealtedRecordType = true;
                                    }
                                    if (this.data.RecordType.Name == 'Refund') {
                                          this.isRefundRecordType = true;
                                    }
                              }
                        }
                  })
                  .catch(error => {
                        this.error = error;
                  })
      }
}