public class IndiaStateMap {
    
    public static Map<String, List<String>> getIndiaStateMap() {
        Map<String, List<String>> indiaStateMap = new Map<String, List<String>>();
        
        
        //  List<String> statesInNorthIndia = new List<String>{'Delhi', 'Haryana', 'Himachal Pradesh', 'Jammu and Kashmir', 'Punjab', 'Rajasthan', 'Uttar Pradesh', 'Uttarakhand'};
        List<String> states = new List<String>{
            'Andaman and Nicobar Islands',
                'Andhra Pradesh',
                'Arunachal Pradesh',
                'Assam',
                'Bihar',
                'Chandigarh',
                'Chhattisgarh',
                'Dadra and Nagar Haveli',
                'Daman and Diu',
                'Delhi',
                'Goa',
                'Gujarat',
                'Haryana',
                'Himachal Pradesh',
                'Jammu and Kashmir',
                'Jharkhand',
                'Karnataka',
                'Kerala',
                'Lakshadweep',
                'Madhya Pradesh',
                'Maharashtra',
                'Manipur',
                'Meghalaya',
                'Mizoram',
                'Nagaland',
                'Odisha',
                'Puducherry',
                'Punjab',
                'Rajasthan',
                'Sikkim',
                'Tamil Nadu',
                'Tripura',
                'Uttarakhand',
                'Uttar Pradesh',
                'West Bengal'
                };
                    indiaStateMap.put('India', states);
        
        
        
        return indiaStateMap;
    }
}