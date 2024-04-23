public class ScheduleInstagramBatchForHashTags implements schedulable {
    private static Instagram_Api_Details__c fap = Instagram_Api_Details__c.getInstance();	
    private static final String hashTag         = fap.HashTag__c;
    public void execute(SchedulableContext sc){
         InstagramHashTagCreationBatch batch = new InstagramHashTagCreationBatch();
         Database.executeBatch(batch);
    }
}