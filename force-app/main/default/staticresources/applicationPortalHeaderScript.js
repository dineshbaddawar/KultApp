var siteURL;
var app = angular.module('DashboardApp');
var sitePrefix = window.location.href.includes('/apex') ? '/apex' : '/ApplicationPortal';
app.config(function ($routeProvider, $locationProvider) { 
    debugger;
    $locationProvider.html5Mode(false).hashPrefix('');
    var rp = $routeProvider;

    for (var i = 0; i < tabValues.length; i++) {
        var pageName = '/' + tabValues[i].Name;

        if (tabValues[i].Apex_class_Name__c != undefined) {
            rp.when(pageName, {

                templateUrl: sitePrefix + pageName,
                controller: tabValues[i].Apex_class_Name__c
            });
        } else {
            rp.when(pageName, {
                templateUrl: sitePrefix + pageName,
            })
        }

    }
});

/*app.filter('specialChar',function(){
    return function(input)
    {
        return input ? input.replace(/&amp;/g,'&').replace(/&#39;/g,'\'').replaceAll('&amp;amp;','&').replaceAll('&amp;gt;','>').replaceAll('&lt;','<').replaceAll('lt;','<').replaceAll('&gt;','>').replaceAll('gt;','>').replaceAll('&amp;','&').replaceAll('amp;','&').replaceAll('&quot;','\'') : input;
    }
});*/

app.controller('DashboardCtlr', function ($scope, $rootScope, $timeout, $window, $location, $element){
    debugger;
    $scope.config = {};
    $rootScope.userDetails;
    $rootScope.activeTab = 0;
    //$rootScope.siteURL = siteURL;

    $scope.baseUrl = window.origin; 

});