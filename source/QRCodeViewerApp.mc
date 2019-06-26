using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Communications as Comm;

class QRCodeViewerApp extends App.AppBase {

	var enabledCodeIds = [];

	function onReceive(responseCode, data) {
		var app = App.getApp();

		if (responseCode == 200) {
			var id = data["id"];
			app.setProperty("cacheValue" + id, data["data"]);
			app.setProperty("cacheData"  + id, data["response"]);
			System.println("Cache data #" + id + " loaded");
		} else {
			System.println("Error while loading cache #" + id);
		    // nothing to do, data will be store next time
		}
	}
	
	function loadQRCodeData(id) {
		System.println("Initialize QR code #" + id);
		var app = App.getApp();
		app.setProperty("cacheValue" + id, null);
		app.setProperty("cacheData"  + id, null);
		if(app.getProperty("cacheEnabled")) {
			System.println("Loading cache data #" + id);
			Comm.makeWebRequest(
				"https://qrcode.alwaysdata.net/phpqrcode/",
				{
					"id"    => id,
					"data" => app.getProperty("codeValue" + id),
					"token" => app.getProperty("token")
				},
				{
					:methods => Comm.HTTP_REQUEST_METHOD_GET,
					:headers => {
						"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
					},
					:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
				},
				method(:onReceive)
			);
		}
	}
	
	function initQRCodeSettings(id) {
		var app = App.getApp();
		var enable = app.getProperty("codeEnable"  + id);
		var label  = app.getProperty("codeLabel"   + id);
		var value  = app.getProperty("codeValue"   + id);

		if(enable && label != null && label.length() > 0 && value != null && value.length() > 0) {
			var cacheValue = app.getProperty("cacheValue" + id);
			if(value != null && !value.equals(cacheValue)) {
				loadQRCodeData(id);
			}
			System.println("Add QR code #" + id);
			enabledCodeIds.add(id);
		} else if(app.getProperty("currentId") == id) {
			app.setProperty("currentId", null);
		}
	}

	function handleSettings() {
		System.println("Handle settings...");
		var app = App.getApp();
        enabledCodeIds = [];
        for(var i=1; i<=8; i++) {
	    	initQRCodeSettings(i);
    	}
    	if(app.getProperty("CustomizeQRCodeGeneratingURL") == false || app.getProperty("QRCodeGeneratingURL") == null || app.getProperty("QRCodeGeneratingURL").length() == 0) {
    		app.setProperty("QRCodeGeneratingURL", Ui.loadResource(Rez.Strings.defaultQRCodeGeneratingURL));
    	}
	}
	
    function initialize() {
		System.println("App initialization...");
        AppBase.initialize();
        // Force default value for old version
		var app = App.getApp();
        if(app.getProperty("liVersion")==null) {
			app.setProperty("liVersion", 0);
        	app.setProperty("cacheEnabled", true);
        }
        handleSettings();
		System.println("App initialized.");
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