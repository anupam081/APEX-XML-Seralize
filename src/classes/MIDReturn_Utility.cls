/*********************************************************************
# File....................: MIDReturn_Utility
# Version.................: 1.0
# Created by..............: NIIT Technologies
# Last Modified Date......: 22/01/2019
# Description.............: This is a utility class for MID Return. All indepedant methods are defined in this class.
# VF Page.................: NA
# Test Class..............: NA
# Change Log..............: NA
**********************************************************************/
Public class MIDReturn_Utility{
    
    /**
        * @author      : NIIT Technologies
        * @date        : 16/01/2019
        * @LastModified: 18/01/2019
        * @description : This Function executes the SOQL query based on giving parameters.  
        * @param1      : Object name
        * @param2      : List of querying fields.
        * @param3      : Filter string.
        * @param4      : Field name to sort the result.
        * @param5      : Sort order and limit variable.
        * @return      : sObjects
    */
    public static List<sObject> queryObjects(String theObject, List<String> theFields, String theFilter, String sortField, String sortOrder, Set<Id> Ids) {
        String theQuery = 'SELECT ' + string.join(theFields, ',');
        theQuery += ' FROM ' + theObject;
        if(!String.isEmpty(theFilter)) {
            theQuery += ' WHERE ' + theFilter;
        }
        if(Ids.size() > 0){
            theQuery += ' IN: Ids';
        }
        if(!String.isEmpty(sortField)) {
            theQuery += ' ORDER BY ' + sortField;
            if(!String.isEmpty(sortOrder)) {
                theQuery += ' ' + sortOrder;
            }
        }
        system.debug('Value of query ******** ' + theQuery);
        return database.query(theQuery);
    }
    
    /**
        * @author      : NIIT Technologies
        * @date        : 18/01/2019
        * @LastModified: 18/01/2019
        * @description : This Function perform all DML operations.  
        * @param1      : sObject List
        * @param2      : DML operation name as string.
        * @return      : Void
    */
     public static void execDMLOperation(List<sObject> sObjectList, String DMLOperationType){
         if(DMLOperationType != '' && sObjectList.size() > 0){
             if(DMLOperationType == MIDConstants.INSERTVal){
                 Insert sObjectList;
             }else if(DMLOperationType == MIDConstants.UPDATEVal){
                 Update sObjectList;   
             }else if(DMLOperationType == MIDConstants.DELETEVal){             
                 Delete sObjectList; 
             }else if(DMLOperationType == MIDConstants.UPSERTVal){
                 Upsert sObjectList;
             }
         }
     }

     /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : Wrapper Class for the vod platform.  
        * @param1      : 
        * @param2      : 
        * @return      : 
    */    
    public class wrapPlatform {
        public VOD_Platform__c vod {get; set;}
        public Boolean selected {get; set;}
 
        //This is the contructor method. 
        public wrapPlatform(VOD_Platform__c v) {
            vod = v;
            selected = false;
        }
    }

    /**
        * @author           : NIIT Technologies
        * @date             : 31/12/2018
        * @LastModifiedDate : 21/01/2019
        * @description      : This Function checks if there is any duplicate row exists in the sObject List.  
        * @param1           : List<sObject>
        * @param2           : String variable to check duplicate row, if there are more then 1 colom to check duplicate then values shoule be comma seperated in this Param.
        * @return           : Boolean 
    */
    public static Boolean duplicateRowExist(List<sObject> sObjectList, String chkDuplicateKey){
        try{
            List<String> findDuplicateKey = new List<String>();            
            findDuplicateKey = chkDuplicateKey.split(',');                                                
            for(Integer i = 0; i < sObjectList.size(); i++)
            {
                for(Integer j = i + 1; j < sObjectList.size(); j++)
                {
                    String allText = '';
                    String lastText = '';
                    for(String str : findDuplicateKey){
                        allText += string.valueof(sObjectList[i].get(str.trim()));
                        lastText += string.valueof(sObjectList[j].get(str.trim()));
                    }                                                             
                    if((allText.toLowerCase()).equals(lastText.toLowerCase()))
                    {                                              
                        return true;
                    }                      
                }                
            }
            return false;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));               
            return null;
        }    
    }

    /**
        * @author           : NIIT Technologies
        * @date             : 31/12/2018
        * @LastModifiedDate : 21/01/2019
        * @description      : This Function checks if there is any duplicate row exists in the sObject List.  
        * @param1           : List<sObject>
        * @param2           : String variable to check duplicate row
        * @return           : Boolean 
    */
    public static Boolean blankRowExist(List<sObject> sObjectList, String chkBlankRowKey){
        try{                                    
            for(Integer i = 0; i < sObjectList.size(); i++)
            {                                          
                if(String.isBlank((String)sObjectList[i].get(chkBlankRowKey.trim()))){                                         
                    return true;
                }                                                     
            }
            return false;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));               
            return null;
        }    
    }

    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : This Function checks if any row in wrapper is selected or not.  
        * @param1      : List<MIDReturn_Utility.wrapPlatform>
        * @param2      : 
        * @return      : Boolean
    */
    public static Boolean isSelected(List<wrapPlatform> wrapList){
        try{
            for(MIDReturn_Utility.wrapPlatform wrapPlatformObj : wrapList){
                if(wrapPlatformObj.selected == true )
                    {                        
                        return True;
                    }                    
            }                
            return false;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));               
            return null;
        }     
    }

    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : Method for getting index of the page.
        * @param1      : NA
        * @param2      : NA
        * @return      : Integer
    */   
     public static Integer getIndex(List<String> list_Tabs, String strTabVisible){       
        Integer counter = 0; 
        for (Integer i = 0;i<list_Tabs.size(); i++)      
        {
            if(strTabVisible == list_Tabs[i])
            {
                return i;
            }
        }
        return counter;        
    }  

}