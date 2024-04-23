public class SelectMemberController {
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getAllProfiles(){
       Map<String, Object> mapOfAllProfiles = new Map<String, Object>();

    // Query profiles
    List<Profile> profiles = [SELECT Id, Name FROM Profile];
    
    for (Profile prof : profiles) {
        Map<String, Object> profileDetails = new Map<String, Object>();
        profileDetails.put('ProfileId', prof.Id);
        profileDetails.put('ProfileName', prof.Name);

        // Query users associated with the profile
        List<User> users = [SELECT Id, Name FROM User WHERE ProfileId = :prof.Id];
        List<Map<String, String>> userList = new List<Map<String, String>>();
        
        for (User usr : users) {
            Map<String, String> userMap = new Map<String, String>();
            userMap.put('UserId', usr.Id);
            userMap.put('UserName', usr.Name);
            userList.add(userMap);
        }

        profileDetails.put('Users', userList);
        mapOfAllProfiles.put(prof.Id, profileDetails);
    }

    return mapOfAllProfiles;
  }
}