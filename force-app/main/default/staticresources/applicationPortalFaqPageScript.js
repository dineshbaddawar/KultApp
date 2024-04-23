//var app = angular.module('faq_app', []);
// var app = angular.module('DashboardApp');
 //angular.module('faq_app').controller('FaqCtlr',function($scope,$timeout){
angular.module('DashboardApp').controller('FaqCtlr', function($scope,$rootScope) {
    debugger;
    $scope.faqs = [];
    $scope.searchQuery = '';
    
    $scope.getFAQData = function(){
        debugger;
        applicationPortalController.getFaqs(function(result, event){
            if(event.status && result){
                $scope.faqs = result;
                $scope.$apply();
            }
        });
    }
    $scope.getFAQData();
    /*$timeout(function() {
        debugger;
        $scope.getFAQData();
    });*/
    
    $scope.filterFaqs = function (faq) {
        debugger;
        return !$scope.searchQuery || faq.Question__c.toLowerCase().includes($scope.searchQuery.toLowerCase());
    };
});

angular.module('DashboardApp').filter('highlight', function($sce) {
    debugger;
    return function(text, search) {
        if (search) {
            var regex = new RegExp(search, 'gi');
            text = text.replace(regex, function(match) {
                return '<span class="highlighted">' + match + '</span>';
            });
        }
        return $sce.trustAsHtml(text);
    };
});