angular.module('DashboardApp').controller('applicationCtlr', function ($scope, $rootScope, $timeout, $window) {
    $scope.hashCode;
    
    debugger;
    var url = window.location.href.toString();
        const queryParams = url.split("&");
        const recordIdParam = queryParams.find(param => param.includes("id"));
        const recordIdKeyValue = recordIdParam.split("=");
        const recordId = recordIdKeyValue.pop().split("#")[0];
        $scope.hashCode = recordId;

    $scope.openApplication = true;
    $scope.closeApplication = false;
    
    $scope.application = {
        "First_Name__c": "",
        "Last_Name__c": ""
    };

    $scope.motherData = {
        "First_Name__c": "",
        "Last_Name__c": ""
    };
    $scope.fatherData = {
        "First_Name__c": "",
        "Last_Name__c": ""
    };

    $scope.emergencyInformation = {
        "First_Name__c": "",
        "Last_Name__c": ""
    };
    $scope.siblingInformation = {
        "First_Name__c": "",
        "Last_Name__c": ""
    };
    $scope.additionalInformation = {
        "Hobbies__c": ""
    };
    $scope.DateData = {
        "First_Name__c": "",
        "Last_Name__c": ""
    };

    $scope.pickListValue = [];
    $scope.pickListValueEduQualification = [];
    
    $scope.showApplications = true;
    $scope.showApplicantDetails = false;

    $scope.objApiNmae = 'Sibling_Information__c';
    $scope.fieldName = 'Enrollment_Status__c';

    $scope.objApiNmae1 = 'Related_Contact__c';
    $scope.fieldName1 = 'Educational_Qualification__c';

    $scope.applicationInserted;
    $scope.stringifyDob;
    $scope.listOfOpenApplication = [];
    $scope.listOfClosedApplication = [];
    $scope.listOfApplicationDocument = [];
    $scope.currentDocumentId;

    var maxStringSize = 6000000;    //Maximum String size is 6,000,000 characters 6 MB
    var maxFileSize = 4350000;      //After Base64 Encoding, this is the max file size
    var chunkSize = 950000;         //Maximum Javascript Remoting message size is 1,000,000 characters
    var attachment;
    var attachmentName;
    var fileSize;
    $scope.files = [];


    $scope.init = function () {
        debugger;
        applicationPortalController.getAllApplication(function (result, event) {
            if (event.status && result) {
                debugger;
                $scope.listOfOpenApplication = result.getOpenApplication;
                $scope.listOfClosedApplication = result.getClosedApplication;
            }
            $scope.$apply();
        })
     }
    $scope.init();
    
    $scope.getQulificationEduction = function () {
        debugger;
        applicationPortalController.getPickListValuesMethod($scope.objApiNmae1, $scope.fieldName1, function (result, event) {
            debugger;
            if(event.status && result !=null){
              debugger;
              $scope.pickListValueEduQualification = result;
            }
            $scope.$apply();
          })
    }
    
    $scope.toggleAndSubmit = function(){
        debugger;
        $scope.showApplicantDetails  =!$scope.showApplicantDetails;
        $scope.showApplications = !$scope.showApplications;
    }
    
    $scope.showApplication = function(){
        debugger;
        $scope.showApplicantDetails  =!$scope.showApplicantDetails;
        $scope.showApplications = !$scope.showApplications;
    }
    
    $scope.NewApplicationForm = function(){
        debugger;
        $scope.showApplicantDetails = true;
        $scope.showApplications = false;
        applicationPortalController.getPickListValuesMethod($scope.objApiNmae, $scope.fieldName, function (result, event) {
            debugger;
            if (event.status && result != null) {
                debugger;
                $scope.pickListValue = result;
            }
            $scope.$apply();
        });
        $scope.getQulificationEduction();
    };

   // For Date Of Birth
    $scope.myFunc = function() {
        debugger;
        var dob = $scope.DateData.Date_Of_Birth__c;
        $scope.stringifyDob = JSON.stringify(dob);
    };

    // Method for Storing Application record
    $scope.saveandNextSection1 = function () {
        // $scope.showApplicantDetailsSection2 = true;
        // $scope.showApplicantDetails = false;
        debugger;
        if ($scope.stringifyDob == undefined) {
            $scope.stringifyDob = $scope.application.DateData;
            if ($scope.stringifyDob == undefined) {
                $scope.stringifyDob =  'null';
            }
        } 
        applicationPortalController.createApplicationRecord($scope.application,$scope.stringifyDob, $scope.hashCode, function (result, event) {
            debugger;
            if (event.status && result) {
                $scope.applicationInserted = result;
                Swal.fire(
                    '',
                    'Application Details Saved Successfully!',
                    'success'
                )
                $scope.$apply();
                $scope.showApplicantDetailsSection2 = true;
                $scope.showApplicantDetails = false;
            } else {
                alert('Error Submitting Application:', event.message);
            }
            $scope.$apply();
        });
    };

    $scope.SaveAsDraftSection1 = function () {
        debugger;
        alert('Save as Draft Section 1')
    },
        
    $scope.SaveAsDraftSection2 = function () {
        debugger;
        alert('Save as Draft Section 2')
    },
        
        // Method for Creating Mother Record
        $scope.saveandNextSection2 = function () {
        debugger;
        // $scope.showApplicantDetailsSection2 = false;
        // $scope.showApplicantDetailsSection3 = true;
            applicationPortalController.createRelatedContactMotherRecord($scope.motherData,$scope.applicationInserted.Id, function (result, event) {
                debugger;
                if (event.status && result) {
                    Swal.fire(
                        '',
                        'Mother Details Saved Successfully!',
                        'success'
                    )
                    $scope.$apply();
                    $scope.showApplicantDetailsSection2 = false;
                    $scope.showApplicantDetailsSection3 = true;
                } else {
                    alert('Error Submitting Application:', event.message);
                }
                $scope.$apply();
            });
        };
    
      // Method for Creating Father Record
    $scope.saveandNextSection3 = function () {
        debugger;
        // $scope.showApplicantDetailsSection3 = false;
        // $scope.showApplicantDetailsSection4 = true;
        applicationPortalController.createRelatedContactFatherRecord($scope.fatherData,$scope.applicationInserted.Id, function (result, event) {
            debugger;
            if (event.status && result) {
                Swal.fire(
                    '',
                    'Father Details Saved Successfully!',
                    'success'
                )
                $scope.$apply();
                $scope.showApplicantDetailsSection3 = false;
                $scope.showApplicantDetailsSection4 = true;
            } else {
                alert('Error Submitting Application:', event.message);
            }
            $scope.$apply();
        });
    };
        
    // Method for Creating Emergency Contact Record
        $scope.saveandNextSection4 = function () {
            debugger;
            // $scope.showApplicantDetailsSection4 = false;
            // $scope.showApplicantDetailsSection5 = true;
            applicationPortalController.createRelatedContactEmergencyContactRecord($scope.emergencyInformation,$scope.applicationInserted.Id, function (result, event) {
                debugger;
                if (event.status && result) {
                    Swal.fire(
                        '',
                        'Emergency Contact Details Saved Successfully!',
                        'success'
                    )
                    $scope.$apply();
                    $scope.showApplicantDetailsSection4 = false;
                    $scope.showApplicantDetailsSection5 = true;
                } else {
                    alert('Error Submitting Application:', event.message);
                }
                $scope.$apply();
            });
        };
    
    // Method for Creating Sibling Record Record
    $scope.saveandNextSection5 = function () {
        debugger;
        // $scope.showApplicantDetailsSection5 = false;
        // $scope.showApplicantDetailsSection6 = true;
        applicationPortalController.createRelatedSiblingInformationRecord($scope.siblingInformation,$scope.applicationInserted.Id, function (result, event) {
            debugger;
            if (event.status && result) {
                Swal.fire(
                    '',
                    'Sibling Details Saved Successfully!',
                    'success'
                )
                $scope.$apply();
                $scope.showApplicantDetailsSection5 = false;
                $scope.showApplicantDetailsSection6 = true;
            } else {
                alert('Error Submitting Sibling:', event.message);
            }
            $scope.$apply();
        });
    };

    $scope.saveandNextSection6 = function () {
        debugger;
        // $scope.showApplicantDetailsSection6 = false;
        // $scope.showApplicantDetailsSection7 = true;

        applicationPortalController.getAllApplicationRelatedDoc( function (result, event) {
            debugger;
            if (event.status && result) {
                $scope.listOfApplicationDocument = result;
                // $scope.showApplicantDetailsSection5 = false;
                // $scope.showApplicantDetailsSection6 = true;
            } else {
               // alert('Error Submitting Sibling:', event.message);
            }
            $scope.$apply();
        });
    }

    // Method for Saved Additional Details
    $scope.saveandNextSectionAdditionalDetails = function () {
        debugger;
        var recordIdApplication = 'a00F600000C6gFNIAZ';
        applicationPortalController.additionalInformationForApplicatonRecord($scope.additionalInformation,recordIdApplication, function (result, event) {
            debugger;
            if (event.status && result) {
                Swal.fire(
                    '',
                    'Additional Details Saved Successfully!',
                    'success'
                )
                $scope.$apply();
                $scope.showApplicantDetailsSection6 = false;
                $scope.showApplicantDetailsSection7 = true;
                $scope.saveandNextSection6();
            } else {
                alert('Error Submitting Sibling:', event.message);
            }
            $scope.$apply();
        });
    }

    $scope.EditDraftApplication = function (recordId) {
        debugger;
        console.log("Select Application record ID:", recordId);
        applicationPortalController.getApplicationDetails(recordId, function (result, event) {
            debugger;
            if (event.status && result) {
                $scope.application = result;
                if(result.Date_Of_Birth__c!=undefined && result.Date_Of_Birth__c!=''){
                    $scope.DateData.Date_Of_Birth__c=new Date(result.Date_Of_Birth__c);
                  }
                $scope.showApplicantDetails = true;
                $scope.showApplications = false;
            } else {
                alert('Error Submitting Sibling:', event.message);
            }
            $scope.$apply();
        });
    }
    
    $scope.geClosedApplication = function () {
        debugger;
        $scope.openApplication = false;
        $scope.closeApplication = true;
        const tabs = document.querySelectorAll('.nav-link');
        tabs.forEach(tab => tab.classList.remove('active'));
        // Add 'active' class to the clicked tab
        event.target.classList.add('active');
        // Add 'highlight' class to the clicked tab
        tabs.forEach(tab => tab.classList.remove('highlight'));
        event.target.classList.add('highlight');
    }

    $scope.geOpenApplication = function () {
        debugger;
        $scope.openApplication = true;
        $scope.closeApplication = false;
        const tabs = document.querySelectorAll('.nav-link');
        tabs.forEach(tab => tab.classList.remove('active'));
        // Add 'active' class to the clicked tab
        event.target.classList.add('active');
        // Add 'highlight' class to the clicked tab
        tabs.forEach(tab => tab.classList.remove('highlight'));
        event.target.classList.add('highlight');
    }

    $scope.documentClick = function () {
        debugger;

      //  $scope.showUploadFileImmunization = true;
    }

    $scope.uploadDocApplication = function (recordId) {
        debugger;
       $scope.currentDocumentId = recordId;
        $scope.showApplicantDetailsSection8 = true;
        $scope.showApplicantDetailsSection7 = false;
    }

    $scope.setUserDocId=function(){
        debugger;
        var file = document.getElementById('attachmentFiles').files[0];
        var parentIdDocId = $scope.currentDocumentId;
        if (file != undefined) {
            if (file.size <= maxFileSize) {
                attachmentName = file.name;
                fileChoosen = file.name;
                const myArr = attachmentName.split(".");
                if($scope.selectedDocName != undefined){
                    attachmentName = $scope.selectedDocName+".pdf";
                }
                var fileReader = new FileReader();
                fileReader.onloadend = function (e) {
                    attachment = window.btoa(this.result);  
                    positionIndex = 0;
                    fileSize = attachment.length;
                    doneUploading = false;
                    var fileId='';
                    if (fileSize < maxStringSize) {
                        $scope.uploadAttachment(parentIdDocId); 
                    } else {
                        alert("Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".");
                    }
                }
                fileReader.onerror = function (e) {
                    alert("There was an error reading the file.  Please try again.");
                }
                fileReader.onabort = function (e) {
                    alert("There was an error reading the file.  Please try again.");
                }
                fileReader.readAsBinaryString(file); 
                
            } else {
                alert("File must be under 4.3 MB in size.  Your file is too large.  Please try again.");
            }
        } else {
            alert("You must choose a file before trying to upload it");
        }
    }

    $scope.uploadAttachment = function (parentIdDocId) {
        debugger;
        var attachmentBody = "";
        if (fileSize <= positionIndex + chunkSize) {
            attachmentBody = attachment.substring(positionIndex);
            doneUploading = true;
        } else {
            attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
        }
        console.log("Uploading ==> " + attachmentBody.length + " &&  chars of  == >" + fileSize);
        applicationPortalController.insertedDocAttachement(attachmentBody, attachmentName, parentIdDocId, function (result, event) {
            debugger;
           if (event.status && result !=null) {
                    Swal.fire(
                        '',
                        'Uploaded Successfully!',
                        'success'
                    )
                    $scope.showApplicantDetailsSection7 = true;
               $scope.showApplicantDetailsSection8 = false;
               $scope.closeDocUploadModal();
            //     $("#fileUploadModel").modal('hide');
            //    $("#resumeUploadModel").modal('hide');
              
            } 
                else {
                    console.log(event.message);
                }
        }, { buffer: true, escape: true, timeout: 120000 });
    }


    $scope.closeDocUploadModal = function () {
        debugger;
        document.getElementById('attachmentFiles').value = "";
        $scope.saveandNextSection6();
    }
    
});