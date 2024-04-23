trigger orderLineItemTrigger on OrderItem (After insert, After Update) {
    if((trigger.isUpdate || trigger.isInsert)&& trigger.isAfter){
        OrderTriggerHelper.UpdateOrderLineItemOnOrder(trigger.new);
    }
}