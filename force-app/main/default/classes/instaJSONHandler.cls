public class instaJSONHandler{
    public cls_data[] data;
    public cls_paging paging;
    public class cls_data {
        public cls_instagram_business_account instagram_business_account;
        public cls_replies repliesOnPost;
        public String media_url;
        public String media_type;
        public String caption;
        public String timestamp;
        public String text;
		public cls_user user;
		public cls_from fromUser;
		public String username;	
		public String id;
        public String permalink;
    }
    public class cls_user {
		public String id;
	}
	public class cls_replies {
		public cls_data[] data;
	}
    public class cls_from {
		public String id;
		public String username;
	}
    public class cls_instagram_business_account {
        public String id;
    }
    public class cls_paging {
        public cls_cursors cursors;
    }
    public class cls_cursors {
        public String before;
        public String after;
    }
    public static instaJSONHandler parse(String json){
        return (instaJSONHandler) System.JSON.deserialize(json, instaJSONHandler.class);
    }
    
}