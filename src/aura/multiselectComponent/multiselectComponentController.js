({
    doInit : function(component, event, helper) {
        helper.expenseDetails(component, event, helper);
    },
    handleChange: function (component, event) {
        // Get the list of the "value" attribute on all the selected options
        var selectedOptionsList = event.getParam("value");
        alert("Options selected: '" + selectedOptionsList + "'");
    }
})