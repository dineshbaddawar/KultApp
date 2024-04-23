({
	showToast : function(message, title, variant) {
		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: variant,
            mode: 'pester'
        });
        toastEvent.fire();
	}
})