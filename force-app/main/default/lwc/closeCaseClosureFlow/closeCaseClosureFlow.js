import { LightningElement, api } from 'lwc';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
export default class CloseCaseClosureFlow extends LightningElement {
    @api caseId;
    @api availableActions = [];




    connectedCallback() {
        debugger;
        this.closeModal();
    }
    handleSuccess() {
        this.handleRefresh();
        this.NavigateToRecord();
    }

    handleRefresh() {
        if (this.availableActions.find((action) => action === 'FINISH')) {
            const navigateNextEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    closeModal() {
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    NavigateToRecord() {
        //write your own js logic to navigate in a new tab
    }
}