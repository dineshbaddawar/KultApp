/**
 * @author [Dinesh Baddawar]
 * @email dinesh.b@utilitarianLab.com
 * @create date 2024-03-05 10:59:36
 * @modify date 2024-03-05 10:59:36
 * @desc [description]
 */

public with sharing class InboungFlowHelper {

    public Account AccRec {get;set;}
    public String AccountRecordString{get;set;}
    Public InboungFlowHelper() {
        try{
            String recordId = Apexpages.currentPage().getParameters().get('id'); 
            AccRec = [SELECT Id,Name,Phone,Email__c,Mobile_Phone__c FROM Account WHERE ID =:recordId];
            System.debug('AccRec ::'+AccRec);
            AccountRecordString=JSON.serialize(AccRec);
        }catch(Exception e){
            System.debug('Error ::'+e.getMessage() + ' Error Line ::'+e.getLineNumber());
        }
    }
    
    // Method for getting Account Details Based on Phone no from Inbound call log
    @AuraEnabled 
    public static Account getAccountDetailsBasedPhone(String InboundPhone){
        Account accRec = new Account();
        try{
          if(InboundPhone !=null){
            accRec = [SELECT Id,Name,Phone FROM Account WHERE Phone =:InboundPhone LIMIT 1];
            if(accRec !=null){
                System.debug('accRec === >'+accRec);
                return accRec;
            }else{
                return null;
            }
          }
        }catch(Exception e){
                System.debug('The Error '+e.getMessage()+' && Erron Line '+e.getLineNumber());
        }
        return null;
    }
    
    // Method to Update CTI phone & Primary Phone in Account Record Details
    @AuraEnabled 
    public static Account updateCTIPhonePrimaryPhoneOnAccount(string primaryPhone,string alternatePhone, string recordId){
        Account accUpdate = new Account();
        
        try{
            if(recordId !=null){
                accUpdate = [SELECT Id,Phone,Name,Alternate_Phone_No__c FROM Account WHERE Id=:recordId LIMIT 1];
                if(primaryPhone !=null){
                    accUpdate.Phone = primaryPhone;
                }
                if(alternatePhone != null){
                    accUpdate.Alternate_Phone_No__c =alternatePhone; 
                }
                Update accUpdate;
                System.debug('accUpdate === >'+accUpdate);
                if(accUpdate !=null){
                    return accUpdate;
                }
            }
        }catch(Exception e){
        System.debug('The Error '+e.getMessage() +  ' && Erron Line '+e.getLineNumber());
        }
        return null;
    }

    // Method to get All Fields Name From Account
    @AuraEnabled
    public static List<String> getAccountFieldSetListss(){
        try{
            List<String> AccountFieldSetList = new List<String>();
            List<Schema.FieldSetMember> FieldSetListFromAccount  = SobjectType.Account.FieldSets.AccountFieldSet.getFields();
            System.debug('FieldSetListFromAccount === >'+FieldSetListFromAccount);
            for(Schema.FieldSetMember fieldsToAdd : FieldSetListFromAccount){
                System.debug('Fields === >'+String.valueOf(fieldsToAdd.sobjectfield));
                AccountFieldSetList.add(String.valueOf(fieldsToAdd.sobjectfield));
            }
            if(AccountFieldSetList.size()>0){
                System.debug('AccountFieldSetList === >'+AccountFieldSetList);
                return AccountFieldSetList;
            }
        }catch(Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }

    // Method for finding Account Using Primary Phone
    @AuraEnabled 
    public static Account findAccountUsingPhone(String accountPrimaryPhone){
        Account accoundFindRec = new Account();
        try{
            if(accountPrimaryPhone !=null){
                accoundFindRec = [SELECt Id,Name,Phone FROM Account WHERE Phone=:accountPrimaryPhone LIMIT 1];
                if(accoundFindRec !=null){
                    return accoundFindRec;
                }else{
                    return null;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }

     // Method for Creating New Account
     @AuraEnabled 
     public static Account createNewAccount(String Accountname,String AccountPrimaryPhone,String alertnatePhone){
        try{
            if(Accountname !=null){
                Account accRec = new Account();
                accRec.Name = Accountname;
                if(AccountPrimaryPhone !=null){
                    accRec.Phone = AccountPrimaryPhone;
                }
                if(alertnatePhone !=null){
                    accRec.Alternate_Phone_No__c = alertnatePhone;
                }
                insert accRec;
                System.debug('Account Created == >'+accRec);
                if(accRec !=null){
                    return accRec;
                }else{
                    return null;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
     }
}