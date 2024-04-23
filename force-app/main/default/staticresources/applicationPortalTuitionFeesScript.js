angular.module('DashboardApp').controller('feeCtrl', function($scope,$rootScope,$timeout,$window) {
    
    debugger;

    $scope.grades = []; 
    
    $scope.getGradeInfo = function() {
        debugger;
        applicationPortalController.getGradeInfo(function(result) {
            $scope.grades = result;
            $scope.$apply();
        });
    };
    $scope.getGradeInfo();
    
    
    $scope.pdfContent = null;
    $scope.initiateComponent = function(){
        debugger;
        applicationPortalController.getFeePdf(function (result, event) {
            if (event.status && result) {
                // Decode Base64 string
                var decodedData = atob(result);
                
                // Convert decoded data to Uint8Array
                var uint8Array = new Uint8Array(decodedData.length);
                for (var i = 0; i < decodedData.length; i++) {
                    uint8Array[i] = decodedData.charCodeAt(i);
                }
                
                // Create Blob
                var blob = new Blob([uint8Array], { type: 'application/pdf' });
                
                // Set the PDF content to be displayed
             //   $scope.pdfContentToPreview = $sce.trustAsResourceUrl(URL.createObjectURL(blob));
            }
            $scope.$apply();
        });
    }
    $scope.initiateComponent();


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
    
    
    $scope.downloadPdf = function () {
        debugger;
        applicationPortalController.getFeePdf(function (result, event) {
            if (event.status && result) {
                // Decode Base64 string
                var decodedData = atob(result);
                
                // Convert decoded data to Uint8Array
                var uint8Array = new Uint8Array(decodedData.length);
                for (var i = 0; i < decodedData.length; i++) {
                    uint8Array[i] = decodedData.charCodeAt(i);
                }
                
                // Create Blob
                var blob = new Blob([uint8Array], { type: 'application/pdf' });
                
                // Set the PDF content to be displayed
                $scope.pdfContent = $sce.trustAsResourceUrl(URL.createObjectURL(blob));
                
                // Wait for a short delay before triggering the download
                setTimeout(function () {
                    var downloadLink = document.createElement('a');
                    downloadLink.href = $scope.pdfContent;
                    downloadLink.download = 'Academic_Calendar.pdf';
                    document.body.appendChild(downloadLink);
                    downloadLink.click();
                    document.body.removeChild(downloadLink);
                }, 100); // Adjust the delay as needed
            } else {
                console.error('Error fetching PDF content: ' + event.message);
            }
        });
    };

    $scope.downloadAcademicFessStruture = function () {
        debugger;
        debugger;
        applicationPortalController.getCalenderAcadmicId(function (result, event) {
            debugger;
            if (event.status && result) {
                var attachmentId =result
                // Dynamically construct the URL for the attachment
                var attachmentUrl = '/servlet/servlet.FileDownload?file=' + attachmentId;
                
                // Open a new window to initiate the download
                $window.open(attachmentUrl, '_blank');
            } else {
                console.error('Error fetching PDF content: ' + event.message);
            }
        });
    }
});
