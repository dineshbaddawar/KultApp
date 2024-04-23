public class InstaDMWrapper {
    public List<Data> data { get; set; }
    public Paging paging { get; set; }
    
    public class Data {
        public Integer message_count { get; set; }
        public Messages messages { get; set; }
        public String id { get; set; }
        public Boolean can_reply { get; set; }
        public Senders senders { get; set; }
    }
    
    public class Messages {
        public List<MessageData> data { get; set; }
        public Paging paging { get; set; }
    }
    
    public class MessageData {
        public String message { get; set; }
        public String id { get; set; }
        public String thread_id { get; set; }
        public String created_time { get; set; }
        public SenderData fromDetails {get;set; }
    }
    
    public class Paging {
        public Cursors cursors { get; set; }
        public string next {get; set;}
    }
    
    public class Cursors {
        public String before { get; set; }
        public String after { get; set; }
    }
    
    public class Senders {
        public List<SenderData> data { get; set; }
    }
    
    public class SenderData {
        public String name { get; set; }
        public String email { get; set; }
        public String id { get; set; }
    }
}