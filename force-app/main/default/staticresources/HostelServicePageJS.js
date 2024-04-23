angular.module('DashboardApp').controller('HostelCtlr', function($scope,$rootScope,$timeout) {
    
    /*$scope.HostelSercies = true;
    $scope.HostelDetails = false;
    
    $scope.checkAvailabilityHostel = function(){
        debugger;
        $scope.HostelSercies = false;
        $scope.HostelDetails = true;
    };
    
    $scope.back = function(){
        debugger;
        $scope.HostelSercies = true;
        $scope.HostelDetails = false;
    };
    
    $scope.CloseSuccessfullyCard = function(){
        debugger;
        $scope.SuccessfulCard = true;
    }*/
    $scope.hostels = []; 
    
    $scope.getHostelInfo = function() {
        debugger;
        applicationPortalController.getHostelInfo(function(result) {
            $scope.hostels = result;
            $scope.$apply();
        });
    };
    
    $scope.getHostelInfo();
});