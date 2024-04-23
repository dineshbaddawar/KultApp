public class getCountryAndStatePicklists {
    
    public static Map<String, List<Object>> getAddressSettings() {
        return new Map<String, List<Object>>{
            'countries' => getCountries(),
                'states' => getStates()
                };
                    }
    
    public static List<Country> getCountries() {
        Map<String, Object> uiApiResponse = (Map<String, Object>) JSON.deserializeUntyped(
            getCountryAndStatePicklists.callSalesforceUiApi('/services/data/v54.0/ui-api/object-info/Account/picklist-values/012000000000000AAA/BillingCountryCode')
        );
        
        List<Country> countries = new List<Country>();
        
        for (Object countryObject : (List<Object>) uiApiResponse.get('values')) {
            Map<String, Object> country = (Map<String, Object>) countryObject;
            
            countries.add(new Country((String) country.get('label'), (String) country.get('value')));
        }
        
        return countries;
    }
    
    public static List<State> getStates() {
        Map<String, Object> uiApiResponse = (Map<String, Object>) JSON.deserializeUntyped(
            getCountryAndStatePicklists.callSalesforceUiApi('/services/data/v54.0/ui-api/object-info/Account/picklist-values/012000000000000AAA/BillingStateCode')
        );
        
        Map<String, Object> countryToValidFor = (Map<String, Object>) uiApiResponse.get('controllerValues');
        
        Map<Integer, String> validForToCountry = new Map<Integer, String>();
        
        for (String countryIsoCode : countryToValidFor.keySet()) {
            validForToCountry.put((Integer) countryToValidFor.get(countryIsoCode), countryIsoCode);
        }
        
        List<State> states = new List<State>();
        
        for (Object stateObject : (List<Object>) uiApiResponse.get('values')) {
            Map<String, Object> state = (Map<String, Object>) stateObject;
            List<Object> validFor = (List<Object>) state.get('validFor');
            
            states.add(
                new State(
                    (String) state.get('label'),
                    (String) state.get('value'),
                    (String) (validFor.isEmpty() ? '' : validForToCountry.get((Integer) validFor[0]))
                )
            );
        }
        
        return states;
    }
    
    public static String callSalesforceUiApi(String endpoint) {
        
        system.debug('endpoint============>'+ endpoint);
        
        String restApiUrl = URL.getOrgDomainUrl().toExternalForm() + endpoint;
        system.debug('restApiUrl============>'+ restApiUrl);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(restApiUrl);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        
        HttpResponse response = new Http().send(request);
        system.debug('response============>'+ response);
        
        system.debug('response.getBody111111()============>'+ response.getBody());
        if (response.getStatusCode() == 200) {
            system.debug('response.getBody22222()============>'+ response.getBody());
            return response.getBody();
        }
        
        return '';
    }
    
    
    public class Country {
        public String label;
        public String value;
        
        public Country(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    public class State {
        public String label;
        public String value;
        public String dependingOn;
        
        public State(String label,String value, String dependingOn) {
            this.label = label;
            this.value = value;
            this.dependingOn = dependingOn;
        }
    }
}