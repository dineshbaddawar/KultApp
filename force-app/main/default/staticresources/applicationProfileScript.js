var app = angular.module('profileApp', []);
app.controller('profileCtlr', function($scope) {
    $scope.application = {
        "First_Name__c": "",
        "Last_Name__c": ""
    };
    $scope.DateData = {
        "First_Name__c": "",
        "Last_Name__c": ""
    };
    $scope.fatherData = {"First_Name__c": "","Last_Name__c": ""};
    $scope.motherData = {"First_Name__c": "","Last_Name__c": ""};
    $scope.emergencyInformation = {"First_Name__c": "","Last_Name__c": ""};
    $scope.siblingInformation = {"First_Name__c": "","Last_Name__c": ""};
    $scope.sibling2Information = {"First_Name__c": "","Last_Name__c": ""};
    $scope.strngfyDob;
    $scope.conId = '003F600000rAoyGIAS';
    $scope.draftData = [];
    
    $scope.handleSubmit = function() {
        debugger;
        applicationPortalController.submitApplication($scope.application,$scope.strngfyDob,$scope.fatherData,$scope.motherData,$scope.emergencyInformation,$scope.siblingInformation,$scope.sibling2Information, function(result, event) {
            debugger;
            if (event.status && result) {
                alert("Application Submitted Successfully:", result);
            } else {
                alert('Error Submitting Application:', event.message);
            }
            $scope.$apply();
        });
        
    };
    
    $scope.myFunc = function() {
        debugger;
        var dob = $scope.DateData.Date_Of_Birth__c;
        $scope.strngfyDob = JSON.stringify(dob);
    };
    
    $scope.getSaveAsDraft = function(){
        debugger;
        applicationPortalController.getApplicationAsDraft($scope.conId, function(result, event){
            if(event.status && result){
                $scope.draftData = result[0];
                $scope.$apply();
            }
            else {
                console.error('Error fetching values:', event.message);
            }
        });
    };
});
