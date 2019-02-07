({
    expenseDetails : function(component, event, helper) {
    
    var action = component.get("c.getcontactDetails"); //Calling Apex class controller 'getTemplateRecrod' method
    
    action.setCallback(this, function(res) {
    console.log(res.getState());
    var state = res.getState();
    
    if (component.isValid() && state === "SUCCESS") {
        var contacts = res.getReturnValue();
        console.log(contacts);
        var options = [];
        contacts.forEach(function(cont)  { 
            console.log(cont);
            options.push({ value: cont.Name, label: cont.Name});
        });
        component.set("v.lstContactData", options); 
   
    } else {    
        var toastEvent = $A.get("e.force:showToast");    
        toastEvent.setParams({    
        "title": "Error :",    
        "mode": "sticky",    
        "message": res.getError()[0].message    
        });
    
        toastEvent.fire();
    
    }
    
    });
    
    $A.enqueueAction(action);
    
    }
    
    })