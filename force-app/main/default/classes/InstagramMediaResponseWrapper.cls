public class InstagramMediaResponseWrapper{
    public String caption;	
    public String media_type;	//IMAGE
    public String media_url;	//https://scontent-yyz1-1.cdninstagram.com/v/t51.29350-15/362372544_202210982513258_8393266818570877071_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=8ae9d6&_nc_ohc=zDVNJvSU5nQAX-q9BIQ&_nc_ht=scontent-yyz1-1.cdninstagram.com&edm=AEQ6tj4EAAAA&oh=00_AfDyA7nu_-Eb-opTdrkuIoIGC-hy18E7Uah6s5wa8oWQnQ&oe=64C8477E
    public String username;	//utilitarian_labs
    public cls_comments comments;
    public String permalink;	//https://www.instagram.com/p/CvFLEeVPZ5W/
    public String id;	//17932309565706946
    public String timestamp;
    public class cls_comments {
        public cls_data[] data;
    }
   public class cls_data {
       public String text;	//@utilitarian_labs yes all good 😊
       public String username;	//kumar_shubham_29
       public String id;	//17925432917740784
       public String commentId;
       public RepliesWrapper replies;
       public String timestamp;//17975260817396560
    }
    public class RepliesWrapper {
        public List<ReplyData> data { get; set; }
    }
    public class ReplyData {
        public String text { get; set; }
        public String username { get; set; }
        public String id { get; set; }
        public String timestamp { get; set; }
    }
    public class cls_user {
        public String id;	//17841455799037293
    }
    public class cls_replies {
        public cls_data[] data;
    }
    public static InstaNotificationWrapper parse(String json){
        return (InstaNotificationWrapper) System.JSON.deserialize(json, InstaNotificationWrapper.class);
    }
}