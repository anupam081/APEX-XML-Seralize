public with sharing class MultiselectController {
    
    @AuraEnabled
    public static List<Contact> getcontactDetails(){

        List<Contact> lstContact=[Select Id, Name From Contact limit 100];

        //SObjectType conType = Schema.getGlobalDescribe().get('Contact');
        //List<Schema.PicklistEntry> mfields = conType.getDescribe().fields.getMap().get('LeadSource').getDescribe().getPicklistValues();

        return lstContact;

    }

    @AuraEnabled
    public static List<String> getpicklistvalues(String objName, String fldName){

        if(!string.isblank(objName) && !string.isblank(fldName)){
            List<String> optList = new List<String>();
            SObjectType conType = Schema.getGlobalDescribe().get('Contact');
            List<Schema.PicklistEntry> mfields = conType.getDescribe().fields.getMap().get('LeadSource').getDescribe().getPicklistValues();
        }

        return optList;

    }
}