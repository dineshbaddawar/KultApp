public class showDetailsOfOrderFromCase {
    @AuraEnabled
    public static List<Case> showOrderDetailsOfAnCase() {
        return [SELECT Id,AccountId,ContactId,Subject,Status From Case];
    }
    @AuraEnabled
     public static List<Order> showOrderDetails() {
        return [SELECT Case__c,TotalAmount,Status,OrderNumber,CustomerAuthorizedById From Order];
    }
}