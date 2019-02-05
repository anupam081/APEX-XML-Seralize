/*********************************************************************
# File....................: MIDReturnController
# Version.................: 1.0
# Created by..............: NIIT Technologies
# Description.............: This class is used for the MID return pages. All MID pages must extend LicensingComUserManagement
# VF Page.................: MID_Return
# VF Component............: NA
# Test Class..............: NA
# Change Log..............: Added Comment.
# Last Modified Date......: 22 Jan 2019.
**********************************************************************/
// TO-DO - review sharing.  Without sharing required on this class to save records
public class MIDReturnController extends MIDComMID {
    //Variable Declaration of class 
    /* Start- ****Properties related to MID return comman finctionality*/ 
    public Account personAccount {get; set;}                
    public Organisational_Role__c orgRole {get; set;} 
    public Boolean previousEnabled {get; set;}
    public Boolean nextEnabled {get; set;}
    public String returnType {get; set;}
    public String returnLicence {get; set;}
    public String returnChannel {get; set;}
    public String returnPeriod {get; set;}
    public Boolean isPostTelecom {get; set;}    
    public Integer pageIndex {get; set;}
    public Integer selectPageNumber {get; set;} 
    public Integer numberOfPages {get;set;}
    public Boolean readOnly {get; set;}    
    public Boolean declarationAgreement {get; set;}
    public Id rtnScheduleId;
    public String formStep {get; set;}       
    public List<String> list_Tabs{get;set;}
    public String strTabVisible{get;set;}
    public String errorList {get; set;}
    public String getModuleSTR;
    /* End- ****Properties related to MID return*/ 
    /* Start- ****Properties related to VOD Page */ 
    public List<MIDReturn_Utility.wrapPlatform> wrapPlatformList {get; set;}
    public List<VOD_Platform__c> VODPlatformList;
    public List<VOD_Platform__c> scheduleMatchedPlatformList;    
    public List<VOD_Platform__c> listToRemove; 
    public List<MID_Returns__c> MIDReturnobjList {get; set;}
    public List<MID_Returns__c> MIDReturnInitialList; 
    public Boolean blankRow;
    public Boolean duplicateRow;
    public Boolean selectedRow;
    public String viewMode{get;set;}
    /* End- ****Properties related to VOD Page */ 
        
