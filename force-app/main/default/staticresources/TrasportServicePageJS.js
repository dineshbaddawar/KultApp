angular.module('DashboardApp').controller('TransportCtlr', function($scope,$rootScope,$timeout){
    
    /*$scope.TransportSercies = true;
    $scope.TransportDetails = false;
    
    $scope.checkAvailabilityTrasportService = function(){
        debugger;
        $scope.TransportSercies = false;
        $scope.TransportDetails = true;
    };
    
    $scope.back = function(){
        debugger;
        $scope.TransportSercies = true;
        $scope.TransportDetails = false;
    };
    
    $scope.CloseSuccessfullyCard = function(){
        debugger;
        $scope.SuccessfulCard = true;
    }*/
    $scope.transports = []; 
    
    $scope.getTransportInfo = function() {
        debugger;
        applicationPortalController.getTransportInfo(function(result) {
            $scope.transports = result;
            $scope.$apply();
        });
    };
    
    $scope.getTransportInfo();
});