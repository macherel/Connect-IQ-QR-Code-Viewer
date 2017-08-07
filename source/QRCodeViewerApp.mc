using Toybox.Application as App;

class QRCodeViewerApp extends App.AppBase {

	
	var codes = [];
	
	function initQRCodeSettings(enable, label, value) {
		if(enable && label != null && label.length() > 0 && value != null && value.length() > 0) {
			codes.add({
				"label" => label,
				"data" => value
			});
		}
	}

	function handleSettings() {
        codes = [];
        for(var i=1; i<=8; i++) {
	    	initQRCodeSettings(
	    		Application.getApp().getProperty("codeEnable" + i),
	    		Application.getApp().getProperty("codeLabel" + i),
	    		Application.getApp().getProperty("codeValue" + i)
	    	);
    	}
	}
	
    function initialize() {
        AppBase.initialize();
        handleSettings();
    }

	function onSettingsChanged() {
		AppBase.onSettingsChanged();
        handleSettings();
	}

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new QRCodeViewerView(), new QRCodeViewerDelegate() ];
    }

}