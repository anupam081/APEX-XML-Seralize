/**
* @author           NIIT
* @description      Definition for MID Return 
* @date             03 Jan 2019
* @LastModifieddate 17 Jan 2019
*/
// TO-DO - review sharing.  Without sharing required on this class to create new return record structure
public without sharing class MIDReturnDefinition {    
    public final static Map<String, List<String>> VODDefinition_Map = new Map<String, List<String>>{'Tabs' => new List<String>{'Platform', 
                                                                                                                               'VOD Returns'},
                                                                                                    'Platform' => new List<String>{'VOD_Platform__c'},
                                                                                                    'VOD Returns' => new List<String>{'MID_Returns__c'},
                                                                                                    'VOD_Platform__c' => new List<String>{'Id',
                                                                                                                                          'Sl_Num__c',
                                                                                                                                          'Return_Schedule_ID__c',
                                                                                                                                          'Platform_Name__c',
                                                                                                                                          'Account_ID__c',
                                                                                                                                          'Is_Active__c',                                                                                                                                          
                                                                                                                                          'RecordType.Name'} ,
                                                                                                    'MID_Returns__c' => new List<String>{'Individual_Programs_Provided_With_Audio__c', 
                                                                                                                                         'Individual_Programs_Provided_With_Sign__c',
                                                                                                                                         'Individual_Programs_Provided_With_Subt__c', 
                                                                                                                                         'Program_Hours_Provided_With_Audio_Desc__c',
                                                                                                                                         'Program_Hours_Provided_With_Signing__c', 
                                                                                                                                         'Program_Hours_Provided_With_Subtitles__c',
                                                                                                                                         'Total_Hours_Of_Programming__c', 
                                                                                                                                         'Total_Number_Of_Programs__c', 
                                                                                                                                         'Plateform_Id__c', 
                                                                                                                                         'Plateform_Id__r.Platform_Name__c'}};
}