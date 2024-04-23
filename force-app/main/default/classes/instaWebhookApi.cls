@RestResource(urlMapping='/instaGramAPI/V1/*')
global without sharing class instaWebhookApi {
    private static final String WEB_TOKEN = 'EAAKJz6xiZC6gBAEQ7Ub3pazJxFazWFUXEkbp2Hlg0W0EmblRJVhrLLr1WUwL81hqfSxRXJJ8otiGZAyQ66onZBoRFTOqdjZBKioZA5iy55N0rxyZBulbw1XVgu6ktZA0b0vs6uZAFG7SodcyHayN2id8WAktoJejpdCcaTLF9NwV6FkTvizWzYBZC';

    @HttpPost
    global static void webhookListener() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String requestBody = req.requestBody.toString();
            System.debug('--- WEBHOOK requestBody' + requestBody);

            if (requestBody != null) {
                requestBody = requestBody.replace('"object"', '"object_c"')
                                         .replace('"time"', '"time_c"')
                                         .replace('"from"', '"from_c"');
                
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
                System.debug('responseMap--->' + responseMap);

                if (responseMap != null && responseMap.containsKey('entry')) {
                    List<Object> entryList = (List<Object>) responseMap.get('entry');
                    Map<String, Object> entryMap = (Map<String, Object>) entryList[0];
                    List<Object> messagingList = (List<Object>) entryMap.get('messaging');
                    Map<String, Object> messagingMap = (Map<String, Object>) messagingList[0];
                    System.debug('messagingMap--->' + messagingMap);

                    if (messagingMap != null && !messagingMap.isEmpty()) {
                        System.debug('The change is ' + messagingMap.get('message'));
                        
                        if (messagingMap.containsKey('message')) {
                            processNewMessages(messagingMap);
                            System.debug('The change is ' + messagingMap.get('message'));
                        } else {
                            processNewMessages(messagingMap);
                            System.debug('The change is ' + messagingMap.get('message'));
                        }
                    }
                }
            }
        } catch(Exception e) {
            System.debug('--- Exception' + e.getMessage());
            handleExceptionResponse(res, e);
        }
        
        res.addHeader('Content-Type', 'application/json');
    }
    
    private static void processNewMessages(Map<String, Object> messagingMap) {
        // Implementation of processNewMessages method
    }
    
    @HttpGet
    global static Integer verify() {
        String token = RestContext.request.params.get('hub.verify_token');
        Integer challenge = Integer.valueOf(RestContext.request.params.get('hub.challenge'));
        if (token == WEB_TOKEN) {
            return challenge;
        }
        return null;
    }
    
    global static String getTimeStamp(Integer timeValue) {
        Integer unixTimestamp = timeValue;
        Datetime dateTimeValue = Datetime.newInstance(unixTimestamp * 1000L);
        String formattedDateTime = dateTimeValue.format('yyyy-MM-dd HH:mm:ss');
        return  formattedDateTime;
    }
    
    private static void handleExceptionResponse(RestResponse response, Exception e) {
        response.addHeader('Content-Type', 'application/json');
        response.statusCode = 500;
        response.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + ' @ ' + e.getLineNumber() + '"}');
    }
    
    public class ResponseWrapper {
        String message;
        String token;
        
        public ResponseWrapper(String message, String token) { 
            this.message = message;
            this.token = token;
        }
    }
}