    /**
    * @author           : NIIT
    * @date             : 03/01/2019
    * @description      : This is a constructor for variable initialization
    * @param1           : NA
    * @return           : None
    */
    public MIDReturnController() {  
        try{                 
            rtnScheduleId = ApexPages.currentPage().getParameters().get(MIDConstants.SCHEDULEIDVal);            
            getModuleSTR = ApexPages.currentPage().getParameters().get(MIDConstants.RETURNTYPE);                                        
            viewMode = (ApexPages.currentPage().getParameters().get(MIDConstants.VIEWMODE));
            
            //if page opens in View mode then set readOnly variable to True.
            if(viewMode==MIDConstants.TRUEVal){  
                readOnly = true;
            }else{                
                readOnly = false;
            }        
            errorList = '';
            //Get person account detail
            personAccount = getUserAccountDetails();
            //Get org role detail
            orgRole = getOrgRoleDetails(MIDRole.Id);        
            String page = ApexPages.currentPage().getParameters().get(MIDConstants.PAGEVal);
            pageIndex = 0;
            selectPageNumber = pageIndex;
            formStep = MIDConstants.NOTSTARTED;            
            //Initialize VOD specific variables Start
            if(getModuleSTR.contains(MIDConstants.ODPS_ACCESS_SERVICE)){
                strTabVisible = MIDConstants.VOD_PLATEFORMS;
                wrapPlatformList = new List<MIDReturn_Utility.wrapPlatform>();
                VODPlatformList = new List<VOD_Platform__c>();
                list_Tabs = MIDReturnDefinition.VODDefinition_Map.get(MIDConstants.TABS);
                numberOfPages = list_Tabs.size();
            }
            MIDReturnobjList = new List<MID_Returns__c>();
            MIDReturnInitialList = new List<MID_Returns__c>();
            nextEnabled = True;
            blankRow = false;
            duplicateRow = false;
            selectedRow = false;
            //Initialize VOD specific variables End
            onLoad();                          
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));            
        }
    }
            
    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : overriding method of parent class and overriding initial properties   
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public override PageReference onPageLoad() {
        try{
            String URL = ApexPages.currentPage().getUrl().split(MIDConstants.SPLITVAl)[0];
          
            if (URL.contains(MIDConstants.VIEWRETURN)) {
                readOnly = true;
                // if return type is TV ODPS return MIDReturn Page
                if(getModuleSTR.contains(MIDConstants.ODPS_ACCESS_SERVICE)){
                    return Page.MIDReturn;        
                }                            
            }      

            return super.onPageLoad();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
            return null;
        }
    }

    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : Overriding method of parent class and overriding initial properties   
        * @param1      : NA
        * @param2      : NA
        * @return      : NA
    */
    public override void initialise() {
        
         initialised = true;
            String URL = ApexPages.currentPage().getUrl().split(MIDConstants.SPLITVAl)[0];            
            if (URL.contains(MIDConstants.SUBMITRETURN)) {
                if (!(wSchedule.hasSubmitPermission && wSchedule.status == MIDConstants.READY_TO_SUBMIT)) {                
                    // throw exception
                    throw new CommunityException(MIDConstants.RETURN_CANNOT_SUBMITTED);
                }                    
            } else if (URL.contains(MIDConstants.RETURNUPLOAD)) {
                if (!(wSchedule.isUploadable && wSchedule.status <> MIDConstants.SUBMITTED && wSchedule.hasModifyPermission)) {
    
                    // throw exception
                    throw new CommunityException(MIDConstants.RETURN_CANNOT_UPLOADED);
                }                
            } else if (URL.contains(MIDConstants.EDITRETURN)) {
                if (readOnly) {
                    if (wSchedule.isUploadable || !wSchedule.hasViewPermission) {
                
                        // throw exception
                        if (isInternalUser) {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,MIDConstants.CANNOT_VIEW_BULK_UPLOAD));
                        } else {
                            throw new CommunityException(MIDConstants.RETURN_CANNOT_VIEWD);
                        }
                    }
                } else if (wSchedule.isUploadable || !wSchedule.hasModifyPermission) {
                
                    // throw exception
                    throw new CommunityException(MIDConstants.RETURN_CANNOT_EDITED);
                }
            }
            returnType = wSchedule.schedule.Return_Category_Type__c + MIDConstants.RETURN_TYPE_CATEGORY_SEPERATOR + wSchedule.schedule.Return_Category_Name__c;
            returnPeriod = wSchedule.schedule.Return_Period_Type__c != null 
                    ? ' ' + MIDConstants.RETURN_HEADING_SEPERATOR + ' ' + wSchedule.schedule.Return_Period_Type__c + MIDConstants.RETURN_PERIOD_TYPE_YEAR_SEPERATOR + wSchedule.schedule.Return_Period_Year__c
                    : ' ' + MIDConstants.RETURN_HEADING_SEPERATOR + ' ' + wSchedule.schedule.Return_Period_Year__c;
                    
            returnLicence = wSchedule.schedule.Subscription__c != null 
                    ?  ' ' + MIDConstants.RETURN_HEADING_SEPERATOR + ' ' + wSchedule.schedule.Subscription__r.Licence_Number__c + ' '
                    : '';
            
            returnChannel = wSchedule.schedule.Subscription__c != null 
                    ?  ' ' + MIDConstants.RETURN_HEADING_SEPERATOR + ' ' + wSchedule.schedule.Subscription__r.Service_Name__c + ' '
                    : '';     
            
            isPostTelecom = MIDConstants.TELECOMS_AND_POST_TYPES.contains(returnType);
            MIDComEditReturnUtil.quarter=wSchedule.schedule.Return_Period_Type__c != null? wSchedule.schedule.Return_Period_Type__c: 'Q4';
            MIDComEditReturnUtil.year= integer.valueof(wSchedule.schedule.Return_Period_Year__c);  
            
            // allow new single page forms to be ready to submitted immediately
            if (wSchedule.status == MIDConstants.NOTSTARTED) {
                wSchedule.changeStatus(MIDConstants.WORKINPROGRESS);
            }
            enableNavigation();        
    }

    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : Common method for navigation   
        * @param1      : NA
        * @param2      : NA
        * @return      : NA
    */
    private void enableNavigation() {        
        // calling save and upsert while navigating to other tabs
        save();
        upsertMidReturns();   
        previousEnabled = pageIndex > 0;
        nextEnabled = pageIndex < numberOfPages-1;        
    }
    
    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : Method for selecting page during navigation   
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public PageReference selectPage() {
        try{            
            if(save())
            {
                //Get the page index if there is no blank, selected and duplicate rows exists                        
                if(blankRow == false && duplicateRow == false && selectedRow == false)
                {
                    pageIndex = MIDReturn_Utility.getIndex(list_Tabs, strTabVisible);
                }
                else
                pageIndex = 0;
                enableNavigation(); 
            }
            return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
            return null;
        }
    } 
    
    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : Method for previous page navigation  
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public PageReference previous() {
        try{
            if (Save()) {
                //Set page index to pervious page
                if (pageIndex > 0) pageIndex--;
                enableNavigation();
                // get the visible tab
                strTabVisible=list_Tabs[pageIndex];
            }
            return null;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
                return null;
        }
    }
    
    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : Method for next navigation of pages 
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public Pagereference next() {
        try{
            if (Save()) {                    
                if(blankRow == false && duplicateRow == false && selectedRow == false)
                {
                    //Set page index to next page if there is no blank, selected and duplicate rows exists
                    if (pageIndex < numberOfPages-1) pageIndex++;                    
                }
                else
                pageIndex=0;
                enableNavigation();
                //get the visible tab
                strTabVisible=list_Tabs[pageIndex];
            }
            return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
            return null;
        }
    }
    
    
     /**
    * @description  Redirects to the (selectPageNumber) page of the edit page from SubmitReturn Page
    * @return       PageReference - the edit page
    */
    public PageReference jumpToPage() {
        //get index of the current Page from MIDReturnSubmit Page
        pageIndex = MIDReturn_Utility.getIndex(list_Tabs, strTabVisible);
        enableNavigation();
        return Page.MIDReturn;
    }
    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : Method for canceling the current activity   
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public PageReference cancel() {
        try{
            // if there is a retURL return there
            PageReference retPage = returnToCallingPage();
            if (retPage != null){
                // if return type is TV ODPS, put parameters 
                 if(getModuleSTR.contains(MIDConstants.ODPS_ACCESS_SERVICE)){
                    retPage.getParameters().put(MIDConstants.RETURNTYPE, returnType);
                 }   
                 return retPage;   
            } 
             
            // otherwise return to the return schedule list 
            return Page.MIDComScheduleList;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
            return null;
        }
    }
    
    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : Method for saving the tabs data once clicked on 'Save & exit'   
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public Pagereference finish() {      
        try{
          if (save()) 
          {
              // save only if no error exists
            if(blankRow == false && duplicateRow == false && selectedRow == false)
            {     
                upsertMidReturns();                            
                PageReference retPage = returnToCallingPage();
                if (retPage != null) return retPage;            
                return Page.MIDComScheduleList;                                                                                            
            }
         }
        return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
            return null;
        }
    }
    
    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : Method for 'ready to submit' functionality   
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public PageReference readyToSubmit() {
        try{
            if(save())
            {
                // enable ready to submit only if no 
                if(blankRow== false && duplicateRow == false && selectedRow ==false)
                {
                    upsertMidReturns();
                    wSchedule.changeStatus(MIDConstants.SUBMITTOCERTIFY);     // TO-DO - Constants            
                }            
            }            
            return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
            return null;
        }
    }

    /**
        * @author      : NIIT Technologies
        * @date        : 31/12/2018
        * @description : Method for 're-open' functionality   
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public PageReference edit() {   
        try{     
            // status of schedule should be changed to In progress
            wSchedule.changeStatus(MIDConstants.WORKINPROGRESS);
            readOnly=false;
            if(save()){
                upsertMidReturns();
                wSchedule.schedule.Submitted_by__c = null;
                wSchedule.schedule.Submitted_date__c = null;
            }
            return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
            return null;
        }
    }

    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : Method for 'Submit-Return' button click functionality  
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public PageReference submit() {
        try{
            // save all details and submit form by navigating to MIDReturnSubmit page
            if (save()) {
                upsertMidReturns();
                PageReference confirmPage = Page.MIDReturnSubmit;
                // set a retURL param
                confirmPage.getParameters().put(MIDConstants.RETURL, MIDConstants.MIDRETURNURL + wSchedule.schedule.Id);           
                confirmPage.setRedirect(false);
                return confirmPage;
            }
            return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
            return null;
        }    
    }  
      
    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : Submits the return schedule.
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */
    public PageReference confirm() {
        
            // validate acceptance checkbox is checked
            if (!declarationAgreement) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.label.MID_You_must_check_agreement);
                ApexPages.addMessage(myMsg);
                errorList += MIDConstants.DECLARATION_AGREEMENT;
                return null;
            }   
            // save all data, update status of schedule
            if (save()) {
                upsertMidReturns();
                wSchedule.schedule.Submitted_by__c = MIDRole.Id;
                wSchedule.schedule.Submitted_date__c = dateTime.now();
                wSchedule.changeStatus(MIDConstants.SUBMITTED_TO_OFCOM);                
                
                // if there is a retURL return there
                PageReference retPage = returnToCallingPage();
                if(getModuleSTR.contains(MIDConstants.ODPS_ACCESS_SERVICE)){
                    retPage.getParameters().put(MIDConstants.RETURNTYPE, returnType);
                }   
                if (retPage != null) return retPage;
            
                // otherwise return to the return schedule list 
                return Page.MIDComScheduleList;
            }            
            return null;
                   
    }
    
    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : Redirects to the edit org role page.
        * @param1      : NA
        * @param2      : NA
        * @return      : PageReference
    */  
    public Pagereference manageRole() {
        try{
            PageReference retPage = Page.MIDComContactDetailsUpdate;
            
            // add a retURL param
            retPage.getParameters().put(MIDConstants.RETURL, MIDConstants.MIDRETURN_SUBMITURL + wSchedule.schedule.Id);
            
            return retPage;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
            return null;
        }
    }

    
    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : Page will be loaded as per return type.    
        * @param1      : NA
        * @param2      : NA
        * @return      : NA
    */           
    private void onLoad()
    {
        try{
            // return Type is TV ODPS, call onVODLoad
            if(getModuleSTR.contains(MIDConstants.ODPS_ACCESS_SERVICE)){                
                onVODLoad();
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));           
        }    
    }

    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : In case of fresh return,display all the active Platform Name available in VOD Platform  object. Otherwise,display all the platform to the respective return schedule   
        * @param1      : NA
        * @param2      : NA
        * @return      : NA
    */
    private void onVODLoad(){
        wrapPlatformList = new List<MIDReturn_Utility.wrapPlatform>();
        VODPlatformList = new List<VOD_Platform__c>();           
        Set<Id> Ids = new Set<Id>();
        String fltrStr = MIDConstants.RETURN_SCHEDULE_ID_VALUE + rtnScheduleId + MIDConstants.CommaVal;
        scheduleMatchedPlatformList = MIDReturn_Utility.queryObjects(MIDConstants.VODPLATFORMAPI, MIDReturnDefinition.VODDefinition_Map.get(MIDConstants.VODPLATFORMAPI), fltrStr, MIDConstants.SNUM, MIDConstants.ASC_WITHOUT_LIMIT , Ids);
        // if no External VOD platform exists for return schedule
        if(scheduleMatchedPlatformList.size() == 0){
            fltrStr = MIDConstants.RECORDID_VAL + MIDConstants.INTERNAL_VOD_RECORDTYPE + MIDConstants.CommaVal;
            List<VOD_Platform__c> listVODInternal = MIDReturn_Utility.queryObjects(MIDConstants.VODPLATFORMAPI, MIDReturnDefinition.VODDefinition_Map.get(MIDConstants.VODPLATFORMAPI), fltrStr, MIDConstants.SNUM, MIDConstants.ASC_WITHOUT_LIMIT , Ids);               
            // add active internal VOD platforms in list
            for(VOD_Platform__c v: listVODInternal) 
            {
                wrapPlatformList.add(new MIDReturn_Utility.wrapPlatform(v));
                VODPlatformList.add(v);
            }
        }else{
            // add external VOD platforms for return schedule in list
            for(VOD_Platform__c v: scheduleMatchedPlatformList) 
            {
                wrapPlatformList.add(new MIDReturn_Utility.wrapPlatform(v));
                VODPlatformList.add(v);
            }
        }
    }        
   
    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : This function used to add more rows in page block table. 
        * @param1      : NA
        * @param2      : NA
        * @return      : NA
    */          
    public void addVODRow(){
        try{
            blankRow = false;
            duplicateRow = false;
            blankRow = MIDReturn_Utility.blankRowExist(VODPlatformList, MIDConstants.PLATFORM_NAME);        
            if(!blankRow) // if blank row is not added check for duplicate row
            {
                duplicateRow = MIDReturn_Utility.duplicateRowExist(VODPlatformList, MIDConstants.PLATFORM_NAME);     
            }
         
            if(blankRow==false && duplicateRow==false) // if no blank row or duplicate row exists, add new row
                {                
                VOD_Platform__c v = new VOD_Platform__c();    
                wrapPlatformList.add(new MIDReturn_Utility.wrapPlatform(v));
                VODPlatformList.add(v);
                }
            else if(blankRow==true) // display error
                {
                    strTabVisible = MIDConstants.VOD_PLATEFORMS; 
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_Please_insert_some_value));
                }
            else if(duplicateRow==true) // display error
                {
                    strTabVisible = MIDConstants.VOD_PLATEFORMS;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_Duplicate_Rows_cannot_be_added));
                }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));          
        }
    }
    
     /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : This Function call on click of 'Save', 'Next' & 'Tab' Button.  
        * @param1      : Na
        * @param2      : Na
        * @return      : Boolean
     */   
    public Boolean save() {
        try{
            // if return type is TV ODPS call saveVOD
            if(getModuleSTR.contains(MIDConstants.ODPS_ACCESS_SERVICE)) 
            {
             return saveVod();
            }else{return null;}            
          }catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
                return null;
           }                   
    }

    /**
        * @author      : NIIT Technologies
        * @date        : 21/01/2019
        * @description : This Function call in save method if Return name is ODPS Access Service.  
        * @param1      : Na
        * @param2      : Na
        * @return      : Boolean
     */   
    public Boolean saveVod() {                    
        Decimal intSerialNumber;
        blankRow= false;
        duplicateRow = false;
        selectedRow=false;
        List<VOD_Platform__c> objVod =new List<VOD_Platform__c>();

        Set<Id> Ids = new Set<Id>();
        String fltrStr =  MIDConstants.RETURN_SCHEDULE_ID_VALUE + rtnScheduleId + MIDConstants.CommaVal;
        objVod = MIDReturn_Utility.queryObjects(MIDConstants.VODPLATFORMAPI, MIDReturnDefinition.VODDefinition_Map.get(MIDConstants.VODPLATFORMAPI), fltrStr, MIDConstants.SNUM, MIDConstants.DESCLIMIT, Ids);                    
        // if VOD Platforms exists, calculate serial number
        If(objVod.size()>0)
        {
            intSerialNumber = (intSerialNumber = objVod[0].Sl_Num__c!=0?objVod[0].Sl_Num__c:0);// get updated serial number 
        }
        else
        {
            intSerialNumber =0;
        }     
        blankRow = MIDReturn_Utility.blankRowExist(VODPlatformList, MIDConstants.PLATFORM_NAME); 
        if(!blankRow)// if blank row is not added check for duplicate row
        {
            duplicateRow = MIDReturn_Utility.duplicateRowExist(VODPlatformList, MIDConstants.PLATFORM_NAME);     
        }
        selectedRow = MIDReturn_Utility.isSelected(wrapPlatformList); 
        // if no error exists allow save
        if(duplicateRow==false && blankRow==false && selectedRow==false)
        {
        List<VOD_Platform__c> listVoD = new List<VOD_Platform__c>();
        Id recTypeId = [SELECT Id, Name FROM RecordType WHERE sObjectType = :MIDConstants.VODPLATFORMAPI and
                        Name = :MIDConstants.EXTERNAL_VOD_RECORDTYPE].id;            
            for(MIDReturn_Utility.wrapPlatform wrapPlatformObj :wrapPlatformList ){
             
                // new VOD Platforms are added
                if(String.isBlank((String)wrapPlatformObj.vod.Return_Schedule_ID__c)&&!(String.isBlank((String)wrapPlatformObj.vod.Platform_Name__c)) )
                { 
                    intSerialNumber++;
                    VOD_Platform__c newVod = new VOD_Platform__c(); 
                    newVod.RecordTypeId = recTypeId;
                    newVod.Return_Schedule_ID__c = rtnScheduleId;
                    newVod.Platform_Name__c= wrapPlatformObj.vod.Platform_Name__c;
                    newVod.Is_Active__c= false;
                    newVod.Sl_Num__c = intSerialNumber;
                    listVoD.add(newVod);                       
                }
                else
                {
                VOD_Platform__c newVod = new VOD_Platform__c(); 
                newVod.Id=wrapPlatformObj.vod.Id;
                newVod.Platform_Name__c= wrapPlatformObj.vod.Platform_Name__c;
                listVoD.add(newVod);             
                }
        
        }
        //upsert VOD Platforms
        if(listVoD.size()>0)
        {
            MIDReturn_Utility.execDMLOperation(listVoD, MIDConstants.UPSERTVal);
        }
        if (wSchedule.status == MIDConstants.NOTSTARTED) {
            wSchedule.changeStatus(MIDConstants.WORKINPROGRESS);
        }
        onLoad();
        }
        else if(blankRow==true) // display error
        {
            strTabVisible = MIDConstants.VOD_PLATEFORMS;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_Please_insert_some_value));
        }
        else if(duplicateRow==true) // display error
        {
            strTabVisible = MIDConstants.VOD_PLATEFORMS;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_Duplicate_Rows_cannot_be_added));
        }
        else if(selectedRow==true) // display error
        {
            strTabVisible = MIDConstants.VOD_PLATEFORMS;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_Please_Delete_the_selected_Row));
        }
        return true;                  
    }

    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : This Function call on click of 'Delete' Button.  
        * @param1      : 
        * @param2      : 
        * @return      : 
     */  
         public Void DeleteVoD()
        {
            try{
                PageReference retPage = Page.MIDReturn;
                Set<Id> idVodToBeRemoved=new Set<Id>();      
                listToRemove = New List<VOD_Platform__c>();
                List<MID_Returns__c> objListMIDReturns=new List<MID_Returns__c>();
                List<MID_Returns__c> objMIdReturns=new List<MID_Returns__c>();
                Map<Id,VOD_Platform__c> mapVodPlatform;
                List<VOD_Platform__c> listTempToRemove = New List<VOD_Platform__c>();
                listToRemove.clear();
                Integer selectedPlat =0;
                Integer blankRowSelected=0;
                // check if blank row is selected and cout number for selected rows
                for ( Integer i = wrapPlatformList.size() - 1; i >= 0; --i )
                {
                    MIDReturn_Utility.wrapPlatform oppWrapObj=wrapPlatformList[i];
                    if (OppWrapObj.selected== True)
                    {
                        if(OppWrapObj.vod.Platform_Name__c!='')
                        {
                            selectedPlat++;
                        }
                        else
                        {
                            blankRowSelected++;
                            wrapPlatformList.remove(i);
                            VODPlatformList.remove(i);
                        }
                        
                    }
                    
                }
                // if all rows are not selected, allow delete
                if(selectedPlat!=wrapPlatformList.size() && selectedPlat >0)
                {
                    for ( Integer i = wrapPlatformList.size() - 1; i >= 0; --i)
                  {
                        MIDReturn_Utility.wrapPlatform oppWrapObj = wrapPlatformList[i];
                        if (OppWrapObj.selected== True && OppWrapObj.vod.Platform_Name__c!='')
                        {                        
                             //External VoD Removal
                             if(oppWrapObj.vod.RecordType.Name==MIDConstants.EXTERNAL_VOD_RECORDTYPE)
                             {
                               idVodToBeRemoved.add(oppWrapObj.vod.Id);
                               listTempToRemove.add(oppWrapObj.vod);                          
                             }
                            wrapPlatformList.remove(i); 
                            VODPlatformList.remove(i);
                        }
                     }
                     
                     if(idVodToBeRemoved.size() > 0){
                        objListMIDReturns = MIDReturn_Utility.queryObjects(MIDConstants.MIDRETURNAPI, MIDReturnDefinition.VODDefinition_Map.get(MIDConstants.MIDRETURNAPI), MIDConstants.PLATFORMIDAPI, '', '', idVodToBeRemoved);
                     }
                     
                     // delete from temperory list
                     if(listTempToRemove.size()>0)
                     {
                         MIDReturn_Utility.execDMLOperation(listTempToRemove, MIDConstants.DELETEVal);                     
                     }
                     // delete from MID return
                     if(objListMIDReturns.size()>0)
                     {
                         MIDReturn_Utility.execDMLOperation(objListMIDReturns, MIDConstants.DELETEVal);                     
                     }
                     // get updated list of platforms to be displayed in MID Return
                     Set<Id> newId=new Set<Id>();
                     for(MIDReturn_Utility.wrapPlatform wrapPlatformObj : wrapPlatformList){
                         newId.add(wrapPlatformObj.vod.Id);
                     }
                     MIDReturnobjList = new List<MID_Returns__c>();
                     List<MID_Returns__c> midReturnList = MIDReturn_Utility.queryObjects(MIDConstants.MIDRETURNAPI, MIDReturnDefinition.VODDefinition_Map.get(MIDConstants.MIDRETURNAPI), MIDConstants.PLATFORMIDAPI, '', '', newId);
                     MIDReturnobjList.addAll(midReturnList);
                     saveVod();
                     onLoad();
                }
                else if(selectedPlat>blankRowSelected) // display error
                {
                     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_CannotDeleteAllPlatform));
                }
                
           }catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));               
           }
        }

    /**
        * @author      : NIIT Technologies
        * @date        : 11/01/2019
        * @description : This Function call on click of 'All Returns Tab', Previous and 'save and exit' Button.  
        * @param1      : NA
        * @param2      : NA
        * @return      : Boolean
    */ 
    public Boolean upsertMidReturns(){
        try{
            // if return type is TV ODPS 
            if(getModuleSTR.contains(MIDConstants.ODPS_ACCESS_SERVICE)) 
            {
                return upsertVODReturns();
            }
            return null;
        }catch(Exception e){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MID_ContactAdminErrorMessage));
        return null;
        } 
    }

      
    /**
        * @author      : NIIT Technologies
        * @date        : 21/01/2019
        * @description : This Function calls in upsertMidReturns method if return name is ODPS Access Service.
        * @param1      : NA
        * @param2      : NA
        * @return      : Boolean
    */ 
    public Boolean upsertVODReturns(){
        // get updated vod platforms ids in Set
        Set<Id> newId=new Set<Id>();
        for(MIDReturn_Utility.wrapPlatform wrapPlatformObj : wrapPlatformList){
            newId.add(wrapPlatformObj.vod.Id);
        }
        Set<Id> newIdClone=new Set<Id>();
        newIdClone=    newId.clone();
        
        MIDReturnInitialList = MIDReturn_Utility.queryObjects(MIDConstants.MIDRETURNAPI, MIDReturnDefinition.VODDefinition_Map.get(MIDConstants.MIDRETURNAPI), MIDConstants.PLATFORMIDAPI,MIDConstants.Vod_SNUM, MIDConstants.ASC_WITHOUT_LIMIT, newId);
        // if no MID Return record is present for VOD Platforms  create blank rows for all platforms
        if(MIDReturnInitialList.size()==0)
        {
            for (Id plat: newId)
            {
                MID_Returns__c midObj = new MID_Returns__c();
                midObj.Plateform_Id__c = plat;
                midObj.Return_Schedule__c=rtnScheduleId;
                MIDReturnInitialList.add(midObj);
            }
            MIDReturn_Utility.execDMLOperation(MIDReturnInitialList, MIDConstants.INSERTVal);              
        }
        else
        {          
            // get all the newly added ids
            Set<id> existId = new Set<Id>();
            Set<id> platformIdsClone = new Set<Id>();
            platformIdsClone=newId;
                
            for (MID_Returns__c MidId : MIDReturnInitialList)
            {
                existId.add(MidId.Plateform_Id__c);
            }
                
            for(Id objId: existId){
                if(platformIdsClone.contains(objId))
                    platformIdsClone.remove(objId);
            }
            // if new platform is added create MID Return blank record for the platform
            if(platformIdsClone.size()>0)
            {
                List<MID_Returns__c> VODRemainingList = new List<MID_Returns__c>(); 
                for (Id plat: platformIdsClone)
                {
                    MID_Returns__c midObj = new MID_Returns__c();
                    midObj.Plateform_Id__c = plat;
                    midObj.Return_Schedule__c=rtnScheduleId;
                    VODRemainingList.add(midObj);
                }
                MIDReturn_Utility.execDMLOperation(VODRemainingList, MIDConstants.INSERTVal);
            }
            else
            {
                // update MID Return records
                MIDReturn_Utility.execDMLOperation(MIDReturnobjList, MIDConstants.UPDATEVal);
            }   
        }
        // get updated list of MID Return records
        MIDReturnobjList = new List<MID_Returns__c>();
        List<MID_Returns__c> midReturnList = MIDReturn_Utility.queryObjects(MIDConstants.MIDRETURNAPI, MIDReturnDefinition.VODDefinition_Map.get(MIDConstants.MIDRETURNAPI), MIDConstants.PLATFORMIDAPI, MIDConstants.Vod_SNUM, MIDConstants.ASC_WITHOUT_LIMIT,newIdClone);
        MIDReturnobjList.addAll(midReturnList);
        return true;  
    }                    
}