public class OutlookBookingWrapper {
    
    public class BookingServicesResponse {
        public String odataContext{get;set;}
        public List<BookingService> value{get;set;}
    }
    
    public class BookingService {
        public String id{get;set;}
        public String displayName{get;set;}
        public String defaultDuration{get;set;}
        public Decimal defaultPrice{get;set;}
        public String defaultPriceType{get;set;}
        public String description{get;set;}
        public Boolean isHiddenFromCustomers{get;set;}
        public String notes{get;set;}
        public String additionalInformation{get;set;}
        public String languageTag{get;set;}
        public String preBuffer{get;set;}
        public String postBuffer{get;set;}
        public List<String> staffMemberIds{get;set;}
        public Boolean isLocationOnline{get;set;}
        public Boolean smsNotificationsEnabled{get;set;}
        public Boolean isAnonymousJoinEnabled{get;set;}
        public String webUrl{get;set;}
        public Integer maximumAttendeesCount{get;set;}
        public SchedulingPolicy schedulingPolicy{get;set;}
        public DefaultLocation defaultLocation{get;set;}
        public List<Object> defaultReminders{get;set;}
        public List<Object> customQuestions{get;set;}
    }
    
    public class SchedulingPolicy {
        public String timeSlotInterval{get;set;}
        public String minimumLeadTime{get;set;}
        public String maximumAdvance{get;set;}
        public Boolean sendConfirmationsToOwner{get;set;}
        public Boolean allowStaffSelection{get;set;}
    }
    
    public class DefaultLocation {
        public String displayName{get;set;}
        public String locationEmailAddress{get;set;}
        public String locationUri{get;set;}
        public String locationType{get;set;}
        public String uniqueId{get;set;}
        public String uniqueIdType{get;set;}
        public Address address{get;set;}
        public Coordinates coordinates{get;set;}
    }
    
    public class Address {
        public String street{get;set;}
        public String city{get;set;}
        public String state{get;set;}
        public String countryOrRegion{get;set;}
        public String postalCode{get;set;}
    }
    
    public class Coordinates {
        public Decimal altitude{get;set;}
        public Decimal latitude{get;set;}
        public Decimal longitude{get;set;}
        public Decimal accuracy{get;set;}
        public Decimal altitudeAccuracy{get;set;}
    }
    
   
   
    
}