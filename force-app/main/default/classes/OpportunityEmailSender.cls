public class OpportunityEmailSender {

    public static void sendEmailOnOpportunity(String opportunityId) {
        try {
            // Retrieve Opportunity and related Account details
            Opportunity opp = [SELECT Id, Name, AccountId, Account.Name, Account.Email__c, CloseDate, StageName
                               FROM Opportunity
                               WHERE Id = :opportunityId LIMIT 1];

            // Check if the related Account has an email address
            if (opp.Account != null && opp.Account.Email__c != null) {
                // Build email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {opp.Account.Email__c});
                email.setSubject('Opportunity Update: ' + opp.Name);

                String body = 'Hello,\n\n';
                body += 'This is an update for Opportunity "' + opp.Name + '"\n';
                body += 'Account: ' + opp.Account.Name + '\n';
                body += 'Close Date: ' + opp.CloseDate + '\n';
                body += 'Stage: ' + opp.StageName + '\n\n';
                body += 'Thank you,\nYour Organization';

                email.setPlainTextBody(body);

                // Send email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            } else {
                System.debug('Account does not have an email address');
            }
        } catch (Exception e) {
            // Handle exceptions
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
}