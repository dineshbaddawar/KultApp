public class AccessTokenUtility {
    private static Instagram_Api_Details__c fap         = Instagram_Api_Details__c.getOrgDefaults();
    private static final String appId                   = fap.CLIENT_ID__c;
    private static String appSecret                     = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI                  = fap.REDIRECT_URI__c;
    private static String userAccessToken               = fap.accessToken__c;
    private static String pageAccessToken               = fap.pageAccessToken__c ;
    private static String AppAccessToken                = fap.App_Access_Token__c ;
    private static String basicUrl                      = fap.basicUrl__c;
    private static String businessUserId                = fap.businessUserId__c;
    private static String fbExchangeToken               = fap.accessToken__c;
    private static String hashtagName                   = fap.HashTag__c;
    
    public static void getLongLivedUserAccessToken() {
        String endpointUrl = 'https://graph.facebook.com/v17.0/oauth/access_token';
        String requestBody = 'grant_type=fb_exchange_token&client_id=' + appId + '&client_secret=' + appSecret + '&fb_exchange_token=' + userAccessToken;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestBody);
        
        try {
            HttpResponse response = http.send(request);
            string longLivedAccessToken  = handleResponse(response);
            
            fap.accessToken__c = longLivedAccessToken;
            update fap;
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
    
    public static void getLongLivedPageAccessToken() {
        String endpointUrl = 'https://graph.facebook.com/v17.0/oauth/access_token';
        String requestBody = 'grant_type=fb_exchange_token&client_id=' + appId + '&client_secret=' + appSecret + '&fb_exchange_token=' + pageAccessToken;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestBody);
        
        try {
            HttpResponse response = http.send(request);
            string longLivedAccessToken  = handleResponse(response);
            fap.pageAccessToken__c = longLivedAccessToken;
            update fap;
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
    
    public static void getLongLivedAppAccessToken() {
        String endpointUrl = 'https://graph.facebook.com/v17.0/oauth/access_token';
        String requestBody = 'grant_type=fb_exchange_token&client_id=' + appId + '&client_secret=' + appSecret + '&fb_exchange_token=' + AppAccessToken;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestBody);
        
        try {
            HttpResponse response = http.send(request);
            string longLivedAccessToken  = handleResponse(response);
            //fap.App_Access_Token__c = longLivedAccessToken;
            update fap;
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
    
    private static String handleResponse(HttpResponse response) {
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) responseBody.get('access_token');
            System.debug('Access Token: ' + accessToken);
            return accessToken;
        } else {
            System.debug('Error: HTTP ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
            return null;
        }
    }
}