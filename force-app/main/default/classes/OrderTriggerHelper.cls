public class OrderTriggerHelper {
    public static void UpdateOrderLineItemOnOrder(List<OrderItem> newOpportunityLineItems) {
        try{
            map<id,decimal> subOrderMap =new map<id,decimal>(); 
            map<id,decimal> OrderMap =new map<id,decimal>(); 
            List<Order> orderListToUpdateOrder = new List<Order>();
            set<Id> setOfOLI = new set<Id>();
            for(OrderItem OLI : newOpportunityLineItems){
                setOfOLI.add(oli.OrderId);
            }
            system.debug('setOfOLI:::::>'+setOfOLI);
            List<AggregateResult> aResult = [SELECT OrderId,SUM(TotalPrice)allOrderLineItemPrice From OrderItem Where OrderId IN:setOfOLI Group By OrderId];
            system.debug('aResult:::::>'+aResult);
            for(AggregateResult aRes : aResult){
                Id OrdId = (id)aRes.get('OrderId');
                Decimal amountOfOrderProduct =  (decimal)aRes.get('allOrderLineItemPrice'); 
                subOrderMap.Put(OrdId,amountOfOrderProduct);
                system.debug('aRes:::::>'+aRes);
            }
            List<Order> orderList = [SELECT Id,Name,TotalAmount,ParentOrder__c From Order Where id IN: subOrderMap.keySet()];
            set<Id> setOfParentOrderId = new set<Id>();
            for(Order ord : orderList){
                setOfParentOrderId.add(ord.ParentOrder__c);
                system.debug('ord:::::>'+ord);
            }
            system.debug('orderList:::::>'+orderList);
            
            List<AggregateResult> aResults = [SELECT ParentOrder__c,SUM(TotalAmount)allSubOrderAmount From Order Where ParentOrder__c IN:setOfParentOrderId Group By ParentOrder__c];
            system.debug('aResult:::::>'+aResults);
            
            for(AggregateResult aRes : aResults){
                if((id)aRes.get('ParentOrder__c') != null){
                    Id OrdId = (id)aRes.get('ParentOrder__c');
                    Decimal amountOfSubOrder =  (decimal)aRes.get('allSubOrderAmount'); 
                    OrderMap.Put(OrdId,amountOfSubOrder);
                    system.debug('aReDs:::::>'+aRes);
                }
                
            }
            if(OrderMap.keySet() != null){
                for(Id OrderId : OrderMap.keySet()){
                    order ord = new order();
                    ord.Id = OrderId;
                    ord.Total_Amount__c = OrderMap.get(OrderId);
                    orderListToUpdateOrder.add(ord);                   
                }
            }
            update orderListToUpdateOrder;
            system.debug('orderListToUpdateOrder:::::>'+orderListToUpdateOrder);
            
        }
        catch(Exception e){
            system.debug('The error occured at line number ===> ' + e.getlinenumber());
            system.debug('The error occured due to ===> ' + e.getmessage());  
        }
    }
}