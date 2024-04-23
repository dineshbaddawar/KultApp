angular.module('DashboardApp').controller('contactUsCtrl', function($scope,$rootScope){
    // var app = angular.module('contactUsApp', []);
    // app.controller('contactUsCtrl',function($scope){
    $scope.showWriteToUs = false;
    $scope.contactUs = [];
    $scope.writeToUs = [];
    $scope.oppId = '006F600000DGGgoIAH';
    
    $scope.toggleWriteToUs = function(){
        $scope.showWriteToUs = !$scope.showWriteToUs;
    };
    
    
    
    $scope.handleSubmit = function(){
        debugger;        
        var myModal = new bootstrap.Modal(document.getElementById('filePreview'))        
        myModal.show('slow') ;
        applicationPortalController.createCase(
            $scope.contactId,
            $scope.writeToUs.Campus,
            $scope.writeToUs.selectedGrade,
            $scope.writeToUs.Message__c,
            function (result, event) {
                if (event.status && result) {
                    $scope.handleCreateCaseResponse(result);
                } else {
                    console.error('Error creating case:', event.message);
                    $scope.handleCreateCaseError(event.message);
                }
                $scope.$apply();
            }
        );
    };
    
    
    $scope.getContactUsData = function(){
        applicationPortalController.getContactUs(function(result, event){
            if(event.status && result){
                $scope.contactUs = result;
                $scope.$apply();
            }
            else {
                console.error('Error fetching values:', event.message);
            }
        });
    };
    $scope.getContactUsData();
    
    $scope.getWriteToUsData = function(){
        debugger;
        applicationPortalController.getWriteToUs($scope.oppId, function(result, event){
            if(event.status && result){
                $scope.writeToUs = result[0];
                $scope.contactId = result[0].Id;
                $scope.$apply();
            }
            else {
                console.error('Error fetching values:', event.message);
            }
        });
    };
    $scope.getWriteToUsData();
    
    $scope.getPicklistData = function(){
        debugger;
        applicationPortalController.getPicklistValues('Contact', 'Presently_Studying_in_Grade__c', function(result, event){
            if(event.status && result){
                $scope.presentlyStudyingGradePicklistValues = result; // Assuming you want to store the picklist values in a variable
                $scope.$apply();
            }
            else {
                console.error('Error fetching values:', event.message);
            }
        });
    };
    $scope.getPicklistData();
    
    $scope.getPicklistData = function(){
        debugger;
        applicationPortalController.getPicklistValues('Contact', 'Campus__c', function(result, event){
            if(event.status && result){
                $scope.campus = result; // Assuming you want to store the picklist values in a variable
                $scope.$apply();
            }
            else {
                console.error('Error fetching values:', event.message);
            }
        });
    };
    $scope.getPicklistData();
    
    $scope.createCase = function () {
        debugger;
        applicationPortalController.createCase(
            $scope.writeToUs.contactId,
            $scope.writeToUs.Campus__c,
            $scope.writeToUs.selectedGrade,
            $scope.writeToUs.Message__c,
            function (result, event) {
                if (event.status && result) {
                    $scope.handleCreateCaseResponse(result);
                } else {
                    $scope.handleCreateCaseError(event.message);
                }
                $scope.$apply();
            }
        );
    };
    
});
