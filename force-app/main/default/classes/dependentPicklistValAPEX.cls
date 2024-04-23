public class dependentPicklistValAPEX {
    
    @AuraEnabled
    public static Map<String, List<State>> getCountryStateDependencies(String objectName, String controllingField, String dependentField)
    {
        Map<String, List<State>> controllingInfo = new Map<String, List<State>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            //System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            controllingInfo.put(currControllingValue.getValue(), new List<State>());
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            State stateRec = new State();
            String jsonString = JSON.serialize(currDependentValue);
            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            //System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
            
            Integer baseCount = 0;
            
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
                
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }
                
                if((val & 8) == 8)
                {
                    stateRec.label = currDependentValue.getLabel();
                    stateRec.value = currDependentValue.getValue();
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getValue());
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(stateRec);
                }
                if((val & 4) == 4)
                {
                    stateRec.label = currDependentValue.getLabel();
                    stateRec.value = currDependentValue.getValue();
                   // System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getValue());
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(stateRec);                    
                }
                if((val & 2) == 2)
                {
                    stateRec.label = currDependentValue.getLabel();
                    stateRec.value = currDependentValue.getValue();
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(stateRec);                    
                }
                if((val & 1) == 1)
                {
                    stateRec.label = currDependentValue.getLabel();
                    stateRec.value = currDependentValue.getValue();
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(stateRec);                    
                }
                
                baseCount += 4;
            }            
        }
        
        System.debug('ControllingInfo: ' + controllingInfo);
        
        return controllingInfo;
    }
    class MyPickListInfo {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }
    
    public class State {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
}