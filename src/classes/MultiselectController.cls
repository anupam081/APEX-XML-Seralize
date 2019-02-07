public with sharing class MultiselectController {
    
    @AuraEnabled
    public static List<Contact> getcontactDetails(){

        List<Contact> lstContact=[Select Id, Name From Contact limit 100];

        return lstContact;

    }
}