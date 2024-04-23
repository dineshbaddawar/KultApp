@RestResource(urlMapping='/CustomerCreation')
global class WS_CustomerCreation {
    
    public class OMSToSFDCAccount {

        public String uuid;
        public String mobile_number;
        public String email_id;
        public String name;
	
    }
    global class ResponseBody {
        public String status;
        public String message;
        public String accountId;
    }
	@Httppost
        global static ResponseBody createAccount(){
            RestRequest req = RestContext.request;
            ResponseBody res = new ResponseBody();
            String jsonResponse = '';
            
            try{
                OMSToSFDCAccount requestBody = (OMSToSFDCAccount)JSON.deserialize(req.requestBody.toString(), OMSToSFDCAccount.class);
				
                Account newAccount = new Account();
                newAccount.UUID__c = requestBody.uuid;
                newAccount.Phone = requestBody.mobile_number;
                newAccount.Email__c = requestBody.email_id;
                newAccount.Name = requestBody.name;
                
                insert newAccount;
                //jsonResponse = '{"status":"success", "message":"Account created successfully."}';
                 res.status = 'Success';
                res.message = 'User created successfully';
                res.accountId = newAccount.Id;
            }
            catch (Exception e) {
                 res.status = 'Error';
            	res.message = e.getMessage();
            }
              return res;
            //return jsonResponse;
            
        }


}