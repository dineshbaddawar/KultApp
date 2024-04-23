/**Author:Salesforce Cody
** Fore More: https://salesforcecody.com/ 
**Portfolio: http://umeshbeti.com/
 */

 public class InstaCommentWrapper{
	public cls_replies replies;
	public String text;	//@kumar_shubham_29  alll good ..
	public cls_user user;
	public String timestamp;	//2023-07-25T10:24:59+0000
	public String username;	//utilitarian_labs
	public cls_media media;
	public String id;	//17975260817396560
	public class cls_replies {
		public cls_data[] data;
	}
	public class cls_data {
		public String text;	//@utilitarian_labs yes all good 😊
		public String username;	//kumar_shubham_29
		public String timestamp;	//2023-07-27T14:41:50+0000
		public String id;	//17925432917740784
	}
	public class cls_user {
		public String id;	//17841455799037293
	}
	public class cls_media {
		public String id;	//17932309565706946
	}
	public static InstaCommentWrapper parse(String json){
		return (InstaCommentWrapper) System.JSON.deserialize(json, InstaCommentWrapper.class);
	}

	
}