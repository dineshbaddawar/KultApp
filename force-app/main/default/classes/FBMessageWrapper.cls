public without sharing class FBMessageWrapper {
    public String object_c;	//page
	public cls_entry[] entry;
	public class cls_entry {
		public String id;	//103319499517877
		public Long time_c;	//1691562125530
		public cls_messaging[] messaging;
	}
	public class cls_messaging {
		public cls_sender sender;
		public cls_recipient recipient;
		public Long timestamp;	//1691562124898
		public cls_message message;
	}
	public class cls_sender {
		public String id;	//6307588752695992
	}
	public class cls_recipient {
		public String id;	//103319499517877
	}
	public class cls_message {
		public String mid;	//m_Pm60WLREClXtDf5fHGayjDkXdhsCETFtIVCp_p1na0fphpioJCrxiKF_W1-HsrdQJANdp4pjfx39mMhhYmSl1w
		public String text;	//Hey
		public cls_reply_to reply_to;
        public cls_attachments[] attachments;
	}

    public class cls_attachments {
        public String type;
        public cls_attachment_payload payload;
    }

    public class cls_attachment_payload {
        public String url;
    }

	public class cls_reply_to {
		public String mid;	//m_Oba2I3BDlkbWEsBmm2OGbjkXdhsCETFtIVCp_p1na0fGKrkmTunWcyIsul1LWaN0xJJof9XmyeiTxnkMwyw55g
	}
	public static FBMessageWrapper parse(String json){
		return (FBMessageWrapper) System.JSON.deserialize(json, FBMessageWrapper.class);
	}

	/* static void testParse() {
		String json=		'{'+
		'  "object_c": "page",'+
		'  "entry": ['+
		'    {'+
		'      "id": "103319499517877",'+
		'      "time_c": 1691562125530,'+
		'      "messaging": ['+
		'        {'+
		'          "sender": {'+
		'            "id": "6307588752695992"'+
		'          },'+
		'          "recipient": {'+
		'            "id": "103319499517877"'+
		'          },'+
		'          "timestamp": 1691562124898,'+
		'          "message": {'+
		'            "mid": "m_3OBqb_WFifz7ZLce8QlfvzkXdhsCETFtIVCp_p1na0ebKWVbP68ZJZDD3XvbW1mPZGegoudbqKvNeD3UqdywuQ",'+
		'            "text": "Hello"'+
		'          }'+
		'        }'+
		'      ]'+
		'    }'+
		'  ]'+
		'}';
		FBMessageWrapper obj = parse(json);
		System.assert(obj != null);
	} */
}