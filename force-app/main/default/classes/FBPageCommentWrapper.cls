public class FBPageCommentWrapper{
	public cls_entry[] entry;
	public String object_c;	//page
	public class cls_entry {
		public String id;	//103319499517877
		public Long time_c;	//1690801083
		public cls_changes[] changes;
	}
	public class cls_changes {
		public cls_value value;
		public String field;	//feed
	}
	public class cls_value {
		public cls_from from_c;
		public cls_post post;
		public String message;	//Comment
		public String post_id;	//103319499517877_106857975834754
		public String comment_id;	//106857975834754_1454793368707778
		public Long created_time;	//1690801081
		public String item;	//comment
		public String parent_id;	//103319499517877_106857975834754
		public String verb;	//add
        public String video;
        public String photo;
	}
	public class cls_from {
		public String id;	//103319499517877
		public String name;	//Test Salesforce Integration
	}
	public class cls_post {
		public String status_type;	//mobile_status_update
		public boolean is_published;
		public String updated_time;	//2023-07-31T10:58:01+0000
		public String permalink_url;	//https://www.facebook.com/permalink.php?story_fbid=pfbid0fh2SCJ4hew2qzPji14prQgm58E6F9ciD8Kpdpn5ojE6JgZaPYjsSM148LbnZwv57l&id=100095316540397
		public String promotion_status;	//inactive
		public String id;	//103319499517877_106857975834754
	}
	public static FBPageCommentWrapper parse(String json){
		return (FBPageCommentWrapper) System.JSON.deserialize(json, FBPageCommentWrapper.class);
	}
}