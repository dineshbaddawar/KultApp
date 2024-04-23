public class InstaNotificationWrapper {
    public cls_entry[] entry;
    public String object_c;	//page
    public class cls_entry {
        public String id;	//0
        public Integer time_c;	//1690447351
        public cls_changes[] changes;
    }
    public class cls_changes {
        public String field;	//feed
        public cls_value value;
        public String text;	//0
    }
    public class cls_value {
        public String item;	//status
        public String id;	//44444444_444444444
        public String verb;	//add
        public Integer published;	//1
        public Integer created_time;	//1690447351
        public String text;	//Example post content.
        public cls_from from_c;
    }
    public class cls_from {
        public String name;	//Test Page
        public String id;	//1067280970047460
    }
    public static InstaNotificationWrapper parse(String json){
        return (InstaNotificationWrapper) System.JSON.deserialize(json, InstaNotificationWrapper.class);
    }
}