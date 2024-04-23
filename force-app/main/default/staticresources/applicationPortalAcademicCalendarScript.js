angular.module('DashboardApp').controller('CalendarCtlr', function($scope,$rootScope,$timeout,$window) {
    $scope.pdfContent = null;
    
    $scope.initiateComponent = function(){
        debugger;
         applicationPortalController.getCalendarPdf(function (result, event) {
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
                $scope.pdfContentToPreview = $sce.trustAsResourceUrl(URL.createObjectURL(blob));
    }
             $scope.$apply();
         });
    }
    $scope.initiateComponent();
    
    $scope.downloadAcademicCalendar = function () {
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
    };
});
