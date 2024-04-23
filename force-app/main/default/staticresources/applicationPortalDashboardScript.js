angular.module('DashboardApp').controller('NotificationCtlr', function($scope,$rootScope){
    debugger;
    $scope.notifications = [];
    $scope.announcements = [];
    $scope.isNoticeVisible = {};
    $scope.isAnnouncementVisible = {};
    $scope.close = false;
    $scope.openAnnouncement = true;
    $scope.openNotice = true;
    $scope.conId = '003F600000r8d13IAA';
    
    $scope.currentDate = new Date();
    
    $scope.getNotificationData = function(){
        debugger;
        applicationPortalController.getNotification($scope.conId,function(result,event){
            if(event.status && result){
                $scope.notifications = result.NoticeNotifications.splice(0, 2);
                $scope.announcements = result.AnnouncementNotifications.splice(0, 2);
                $scope.$apply();
            }                                       
        })
    }
    $scope.getNotificationData();
    
    $scope.getAllNotificationData = function(){
        debugger;
        applicationPortalController.getNotification($scope.conId,function(result,event){
            if(event.status && result){
                $scope.allNotifications = result.NoticeNotifications; //use result.NoticeNotifications.splice(0, 2); for showing only two data
                $scope.allAnnouncements = result.AnnouncementNotifications;
                $scope.$apply();
            }                                       
        })
    }
   $scope.getAllNotificationData();    
    
    
    $scope.toggleNotice = function (descriptionId) {
        $scope.isNoticeVisible[descriptionId] = !$scope.isNoticeVisible[descriptionId];
        
        if ($scope.isNoticeVisible[descriptionId]) {
            $scope.toggleText = 'Hide';
        } else {
            $scope.toggleText = 'View';
        }
    }
    
    
    $scope.toggleAnnouncement = function (descId) {
        debugger;
        $scope.isAnnouncementVisible[descId] = !$scope.isAnnouncementVisible[descId];
        
        if ($scope.isAnnouncementVisible[descId]) {
            $scope.toggleText = 'Hide';
        } else {
            $scope.toggleText = 'View';
        }
    }
    
    
    $scope.openViewAllAnnouncement = function(){
        debugger;
        $scope.openAnnouncement = false;
        $scope.openNotice = false;
        $scope.closeAnnouncement = true;
        $scope.closeNotice = false;
    }
    
    $scope.openViewAllNotice = function(){
        debugger;
        $scope.openAnnouncement = false;
        $scope.openNotice = false;
        $scope.closeAnnouncement = false;
        $scope.closeNotice = true;
    }
    
    $scope.closeViewAll = function(){
        debugger;
        $scope.openAnnouncement = true;
        $scope.openNotice = true;
        $scope.closeAnnouncement = false;
        $scope.closeNotice = false;
    }
});