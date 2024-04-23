import { LightningElement,wire,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getAllProfileNames from '@salesforce/apex/CaseHelperController.getAllProfileNames';
import getUsersBasedOnSelectedProfile from '@salesforce/apex/CaseHelperController.getUsersBasedOnSelectedProfile';
import shareCaseRecordWithSelectedUser from '@salesforce/apex/CaseHelperController.shareCaseRecordWithSelectedUser';
export default class SelectMemberComponent extends LightningElement {
@api recordId;
@track userId;
@track options = [];
@track userOptions = [];
@track selectedProfile;
@track value = '';
@track items = [];

@wire(getAllProfileNames)
wiredProfiles({error,data}){
if(data){
    this.options = data.map(profile => ({ label: profile, value: profile}))
}
else if(error){
    console.error('Error Fetching profiles',error);
}
}

handleProfileChange(event) {
debugger;
this.selectedProfile = event.detail.value;
    if(this.selectedProfile != undefined){
        this.userOptions = [];
        this.getAllusers();
    }
}

    getAllusers() {
        debugger;
    getUsersBasedOnSelectedProfile({profileName:this.selectedProfile})
    .then((result) => {
        for(let i=0; i<result.length; i++) {
              console.log('id=' + result[i].Id);
              this.userOptions = [...this.userOptions ,{value: result[i].Id , label: result[i].Name}];                                   
              }  
      })
      .catch((error) => {
        this.error = error;
      });
}

handleUserChange(event) {
debugger;
this.userId = event.detail.value;
}

handleSubmit(){
debugger;
shareCaseRecordWithSelectedUser({recordId:this.recordId,userOrGroupId:this.userId})
.then((result) => {
  if(result){
      if (result == 'SUCCESS') {
          this.showToast();
      }
      if (result == 'ERROR') {
          this.showErrorToast();
      }
  }
    
}).catch((err) => {
    
});

}

handleCancel(){
debugger;
this.closequickaction = true;
this.dispatchEvent(new CloseActionScreenEvent());
}
    
showToast() {
    const event = new ShowToastEvent({
        title: 'SUCCESS',
        message: 'Case Record Shared Successfully!',
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(event);
    this.handleCancel();
}
    
showErrorToast() {
    const evt = new ShowToastEvent({
        title: 'ERROR',
        message: 'Something Went Wrong !',
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
    this.handleCancel();
}

}