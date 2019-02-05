/**
* @author           Patrick Dixon
* @description      Controller for the MID Schedule list page
*                   All MID pages must extend MIDComMID
* @date             05 Aug 2016
* @LastModifiedDate 18 Jan 2019
* @Change Log       V1.0 Initial Version
                    V1.1 Modifed for VOD Return Changes
*/
public with sharing class MIDComScheduleListController extends MIDComMID {
    
    public ScheduleList schedules {get; set;}
    
    public String showOption {get; set;}
    public String bulkFilter {get; set;}
    public String returnTypeFilter {get; set;}
    public String returnNameFilter {get; set;}
    public String returnStatusFilter {get; set;}
    public String sortFieldName {get; set;}
    public String pageSize {get; set;}
    public String returnType {get; set;}

    public Boolean wasSortedASC {get; set;}
    public String wasSortedBy {get; set;}
    

    /**
    * @description  Schedule List class to implement pagination for the list of schedules
    */
    public class ScheduleList extends Paginator {
        
        private List<MIDComScheduleWrapper> wSchedules;

        /**
        * @description  Constructor
        */
        public ScheduleList() {
            
            if (paginationEnabled == null) paginationEnabled = true;
            if (pageSize == null) pageSize = Integer.valueOf(Paginator.DEFAULT_PAGE_SIZE);
            
            wSchedules = new List<MIDComScheduleWrapper>();
        }
        
        /**
        * @description  Clears the Schedule wrapper list
        */
        public void clear() {
            
            wSchedules.clear();
        }

        /**
        * @description  Adds a Schedule wrapper to the list
        * @
                MIDComScheduleWrapper - the Schedule wrapper to be added
        */
        public void add(MIDComScheduleWrapper wSchedule) {
            
            wSchedules.add(wSchedule);
        }

        /**
        * @description  Returns the number of selected schedules
        * @return       Integer - number of selected Schedules
        */
        public Integer getSelectedCount() {
            Integer selectedCount = 0;
            for (MIDComScheduleWrapper wSchedule : wSchedules) {
                if (wSchedule.selected) selectedCount++;
            }
            return selectedCount;
        }

        /**
        * @description  Updates the sort order
        * @param    Boolean - true = ASC, false = DESC
        */
        public void sortASC(Boolean sortASC) {
            
            for (MIDComScheduleWrapper wSchedule : wSchedules) {
                wSchedule.sortASC = sortASC;
            }
        }
        /**
        * @description  Updates the sort field
        * @param    String - field name to sort by
        *           (defaults to Account Name)
        */
        public void sortBy(String fieldName) {
            
            for (MIDComScheduleWrapper wSchedule : wSchedules) {
                if (fieldName == 'Category Name') {
                    wSchedule.sortString = wSchedule.schedule.Return_Category_Name__c != null ? wSchedule.schedule.Return_Category_Name__c : '';

                } else if (fieldName == 'Licence Number') {
                    wSchedule.sortString = wSchedule.schedule.Subscription__r.Licence_Number__c != null ? wSchedule.schedule.Subscription__r.Licence_Number__c : '';

                } else if (fieldName == 'Name of Service') {
                    wSchedule.sortString = wSchedule.schedule.Subscription__r.Service_Name__c != null ? wSchedule.schedule.Subscription__r.Service_Name__c : '';

                } 
                /*else if (fieldName == 'Return Frequency') {
                   wSchedule.sortString = wSchedule.schedule.Return_Frequency__c != null ? wSchedule.schedule.Return_Frequency__c : '';
                    
                } */
                else if (fieldName == 'Account') {
                wSchedule.sortString = wSchedule.schedule.Account__r.Name != null ? wSchedule.schedule.Account__c : '';   
   
                } 
                else if (fieldName == 'Return Period') {
                    wSchedule.sortString = wSchedule.schedule.Return_Period_Type__c != null ? wSchedule.schedule.Return_Period_Type__c : '';

                } else if (fieldName == 'Return Year') {
                    wSchedule.sortString = wSchedule.schedule.Return_Period_Year__c != null ? wSchedule.schedule.Return_Period_Year__c : '';

                } else if (fieldName == 'Status') {
                    wSchedule.sortString = wSchedule.status != null ? wSchedule.status : '';

                } else if (fieldName == 'Due Date') {
                    wSchedule.sortString = wSchedule.schedule.Return_Input_Deadline__c != null ? String.valueOf(wSchedule.schedule.Return_Input_Deadline__c) : '';

                } else {        // (fieldName == 'Category Type')
                    wSchedule.sortString = wSchedule.schedule.Return_Category_Type__c != null ? wSchedule.schedule.Return_Category_Type__c : '';
                }
            }
        }

        /**
        * @description  Implementation of pagination
        */
        public list<MIDComScheduleWrapper> getPaginatedSchedules() {
            
            if (!paginationEnabled) return wSchedules;      // pagination not enabled
            list<MIDComScheduleWrapper> paginatedSchedules = new list<MIDComScheduleWrapper>();
            for (object o : paginate(wSchedules)) {
                paginatedSchedules.add((MIDComScheduleWrapper)o);
            }
            return paginatedSchedules;
        }
    }

    /**
    * @description Constructor
    */
    public MIDComScheduleListController() {
        
        // initialise the filters
        showOption = Label.LicensingComShowAll;
        bulkFilter = Label.LicensingComBulkActionsNone;
        returnTypeFilter = 'All return types';      // TO-DO - Labels
        returnNameFilter = 'All return names';
        returnStatusFilter = 'Any Status';
        pageSize = Paginator.DEFAULT_PAGE_SIZE;
        
        // initialise the sort field and order
        sortFieldName = 'Category Type';
        wasSortedBy = sortFieldName;
        wasSortedASC = true;

        // instantiate a new schedule list
        schedules = new ScheduleList();

        // initialise the filtered schedule list
        applyFilters();
        
        // initialise the schedule sort order
        schedules.sortASC(wasSortedASC);
        schedules.sortBy(wasSortedBy);

        // sort the schedule list
        schedules.wSchedules.sort();
        
    }

    /**
    * @description  Changes page view to view a return
    * @return       PageReference - the next page the user is directed to
    */
    public PageReference viewReturn() {
        PageReference retPage;
        MID_Return__c obj = MID_Return__c.getValues('ReadOnlyStatus');
        obj.Set_ReadOnly_Value__c = false;
        update obj;
        
        if(returnType != MIDConstants.ODPS_ACCESS_SERVICE){
            retPage = Page.MIDComViewReturn;
        }
        else
        {
            retPage = Page.MIDReturn;
            retPage.getParameters().put('viewMode', 'true');  
            // add a return type param if return type is ODPS ACCESS SERVICE
            retPage.getParameters().put('returnType', returnType);          
        }
        
        // add a retURL param
        retPage.getParameters().put('retURL', 'MIDComScheduleList');
        
        // add a schedule Id param
        retPage.getParameters().put('scheduleId', scheduleId);               

        retPage.setRedirect(true);
        return retPage;
    }

    /**
    * @description  Changes page view to edit a return
    * @return       PageReference - the next page the user is directed to
    */
    public PageReference amendReturn() {
        PageReference retPage;
        MID_Return__c obj = MID_Return__c.getValues('ReadOnlyStatus');
        obj.Set_ReadOnly_Value__c = false;
        update obj;
        if(returnType != MIDConstants.ODPS_ACCESS_SERVICE){
            retPage = Page.MIDComEditReturn;
        }
        else
        {
         retPage = Page.MIDReturn;
         retPage.getParameters().put('returnType', MIDConstants.ODPS_ACCESS_SERVICE);
         retPage.getParameters().put('viewMode', 'false');
        }
        // add a retURL param
        retPage.getParameters().put('retURL', 'MIDComScheduleList');
        
        // add a schedule Id param
        retPage.getParameters().put('scheduleId', scheduleId);

        retPage.setRedirect(true);
        return retPage;
    }
    
    /**
    * @description  Changes page view to upload an XML attachment for parsing
    * @return       PageReference - the next page the user is directed to
    */
    public PageReference uploadParseXML() {
        PageReference retPage = Page.MIDComReturnUpload;
        
        // add a retURL param
        retPage.getParameters().put('retURL', 'MIDComScheduleList');
        
        // add a schedule Id param
        retPage.getParameters().put('scheduleId', scheduleId);
        
        retPage.setRedirect(true);
        return retPage;
    }     

    /**
    * @description  Sorts the schedule list by field and ascending/descending order
    * @return       void
    */
    public void sortBy() {

        // if the sort field is unchanged
        if (wasSortedBy == sortFieldName) {

            // toggle the sort order
            schedules.sortASC(!wasSortedASC);
            wasSortedASC = !wasSortedASC;

        } else {
            
            // update the sort field
            schedules.sortBy(sortFieldName);
            wasSortedBy = sortFieldName;
            wasSortedASC = true;
            schedules.sortASC(wasSortedASC);
        }

        // re-sort the licence list
        schedules.wSchedules.sort();

        // reset the pagination
        schedules.first();
    }

    /**
    * @description  Applies the schedule Type and schedule name filters to the schedule list
    * @return       void
    */
    public void applyFilters() {

        // clear the licence list
        schedules.clear();
        
        // clear 'show selected' state
        showOption = Label.LicensingComShowAll;
        
        Boolean addSchedule;
        
        // add the licences that match filter criteria
        for (MIDComScheduleWrapper wSchedule : wSchedules) {
    
            addSchedule = false;
            if (returnTypeFilter == 'All return types') addSchedule = true;
            else if (returnTypeFilter == wSchedule.schedule.Return_Category_Type__c) addSchedule = true;
                
            if (addSchedule) {
                addSchedule = false;
                if (returnNameFilter == 'All return names') addSchedule = true;
                else if (returnNameFilter == wSchedule.schedule.Return_Category_Name__c) addSchedule = true;
            }
            
            if (addSchedule) {
                addSchedule = false;
                if (returnStatusFilter == 'Any Status') addSchedule = true;
                else if (returnStatusFilter == wSchedule.status) addSchedule = true;
            }
            
            if (addSchedule) {
                addSchedule = false;
                if (bulkFilter == Label.LicensingComBulkActionsNone) addSchedule = true;
            }
            
            if (addSchedule) schedules.add(wSchedule);
        }
        
        // sort the licence list
        schedules.wSchedules.sort();
        
        // reset the pagination
        schedules.first();
    }

    // TO-DO - move these into helper class to cover both Licencing and MID
    /**
    * @description  Gets the list of show options
    * @return       List<SelectOption> - list of show options
    */
    public List<SelectOption> getshowOptions() {
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption(Label.LicensingComShowAll, Label.LicensingComShowAll));
        options.add(new SelectOption(Label.LicensingComShowSelected, Label.LicensingComShowSelected));

        return options;
    }

    /**
    * @description  Gets the list of return types from those available
    * @return       List<SelectOption> - list of return types to filter by
    */
    public List<SelectOption> getReturnTypeFilters() {
        
        List<SelectOption> options = new List<SelectOption>();
        Set<String> returnTypes = new Set<String>();
        
        options.add(new SelectOption('All return types', 'All return types'));      // TO-DO - Labels
        
        // add all schedules from the list of schedules
        for (MIDComScheduleWrapper wSchedule : wSchedules) {
            
            String returnType = wSchedule.schedule.Return_Category_Type__c;
            if (returnType != null && !returnTypes.contains(returnType)) {
                returnTypes.add(returnType);
                options.add(new SelectOption(returnType, returnType));
            }
        }
        
        return options;
    }

    /**
    * @description  Gets the list of return names from those available
    * @return       List<SelectOption> - list of return names to filter by
    */
    public List<SelectOption> getReturnNameFilters() {

        List<SelectOption> options = new List<SelectOption>();
        Set<String> returnNames = new Set<String>();
        
        options.add(new SelectOption('All return names', 'All return names'));      // TO-DO - Labels
        
        // add all schedules from the list of schedules
        for (MIDComScheduleWrapper wSchedule : wSchedules) {
            
            String returnName = wSchedule.schedule.Return_Category_Name__c;
            if (returnName != null && !returnNames.contains(returnName)) {
                returnNames.add(returnName);
                options.add(new SelectOption(returnName, returnName));
            }
        }

        return options;
    }

    /**
    * @description  Gets the list of return statuses from the picklist field
    * @return       List<SelectOption> - list of return statuses to filter by
    */
    public List<SelectOption> getReturnStatusFilters() {
        
        List<SelectOption> options = new List<SelectOption>();      // TO-DO - Labels
        
        options.add(new SelectOption('Any Status', 'Any Status'));
        
        for (String status : MIDConstants.SCHEDULE_STATUS_MAP.keySet()) {
            options.add(new SelectOption(MIDConstants.SCHEDULE_STATUS_MAP.get(status), MIDConstants.SCHEDULE_STATUS_MAP.get(status)));
        }
        return options;
    }

    // TO-DO - make pagination utility class for licences/schedules

    /**
    * @description  Applies the pagination page size setting
    * @return       void
    */
    public void applyPageSize() {

        if (pageSize != Label.LicensingComPaginationAllRecords) {
            schedules.paginationEnabled = true;
            schedules.pageSize = Integer.valueOf(pageSize);
            
        } else {
            schedules.paginationEnabled = false;
        }

        // reset the pagination
        schedules.first();
    }

    /**
    * @description  Gets the list of pagination page size options
    * @return       List<SelectOption> - list of page sizes
    */
    public List<SelectOption> getPageSizeSettings() {
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption(String.valueOf(5), String.valueOf(5)));
        options.add(new SelectOption(String.valueOf(10), String.valueOf(10)));
        options.add(new SelectOption(String.valueOf(25), String.valueOf(25)));
        options.add(new SelectOption(String.valueOf(50), String.valueOf(50)));
        options.add(new SelectOption(Label.LicensingComPaginationAllRecords, Label.LicensingComPaginationAllRecords));
        
        return options;
    }

}