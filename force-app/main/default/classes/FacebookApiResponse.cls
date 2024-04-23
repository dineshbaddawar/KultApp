public class FacebookApiResponse {
    public List<DataWrapper> data { get; set; }
    public PagingWrapper paging { get; set; }

    public class DataWrapper {
        public String media_url { get; set; }
        public Integer comments_count { get; set; }
        public String permalink { get; set; }
        public String caption { get; set; }
        public String media_type { get; set; }
        public String shortcode { get; set; }
        public String timestamp { get; set; }
        public String username { get; set; }
        public CommentsWrapper comments { get; set; }
        public String id { get; set; }
    }

    public class CommentsWrapper {
        public List<CommentData> data { get; set; }
    }

    public class CommentData {
        public String id { get; set; }
        public Integer like_count { get; set; }
        public String username { get; set; }
        public String user { get; set; }
        public CommentMedia media { get; set; }
        public RepliesWrapper replies { get; set; }
        public String text { get; set; }
        public String timestamp { get; set; }
    }

    public class CommentMedia {
        public String id { get; set; }
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

    public class PagingWrapper {
        public CursorsWrapper cursors { get; set; }
    }

    public class CursorsWrapper {
        public String before { get; set; }
        public String after { get; set; }
    }
}