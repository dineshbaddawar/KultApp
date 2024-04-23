public class DynamicHttpCallout {
    public static HttpResponse makeHttpGetCallout(String endpointUrl, Map<String, String> queryParams, Map<String, String> headers) {
        String fullUrl = endpointUrl;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(fullUrl);
        request.setMethod('GET');
        if (headers != null && !headers.isEmpty()) {
            for (String key : headers.keySet()) {
                request.setHeader(key, headers.get(key));
            }
        }
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }
    
    public static HttpResponse makeHttpPOSTCallout(String endpointUrl, Map<String, String> queryParams, Map<String, String> headers) {
        
        String fullUrl = endpointUrl;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(fullUrl);
        request.setMethod('POST');
        if (headers != null && !headers.isEmpty()) {
            for (String key : headers.keySet()) {
                request.setHeader(key, headers.get(key));
            }
        }
        Http http = new Http();
        HttpResponse response = http.send(request);
        system.debug('response==>'+response);
        return response;
    }
    
    public static HttpResponse makeHttpDeleteCallout(String endpointUrl, Map<String, String> queryParams, Map<String, String> headers) {
        String fullUrl = endpointUrl;
        if (queryParams != null && !queryParams.isEmpty()) {
            fullUrl += '?' + String.join(new List<String>(queryParams.keySet()), '&');
        }
        HttpRequest request = new HttpRequest();
        request.setEndpoint(fullUrl);
        request.setMethod('GET');
        
        if (headers != null && !headers.isEmpty()) {
            for (String key : headers.keySet()) {
                request.setHeader(key, headers.get(key));
            }
        }
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }
}