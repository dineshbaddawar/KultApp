@isTest
public class getCountryAndStatePicklistsTest {
    
    @isTest
    static void testGetAddressSettings() {
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());

        getCountryAndStatePicklists.getAddressSettings();
        
    }
    
}