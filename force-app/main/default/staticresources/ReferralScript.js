var app = angular.module('referralApp', []);
app.controller('referralCtrl',function($scope){
    $scope.LeadRecord = {"FirstName":"","LastName":""};
    $scope.conId = '003F600000r0gZhIAI';
    $scope.saveLeadData = function(){
        debugger;
        if($scope.LeadRecord.LastName == "" || $scope.LeadRecord.LastName == undefined){
            swal(
                'error',
                'Please fill Last Name.',
                'error'
            )
            return;
        }
        applicationPortalController.createLead($scope.LeadRecord,$scope.conId,function(result, event){
            debugger;
            if(event.status && result){
                swal(
                    'success',
                    'Your Details have been saved Successfully.',
                    'success'
                )
            }
            else {
                console.error('Error fetching values:', event.message);
            }
        });
    };
    
    $scope.getPicklistData = function(){
        debugger;
        applicationPortalController.getPicklistValues('Lead', 'Grade__c', function(result, event){
            if(event.status && result){
                $scope.Grade = result; 
                $scope.$apply();
            }
            else {
                console.error('Error fetching values:', event.message);
            }
        });
    };
    $scope.getPicklistData();
});