public class WS_OrderCreation {
    public Data data;
    
    public class Data {
        public String order_id;
        public String order_date;
        public String payment_id;
        public String payment_status;
        public String payment_type;
        public Decimal amount;
        public String coupon_code;
        public String coupon_discount;
        public String is_coupon_redeemed;
        public String order_status;
        public CustomerDetails customer_details;
        public AddressDetails address_details;
        public List<OrderDetails> order_details;
    }
    
    public class CustomerDetails {
        public String name;
        //public String mobile_number;
        public String email;
        public String phone_number;
    }
    
    public class AddressDetails {
        public ShippingAddress shipping_address;
        public DeliveryAddress billing_address;
    }
    
    public class ShippingAddress {
        public String complete_address;
        public String house_number;
        public String phone_number;
        public String street;
        public String pin_code;
    }
    
    public class DeliveryAddress {
        public String complete_address;
        public String phone_number;
        public String house_number;
        public String pin_code;
        public String state;
    }
    
    public class OrderDetails {
        public String sub_order_id;
        public String sub_order_seller_name;
        public String awb_number;
        public String courier;
        public String expected_delivery_date;
        public String Sub_order_status;
        public String tracking_link;
        public List<ItemDetails> item_details;
    }
    
    public class ItemDetails {
        public String brand;
        public String mrp;
        public Decimal selling_price;
        public Integer quantity;
        public String refunded_price;
        public String sku;
        public String status;
        public String variant_name;
    }
}