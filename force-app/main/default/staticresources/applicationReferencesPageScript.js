var app = angular.module('ApplicationApp', []);
app.controller('ApplicationCtlr', function($scope) {
    $scope.checkPaid =false;
    $scope.showFee = false;
    $scope.showSuccess = false;
    $scope.showMain = true;
    $scope.showSubmit = false;
    $scope.showPayNow = false;
    $scope.showDownloadMessage = false;
    //var leadId = '{!$CurrentPage.parameters.leadId}';
    $scope.leadId = '00QF6000007MhLUMA0';
    
    $scope.handleButton = function(){
        debugger;
        applicationPortalController.checkFeePaid($scope.leadId,function(result, event){
            if(event.status && result){
                $scope.checkPaid = result;
                if ($scope.checkPaid) {
                    $scope.showSubmit = !$scope.showSubmit;
                } 
            }
            else if(event.status && !result){
                $scope.checkPaid = !result;
                if ($scope.checkPaid){
                    $scope.showPayNow = !$scope.showPayNow;
                }
            }
                else{
                    console.log('Error checking fee paid:', event.message);
                }
            $scope.$apply();
        });
    };
    $scope.handleButton();
    
    $scope.handlePayNow = function(){
        debugger;
        applicationPortalController.checkFeePaid($scope.leadId,function(result, event){
            if(event.status && !result){
                $scope.checkPaid = !result;
                if ($scope.checkPaid){
                    $scope.showFee = !$scope.showFee; 
                    $scope.sendPaymentLink();
                }
            }else{
                console.log('Error checking fee paid:', event.message);
            }
        }); 
    };
    
    $scope.handleSubmit = function() {
        debugger;
        applicationPortalController.checkFeePaid($scope.leadId,function(result, event){
            if(event.status && result){
                $scope.checkPaid = result;
                if ($scope.checkPaid) {
                    $scope.showSuccess = !$scope.showSuccess;
                    $scope.showMain = !$scope.showMain;
                } 
            }else{
                console.log('Error checking fee paid:', event.message);
            }
            $scope.$apply();
        }); 
    };
    
    $scope.showDownload = function() {
        debugger;
        $scope.showDownloadMessage = !$scope.showDownloadMessage;
        $scope.showSuccess = !$scope.showSuccess;
    };
    
    $scope.sendPaymentLink = function() {
        debugger;
        applicationPortalController.sendPaymentLink($scope.leadId,function(result, event){
            if (result) {
                $scope.showMain = false;
            } else {
                console.log('Error sending payment link:', event.message);
            }
            $scope.$apply();
        });
    };
    
    $scope.CloseSuccessfullyCard = function() {
        debugger;
        $scope.showDownloadMessage = !$scope.showDownloadMessage; 
        $scope.showMain = !$scope.showMain;
    };
    
});