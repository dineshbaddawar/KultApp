public class ScheduleInstagramBatchForMentions implements schedulable {
    public void execute(SchedulableContext sc){
       InstagramMentionCreationBatch batch = new InstagramMentionCreationBatch();
       Database.executeBatch(batch);
    }
}