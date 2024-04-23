public class ScheduleInstagramBatchForPosts implements schedulable {
    public void execute(SchedulableContext sc){
        InstagramPostCreationBatch batch = new InstagramPostCreationBatch();
        Database.executeBatch(batch);
    }
}