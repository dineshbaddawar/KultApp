var skillList = [];
var staffList = [];

var app = angular.module('LoginApp', []);
app.controller('LoginCtlr', function ($scope) {
    //debugger;    
    $scope.showSpinner = false; 
    //  $scope.userName =   'vaibhav.chauhan@utilitarianlabs.com';
    $scope.userPassword;
    $scope.userName;
    $scope.userPassword = 'test@123';
    $scope.NewuserPassword;
    $scope.currentpageHashcode;
    $scope.registrationPage = false;
    $scope.isRegistration = false;
    $scope.contactDetails = { FirstName: "", LastName: "", Email: "", Phone: "+91"};
    $scope.verifyEmail ;
    $scope.contactDetails.FirstName = "";
    $scope.refralId = "";
    $scope.contactDetails.Email = "";
    $scope.disableEmail = false;
    if($scope.contactDetails.Email != undefined && $scope.contactDetails.Email.includes("@")){
        $scope.disableEmail = true;
    }
    $scope.forgotPassword = true;
    $scope.forgotPass = function () {
        debugger;
        $scope.forgotPassword = !$scope.forgotPassword;
    };
    
	$scope.isCancel = false;
    $scope.cancel = function(){
        $scope.isCancel = !$scope.isCancel;
    };
    
    
    $scope.loginUser = function () {
        debugger;
        $scope.showSpinner = true;
            
            applicationPortalController.loginUser($scope.userName, $scope.userPassword, function (result, event) {
                if (event.status && result != null) {
                    $scope.Profile = result;
                    $scope.hashcodeId = $scope.Profile.Login_Hash_Code__c;
                    $scope.userLoggedIn = true;
                    Swal.fire(
                        '',
                        'LoggedIn Successfully!',
                        'success'
                    )
                    $scope.$apply();
                    debugger;
                    var sitePrefix = window.location.href.includes('/apex') ? '/apex' : '/ApplicationPortal';
                            debugger;
                            window.location.replace(window.location.origin + sitePrefix + '/applicationPortalHeader?id=' + result.Login_Hash_Code__c +'#/applicationPortalDashboard');
                    // window.location.replace(siteUrl+"applicationPortalHeader");
                    //window.location.replace(window.location.origin + "/applicationPortalHeader" )
                    //window.location.replace(siteUrl+"applicationPortalHeader?hc=" + $scope.Profile.Login_Hash_Code__c+'#/CP_HomePage');
                }
                else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Oops...',
                        text: 'Please enter the correct Username and Password!'
                    })
                }
            }, { escape: false })
            
        $scope.showSpinner = false;
        $scope.$apply();    
        
        
    }
    
    $scope.changePasswordType= function(){
        debugger;
        if(document.getElementById("password").type == "text"){
         document.getElementById("password").type="password";   
        }else if(document.getElementById("password").type == "password"){
         document.getElementById("password").type="text";   
        }
    }
    
    $scope.checkForEmail = function () {
        debugger;
        $scope.showSpinner = true;
        applicationPortalController.verifyEmail($scope.userName ,function(result,event){
            if(event.status){
                debugger;
              if(result != null){
                Swal.fire(
                    '',
                    'Password reset link sent to your registered Email Successfully!',
                    'success'
                  );
                $("#staticBackdrop").hide();
                  $(".modal-backdrop").hide();
              }else{
                  Swal.fire(
                    '',
                    'Please enter correct Email Id!',
                    'error'
                  );
                $("#staticBackdrop").hide();
                $(".modal-backdrop").hide();
              }
            }
            else{
              Swal.fire(
                    '',
                    'Something Went Wrong!',
                    'error'
                  );
                $("#staticBackdrop").hide();
                $(".modal-backdrop").hide();
            }
        },{escape:false})
        $scope.showSpinner = false;
    }


    $scope.resetPassword = function () {
        debugger;
        var currentURL = window.location.href;
        const urlObj = new URL(currentURL);
        // Get the value of the 'id' parameter
        $scope.currentpageHashcode = urlObj.searchParams.get('id');
        
        $scope.showSpinner = true;
        applicationPortalController.updateContactPassword($scope.currentpageHashcode,$scope.NewuserPassword,function(result,event){
            if(event.status){
                debugger;
              if(result != null){
                Swal.fire(
                    '',
                    'Password Reset Successfully!',
                    'success'
                );
                  window.location.replace('https://united-world-academy--uwasandbox.sandbox.my.salesforce-sites.com/ApplicationPortal');
                $("#staticBackdrop").hide();
                $(".modal-backdrop").hide();
              }else{
                  Swal.fire(
                    '',
                    'Please enter correct password!',
                    'error'
                  );
                $("#staticBackdrop").hide();
                $(".modal-backdrop").hide();
              }
            }
            else{
              Swal.fire(
                    '',
                    'Something Went Wrong!',
                    'error'
                  );
                $("#staticBackdrop").hide();
                $(".modal-backdrop").hide();
            }
        },{escape:false})
        $scope.showSpinner = false;
    }

    $scope.backToLogInPage = function () {
        debugger;
        window.location.replace('https://united-world-academy--uwasandbox.sandbox.my.salesforce-sites.com/ApplicationPortal');
    }
    
});