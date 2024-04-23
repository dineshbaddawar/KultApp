public class FBFeedNotificationWrapper {

    public cls_entry[] entry;
	public String object_c;	//page
	public class cls_entry {
		public String id;	//0
		public Long time_c;	//1690447351
		public cls_changes[] changes;
	}
	public class cls_changes {
		public String field;	//feed
		public cls_value value;
	}
	public class cls_value {
		public String item;	//status
		public String post_id;	//44444444_444444444
		public String verb;	//add
		public Integer published;	//1
		public Long created_time;	//1690447351
		public String message;	//Example post content.
		public cls_from from_c;
        public String link;
	}
	public class cls_from {
		public String name;	//Test Page
		public String id;	//1067280970047460
	}
	public static FBFeedNotificationWrapper parse(String json){
		return (FBFeedNotificationWrapper) System.JSON.deserialize(json, FBFeedNotificationWrapper.class);
	}

	/* static testMethod void testParse() {
		String json=		'{'+
		'  "entry": ['+
		'    {'+
		'      "id": "0",'+
		'      "time": 1690447351,'+
		'      "changes": ['+
		'        {'+
		'          "field": "feed",'+
		'          "value": {'+
		'            "item": "status",'+
		'            "post_id": "44444444_444444444",'+
		'            "verb": "add",'+
		'            "published": 1,'+
		'            "created_time": 1690447351,'+
		'            "message": "Example post content.",'+
		'            "from": {'+
		'              "name": "Test Page",'+
		'              "id": "1067280970047460"'+
		'            }'+
		'          }'+
		'        }'+
		'      ]'+
		'    }'+
		'  ],'+
		'  "object": "page"'+
		'}';
		FeedWrapper obj = parse(json);
		System.assert(obj != null);
	} */
    
}