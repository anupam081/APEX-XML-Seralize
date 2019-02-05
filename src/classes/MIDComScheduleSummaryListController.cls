/**
* @author           Patrick Dixon
* @description      Controller for the MID schedule summary list component
* @date             05 Sep 2016
* @LastModifiedDate 18 Jan 2019
* @Change Log       V1.0 Initial Version
                    V1.1 Modified for VOD Return Changes
*/
public with sharing class MIDComScheduleSummaryListController {

    public Id scheduleId {get; set;}      // Id of selected return schedule record
    public Boolean isUploadType {get; set;}
    public String returnType {get; set;}  

    /**
    * @description  Constructor
    */
    public MIDComScheduleSummaryListController() {
        
    }
    
    /**
    * @description  Redirects to the return page
    * @return       PageReference - the next page
    */
    public PageReference complete() {
        PageReference retPage;
        MID_Return__c obj = MID_Return__c.getValues('ReadOnlyStatus');
        obj.Set_ReadOnly_Value__c = false;
        update obj;
        if(returnType != MIDConstants.ODPS_ACCESS_SERVICE){
            retPage = isUploadType ? Page.MIDComReturnUpload : Page.MIDComEditReturn;
        }
        else
        {
            retPage = isUploadType ? Page.MIDComReturnUpload : Page.MIDReturn;
            //add a return type param if return type is ODPS ACCESS SERVICE
            retPage.getParameters().put('returnType', returnType);
        }

        // add a retURL param
        retPage.getParameters().put('retURL', 'MIDComDashboard');
        
        // add a schedule Id param
        retPage.getParameters().put('scheduleId', scheduleId);               

        retPage.setRedirect(true);
        return retPage;
    }
     
}