@RestResource(urlMapping='/OrderCreation')
global class WS_OrderCreationv1 {
    
    @HttpPost
    global static List<ResponseBody> doPost() {
        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;
        ResponseBody res = new ResponseBody();
        List<ResponseBody> respBodyList = new List<ResponseBody>();
        try {
            
            List<WS_OrderCreation> orderRecords = (List<WS_OrderCreation>) JSON.deserialize(req.requestBody.toString(), List<WS_OrderCreation>.class);
            
            List<Account> accountsToUpdate = new List<Account>();
            List<Account> accountsToInsert = new List<Account>();
            List<Order> ordersToInsert = new List<Order>();
            List<List<OrderItem>> orderItemsToInsert = new List<List<OrderItem>>();
            
            Map<String, Account> existingAccountsByEmail = new Map<String, Account>();
            Map<String, Account> existingAccountsByPhone = new Map<String, Account>();
            Map<String, Account> existingAccountsByMobileNumber = new Map<String, Account>();
            Set<String> existingOrderIds = new Set<String>();
            Set<String> existingSubOrderIds = new Set<String>();
            
            for(Order existingOrder : [SELECT Id, Name FROM Order WHERE Name IN :getOrderIds(orderRecords)]) {
                existingOrderIds.add(existingOrder.Name);
            }
            
            if(!orderRecords.isEmpty()) {
                for(WS_OrderCreation orderData : orderRecords) {
                    if(existingOrderIds.contains(orderData.data.order_id)) {
                        res.status = 'Aborted';
                        res.message = 'Order Already Exists';
                        res.orderId = null;
                        respBodyList.add(res);
                        return respBodyList;
                    }
                    if(String.isNotBlank(orderData.data.customer_details.email)) {
                        existingAccountsByEmail.put(orderData.data.customer_details.email.toLowerCase(), null);
                    }
                    if(String.isNotBlank(orderData.data.customer_details.phone_number)) {
                        existingAccountsByPhone.put(orderData.data.customer_details.phone_number, null);
                    }
                    // if(String.isNotBlank(orderData.data.customer_details.mobile_number)) {
                    //     existingAccountsByMobileNumber.put(orderData.data.customer_details.mobile_number, null);
                    // }
                }
                
                List<Account> accList = [SELECT Id, Email__c, Phone, Mobile_Phone__c, BillingStreet, ShippingStreet FROM Account WHERE Email__c IN :existingAccountsByEmail.keySet() OR Phone IN :existingAccountsByPhone.keySet() OR Mobile_Phone__c IN :existingAccountsByPhone.keySet()];
                for(Account existingAccount : accList) {
                    if(String.isNotBlank(existingAccount.Email__c)) {
                        existingAccountsByEmail.put(existingAccount.Email__c.toLowerCase(), existingAccount);
                    }
                    if(String.isNotBlank(existingAccount.Phone)) {
                        existingAccountsByPhone.put(existingAccount.Phone, existingAccount);
                    }
                    if(String.isNotBlank(existingAccount.Mobile_Phone__c)) {
                        existingAccountsByPhone.put(existingAccount.Mobile_Phone__c, existingAccount);
                    }
                }
                
                for(WS_OrderCreation orderData : orderRecords) {
                    Account account;
                    if(String.isNotBlank(orderData.data.customer_details.email)) {
                        account = existingAccountsByEmail.get(orderData.data.customer_details.email.toLowerCase());
                    }
                    if(account == null && String.isNotBlank(orderData.data.customer_details.phone_number)) {
                        account = existingAccountsByPhone.get(orderData.data.customer_details.phone_number);
                    }
                    // if(account == null && String.isNotBlank(orderData.data.customer_details.mobile_number)) {
                    //     account = existingAccountsByMobileNumber.get(orderData.data.customer_details.mobile_number);
                    // }
                    
                    if(account != null) {
                        updateAccount(account, orderData.data.customer_details, orderData.data); 
                    } else {
                        account = createAccount(orderData.data.customer_details, orderData.data);
                        if(account != null) {
                            if(account.Id != null) {
                                accountsToUpdate.add(account);
                            } else {
                                accountsToInsert.add(account);
                            }
                        }
                    }
                    
                    if(account != null) {
                        List<Contract> existingContract = [SELECT Id FROM Contract WHERE AccountId = :account.Id LIMIT 1];
                        if(existingContract.Size()==0) {
                            Contract newContract = createContract(orderData.data, account);
                            if(newContract != null) {
                                // Handle any further logic if needed
                            }
                            
                            Order order = createOrder(orderData.data, account.Id, newContract.Id);
                            if(!(orderData.data.order_details).isEmpty()){

                                List<Order> subOrders = createSubOrders(orderData.data.order_details, order.Id, account.Id, newContract.Id, order.EffectiveDate);
                            }
                            System.debug('order==>' + order);
                            res.status = 'Success';
                            res.message = 'Order Successfully Created';
                            res.orderId = order.Id;
                            respBodyList.add(res);
                            if(order != null) {
                                ordersToInsert.add(order);
                                // Create order items and associate with the order
                                // if(orderData.data.order_details != null && !orderData.data.order_details.isEmpty()) {
                                //     for(WS_OrderCreation.OrderDetails orderDetails : orderData.data.order_details) {
                                //         List<OrderItem> orderItems = createOrderItem(orderDetails, order.Id);
                                //         if(!orderItems.isEmpty()) {
                                //             orderItemsToInsert.add(orderItems);
                                //         }
                                //     }
                                // }
                            }
                        }else{
                            Order order = createOrder(orderData.data, account.Id, existingContract[0].Id);
                            if(!(orderData.data.order_details).isEmpty()){
                                System.debug('Test');
                                List<Order> subOrders = createSubOrders(orderData.data.order_details, order.Id, account.Id, existingContract[0].Id, order.EffectiveDate);
                            }
                            System.debug('order==>' + order);
                            res.status = 'Success';
                            res.message = 'Order Successfully Created';
                            res.orderId = order.Id;
                            respBodyList.add(res);
                            if(order != null) {
                                ordersToInsert.add(order);
                                // Create order items and associate with the order
                                // if(orderData.data.order_details != null && !orderData.data.order_details.isEmpty()) {
                                //     for(WS_OrderCreation.OrderDetails orderDetails : orderData.data.order_details) {
                                //         List<OrderItem> orderItems = createOrderItem(orderDetails, order.Id);
                                //         if(!orderItems.isEmpty()) {
                                //             orderItemsToInsert.add(orderItems);
                                //         }
                                //     }
                                // }
                            }
                        } 
                    }
                    
                    // Bulk update existing accounts
                    if(!accountsToUpdate.isEmpty()) {
                        update accountsToUpdate;
                    }
                    // Bulk insert new accounts
                    if(!accountsToInsert.isEmpty()) {
                        insert accountsToInsert;
                    }
                    // Bulk insert orders
                    if(!ordersToInsert.isEmpty()) {
                        //insert ordersToInsert;
                    }
                    // Bulk insert order items
                    /*if(!orderItemsToInsert.isEmpty()) {
insert orderItemsToInsert;
}*/
                }
            }
            return respBodyList;
            
        } catch(Exception e) {
            system.debug('Error Message==>'+e.getMessage() + ' at line==> ' + e.getLineNumber());
            return null;
        }
        
    }
    
    public static Account updateAccount(Account account, WS_OrderCreation.CustomerDetails customerDetails, WS_OrderCreation.Data orderData) {
        // Update account fields
        account.Name = customerDetails.name;
        account.Phone = customerDetails.phone_number;
        //account.Mobile_Phone__c = customerDetails.mobile_number;
        account.Email__c = customerDetails.email;
        if(account.BillingStreet == null){
            //account.BillingStreet = orderData.address_details.shipping_address.house_number + ' ' + orderData.address_details.shipping_address.street; 
            account.BillingStreet = orderData.address_details.billing_address.complete_address != null ? orderData.address_details.billing_address.complete_address : ''; 
            account.BillingPostalCode = orderData.address_details.billing_address.pin_code != null ? orderData.address_details.billing_address.pin_code : '';
        }
        if(account.ShippingStreet == null){
            //account.ShippingStreet = orderData.address_details.delivery_address.house_number;
            account.ShippingStreet = orderData.address_details.shipping_address.complete_address != null ? orderData.address_details.shipping_address.complete_address : '';
            //account.ShippingState = orderData.address_details.delivery_address.state;
            account.ShippingPostalCode = orderData.address_details.shipping_address.pin_code != null ? orderData.address_details.shipping_address.pin_code : '';   
        }
        //account.Delivery_Mobile_Number__c = orderData.address_details.delivery_address.mobile_number;
        
        Account_Address__c deliveryAddress = findOrCreateDeliveryAddress(orderData.address_details, account );
        Account_Address__c shippingAddress = findOrCreateShippingAddress(orderData.address_details, account );
        update account;
        System.debug('updated Account==. ' + account);
        return account;
    }
    
    public static Account createAccount(WS_OrderCreation.CustomerDetails customerDetails, WS_OrderCreation.Data orderData) {
        // Create new account
        Account newAccount = new Account();
        newAccount.Name = customerDetails.name != null ? customerDetails.name : 'Unknown Name';
        newAccount.Phone = customerDetails.phone_number != null ? customerDetails.phone_number : '';
        //newAccount.Mobile_Phone__c = customerDetails.mobile_number;
        newAccount.Email__c = customerDetails.email != null ? customerDetails.email : '';
        //newAccount.BillingStreet = orderData.address_details.shipping_address.house_number + ' ' + orderData.address_details.shipping_address.street;
        newAccount.BillingStreet = orderData.address_details.billing_address.complete_address != null ? orderData.address_details.billing_address.complete_address : '';
        newAccount.BillingPostalCode = orderData.address_details.billing_address.pin_code != null ? orderData.address_details.billing_address.pin_code : '';
        newAccount.ShippingStreet = orderData.address_details.shipping_address.house_number != null ? orderData.address_details.shipping_address.house_number : '';
        //newAccount.ShippingState = orderData.address_details.shipping_address.state;
        newAccount.ShippingPostalCode = orderData.address_details.shipping_address.pin_code != null ? orderData.address_details.shipping_address.pin_code : '';
        //newAccount.Delivery_Mobile_Number__c = orderData.address_details.shipping_address.mobile_number;
        insert newAccount;
        System.debug('created Account==. ' + newAccount);
        Account_Address__c deliveryAddress = findOrCreateDeliveryAddress(orderData.address_details, newAccount );
        Account_Address__c shippingAddress = findOrCreateShippingAddress(orderData.address_details, newAccount );
        return newAccount;
    }
    
    public static Order createOrder(WS_OrderCreation.Data orderData, Id accountId, Id ContractId) {
        // Create new order
        Order newOrder = new Order();
        newOrder.Name = orderData.order_id != null ? orderData.order_id : '';
        newOrder.Pricebook2Id = '01sIR000002f36lYAA';
        newOrder.AccountId = accountId;
        newOrder.EffectiveDate = orderData.order_date != null ? Date.ValueOf(orderData.order_date) : System.today();
        newOrder.Payment_Id__c = orderData.payment_id != null ? orderData.payment_id : '';
        newOrder.Payment_Status__c = orderData.payment_status != null ? orderData.payment_status : '';
        newOrder.Payment_Type__c = orderData.payment_type != null ? orderData.payment_type : '';
        newOrder.Amount_from_OMS__c = orderData.amount != null ? orderData.amount : 0;
        newOrder.Coupon_Code__c = orderData.coupon_code != null ? orderData.coupon_code : '';
        newOrder.Coupon_Discount__c = orderData.coupon_discount != null ? Decimal.valueOf(orderData.coupon_discount) : 0;
        newOrder.Coupon__c = orderData.is_coupon_redeemed;
        newOrder.ContractId = ContractId;
        newOrder.Status = orderData.order_status;
        //newOrder.BillingStreet = orderData.address_details.shipping_address.house_number + ' ' + orderData.address_details.shipping_address.street;
        newOrder.BillingStreet = orderData.address_details.billing_address.complete_address != null ? orderData.address_details.billing_address.complete_address : '';
        newOrder.BillingPostalCode = orderData.address_details.billing_address.pin_code != null ? orderData.address_details.billing_address.pin_code : '';
        newOrder.ShippingStreet = orderData.address_details.shipping_address.complete_address != null ? orderData.address_details.shipping_address.complete_address : '';
        //newOrder.ShippingState = orderData.address_details.shipping_address.state;
        newOrder.ShippingPostalCode = orderData.address_details.shipping_address.pin_code != null ? orderData.address_details.shipping_address.pin_code : '';
        newOrder.Delivery_Mobile_Number__c = orderData.address_details.shipping_address.phone_number != null ? orderData.address_details.shipping_address.phone_number : '';
        newOrder.ContractId = ContractId;
        insert newOrder;
        System.debug('created Order==> ' + newOrder);
        return newOrder;
    }

    public static List<Order> createSubOrders(List<WS_OrderCreation.OrderDetails> orderDetails, Id orderId, Id accId, Id ContractId, Date orderDate){
        try{
            List<Order> subOrdersToAdd = new List<Order>();
            for(WS_OrderCreation.OrderDetails orderRec : orderDetails){
                Order subOrderRec = new Order();
                subOrderRec.Sub_Order_Id__c = orderRec.sub_order_id != null ? orderRec.sub_order_id : '';
                subOrderRec.Seller_Name__c = orderRec.sub_order_seller_name != null ? orderRec.sub_order_seller_name : '';
                subOrderRec.AWB_Number__c = orderRec.awb_number != null ? orderRec.awb_number : ''; 
                subOrderRec.EffectiveDate = orderDate;
                subOrderRec.ContractId = ContractId;
                subOrderRec.Courier__c = orderRec.courier != null ? orderRec.courier : '';
                subOrderRec.Pricebook2Id = '01sIR000002f36lYAA';
                if(orderRec.expected_delivery_date != null){
                    subOrderRec.Expected_Delivery_Date__c = Date.ValueOf(orderRec.expected_delivery_date);
                }
                subOrderRec.Status = orderRec.Sub_order_status != null ? orderRec.Sub_order_status : '';
                subOrderRec.Tracking_Link__c = orderRec.tracking_link != null ? orderRec.tracking_link : '';
                subOrderRec.AccountId = accId;
                subOrderRec.ParentOrder__c = orderId;
                insert subOrderRec;
                List<OrderItem> orderItems = createOrderItem(orderRec, subOrderRec.Id);
                subOrdersToAdd.add(subOrderRec);
            }
            return subOrdersToAdd;
            // if(!subOrdersToAdd.isEmpty()){
            //     insert subOrdersToAdd;
            // }
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
    }
    
    public static List<OrderItem> createOrderItem(WS_OrderCreation.OrderDetails orderDetails, Id orderId) {
        // Create new order item
        List<OrderItem> oliListToAdd = new List<OrderItem>();
        for(WS_OrderCreation.ItemDetails itemDetail : orderDetails.item_details){
            OrderItem newOrderItem = new OrderItem();
            newOrderItem.Brand__c = itemDetail.brand != null ? itemDetail.brand : '';
            newOrderItem.UnitPrice = itemDetail.mrp != null ? Decimal.valueOf(itemDetail.mrp) : 0;
            newOrderItem.OrderId = orderId;
            newOrderItem.Selling_Price__c = itemDetail.selling_price != null ? itemDetail.selling_price : 0;
            newOrderItem.Quantity = itemDetail.quantity != null ? itemDetail.quantity : 0;
            if(itemDetail.refunded_price != '' && itemDetail.refunded_price != null)
                newOrderItem.Refunded_Price__c = Decimal.valueOf(itemDetail.refunded_price);
            newOrderItem.SKU__c = itemDetail.sku != null ? itemDetail.sku : '';
            newOrderItem.Total_Selling_Price__c = newOrderItem.Selling_Price__c * newOrderItem.Quantity;
            newOrderItem.Status__c = itemDetail.status != null ? itemDetail.status : '';
            newOrderItem.Product_Name__c = itemDetail.variant_name != null ? itemDetail.variant_name : '';
            newOrderItem.PricebookEntryId = '01uF3000005qUMkIAM';
            newOrderItem.Product2Id = '01tF3000006czvcIAA';
            oliListToAdd.add(newOrderItem);
        }
        insert oliListToAdd;
        System.debug('inserted OLIs==. ' + oliListToAdd);
        return oliListToAdd;
    }
    
    public static Contract createContract(WS_OrderCreation.Data orderData, Account account) {
        // Create new contract
        
        Contract newContract = new Contract();
        newContract.AccountId = account.Id;
        System.debug('newContract.AccountId==> ' + newContract.AccountId);
        newContract.StartDate = orderData.order_date != null ? Date.ValueOf(orderData.order_date) : System.Today();
        newContract.ContractTerm = 12;
        // Set other contract fields accordingly
        insert newContract;
        System.debug('created Contract==> ' + newContract);
        return newContract;
    }
    
    public static Set<String> getOrderIds(List<WS_OrderCreation> orderRecords) {
        Set<String> orderIds = new Set<String>();
        for(WS_OrderCreation orderData : orderRecords) {
            orderIds.add(orderData.data.order_id);
        }
        return orderIds;
    }
    
    public static Account_Address__c findOrCreateDeliveryAddress(WS_OrderCreation.AddressDetails addressDetails, Account accRec){
        try{
            List<Account_Address__c> deliveryAddressList = [SELECT Id, OwnerId, Name, Address__Street__s, Address__City__s, Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s, 
                                                            Address__Latitude__s, Address__Longitude__s, Address__GeocodeAccuracy__s, Address__c, Address_Type__c, Account__c, Mobile_Phone__c, Street__c, City__c, State__c, 
                                                            Country__c, Postal_Code__c FROM Account_Address__c WHERE Street__c =: addressDetails.billing_address.complete_address 
                                                           AND Postal_Code__c=: addressDetails.billing_address.pin_code /*AND State__c =: addressDetails.billing_address.state */
                                                           AND Account__c =: accRec.Id AND Mobile_Phone__c=: addressDetails.billing_address.phone_number LIMIT 1];
            if(deliveryAddressList.isEmpty()){
                Account_Address__c newDeliveryAddressRec = new Account_Address__c();
             	newDeliveryAddressRec.Street__c = addressDetails.billing_address.complete_address != null ? addressDetails.billing_address.complete_address : '' ;
                    //newDeliveryAddressRec.State__c = addressDetails.billing_address.state ;
                    newDeliveryAddressRec.Postal_Code__c = addressDetails.billing_address.pin_code != null ? addressDetails.billing_address.pin_code : '';
                newDeliveryAddressRec.Mobile_Phone__c = addressDetails.billing_address.phone_number != null ? addressDetails.billing_address.phone_number : '';
                newDeliveryAddressRec.Account__c = accRec.Id;
                newDeliveryAddressRec.Address_Type__c = 'Billing';
                insert newDeliveryAddressRec;
                System.debug('created newDeliveryAddressRec==> ' + newDeliveryAddressRec);
                return newDeliveryAddressRec;
            }else{
                System.debug('existing deliveryAddressList[0]==> ' + deliveryAddressList[0]);
                return deliveryAddressList[0];
            }
            
        }catch(exception e){
            system.debug('Error Message==>'+e.getMessage() + ' at line==> ' + e.getLineNumber());
            return null;
        }
    }
    
    public static Account_Address__c findOrCreateShippingAddress(WS_OrderCreation.AddressDetails addressDetails, Account accRec){
        try{
            
            //String shippingStreet = addressDetails.shipping_address.house_number + ' ' + addressDetails.shipping_address.street;
            String shippingStreet = addressDetails.shipping_address.complete_address;
            
            List<Account_Address__c> shippingAddressList = [SELECT Id, OwnerId, Name, Address__Street__s, Address__City__s, Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s, 
                                                            Address__Latitude__s, Address__Longitude__s, Address__GeocodeAccuracy__s, Address__c, Address_Type__c, Account__c, Mobile_Phone__c, Street__c, City__c, State__c, 
                                                            Country__c, Postal_Code__c FROM Account_Address__c WHERE Street__c =: shippingStreet
                                                           AND Postal_Code__c=: addressDetails.shipping_address.pin_code AND Mobile_Phone__c=: addressDetails.shipping_address.phone_number AND Account__c =: accRec.Id LIMIT 1];
            
            if(shippingAddressList.isEmpty()){
                Account_Address__c newAddressRec = new Account_Address__c();
             	//newAddressRec.Street__c = addressDetails.shipping_address.house_number + ' ' + addressDetails.shipping_address.street ;
                 newAddressRec.Street__c = addressDetails.shipping_address.complete_address != null ? addressDetails.shipping_address.complete_address : '';
                    newAddressRec.Postal_Code__c = addressDetails.shipping_address.pin_code != null ? addressDetails.shipping_address.pin_code : '';
                    newAddressRec.Mobile_Phone__c = addressDetails.shipping_address.phone_number != null ? addressDetails.shipping_address.phone_number : '';
                newAddressRec.Account__c = accRec.Id;
                newAddressRec.Address_Type__c = 'Shipping';
                insert newAddressRec;
                System.debug('created newAddressRec==> ' + newAddressRec);
                return newAddressRec;
            }else{
                System.debug('existing shippingAddressList[0]==> ' + shippingAddressList[0]);
                return shippingAddressList[0];
            }
        }catch(exception e){
            system.debug('Error Message==>'+e.getMessage() + ' at line==> ' + e.getLineNumber());
            return null;
        }
    }
    
    global class ResponseBody {
        public String status;
        public String message;
        public String orderId;
    }
}