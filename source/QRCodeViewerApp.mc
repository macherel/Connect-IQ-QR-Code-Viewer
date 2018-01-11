using Toybox.WatchUi as Ui;
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
		var app = Application.getApp();
        codes = [];
        for(var i=1; i<=8; i++) {
	    	initQRCodeSettings(
	    		app.getProperty("codeEnable" + i),
	    		app.getProperty("codeLabel" + i),
	    		app.getProperty("codeValue" + i)
	    	);
    	}
    	if(app.getProperty("CustomizeQRCodeGeneratingURL") == false || app.getProperty("QRCodeGeneratingURL") == null || app.getProperty("QRCodeGeneratingURL").length() == 0) {
    		app.setProperty("QRCodeGeneratingURL", Ui.loadResource(Rez.Strings.defaultQRCodeGeneratingURL));
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