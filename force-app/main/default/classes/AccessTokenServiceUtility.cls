public class AccessTokenServiceUtility {
    
    private static final String FB_GRAPH_API_BASE_URL = 'callout:meta';
    //Getting the basic details from custom setting
    private static Instagram_Api_Details__c fap         = Instagram_Api_Details__c.getInstance();
    private static final String CLIENT_ID               = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET                 = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI                  = fap.REDIRECT_URI__c;
    private static String accessToken                   = fap.accessToken__c;
    private static string scope                         = 'user_profile,user_media';
    //Getting the record Type Id
    //private static Id caseRecordTypeId                  = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
    
    public Static String getPageAccessToken(string pageName){
        string pageAccessToken = '';
        String apiEndpoint = FB_GRAPH_API_BASE_URL + '/me/accounts?access_token=' + accessToken;
        Map<String, PageInfo> pagesMap = new Map<String, PageInfo>();
        HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(apiEndpoint, null, null);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> pageDataList = (List<Object>) jsonResponse.get('data');
            system.debug('pageDataList==>'+pageDataList);
            for (Object pageData : pageDataList) {
                Map<String, Object> pageMap = (Map<String, Object>) pageData;
                PageInfo pageInfo = new PageInfo(
                    (String) pageMap.get('id'),
                    (String) pageMap.get('name'),
                    (String) pageMap.get('access_token'),
                    (List<Object>) pageMap.get('tasks')
                );
                pagesMap.put((String) pageMap.get('name'), pageInfo);
            }
        }
        if(pagesMap.containsKey(pageName)){
            pageAccessToken = pagesMap.get(pageName).accessToken;
        }
        system.debug('pageAccessToken=========>'+pageAccessToken);
        Instagram_Api_Details__c settings = Instagram_Api_Details__c.getOrgDefaults();
        
        // Update the accessToken__c field
        settings.pageAccessToken__c = pageAccessToken;
		update settings;
        return pageAccessToken;
    }
    
    public Static String getAppAccessToken(){
        String appAccessToken = CLIENT_ID + '|' + CLIENT_SECRET;
        return appAccessToken;
    }
    
    //To be developed..
    public static String getUserAccessToken() {
         String accessToken = '';
        // Construct authorization URL
        String authorizationUrl = 'https://api.instagram.com/oauth/authorize/?client_id=' + CLIENT_ID + '&redirect_uri=' + REDIRECT_URI + '&scope=' + scope + '&response_type=code';
        system.debug(authorizationUrl);
        // Redirect user to authorization URL
        PageReference authPage = new PageReference(authorizationUrl);
        authPage.setRedirect(true);
        
        // Handle callback
        // In the controller associated with your redirect URI page, extract the authorization code from the query parameters
        
        String authCode = ApexPages.currentPage().getParameters().get('code');
        
        // Exchange authorization code for access token
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.instagram.com/oauth/access_token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('client_id=' + CLIENT_ID + '&client_secret=' + CLIENT_SECRET + '&grant_type=authorization_code' + '&redirect_uri=' + REDIRECT_URI + '&code=' + authCode);
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            accessToken = (String) tokenResponse.get('access_token');
            // Now you have the user's access token
        } else {
            // Handle error
        }
        return accessToken;
    }
    
    private class PageInfo {
        private String id { get; private set; }
        private String name { get; private set; }
        private String accessToken { get; private set; }
        private List<Object> tasks { get; private set; }

        private PageInfo(String id, String name, String accessToken, List<Object> tasks) {
            this.id = id;
            this.name = name;
            this.accessToken = accessToken;
            this.tasks = tasks;
        }
    }

}