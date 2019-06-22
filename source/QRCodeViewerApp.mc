using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class QRCodeViewerApp extends App.AppBase {

	
	var codes = [];

	function onReceive(responseCode, data) {
		var app = App.getApp();

		if (responseCode == 200) {
			app.setProperty("data", data);
		} else {
			app.setProperty("data", null);
			app.setProperty("message", "error: " + responseCode.format("%d"));
		}
		Ui.requestUpdate();
	}
	
	function loadQRCodeData(code) {
		Comm.makeWebRequest(
			"https://qrcode.alwaysdata.net/phpqrcode/",
			{
				"size" => 6,
				"data" => code["value"]
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
	
	function initQRCodeSettings(enable, label, value, cachedValue, cachedData) {
		if(enable && label != null && label.length() > 0 && value != null && value.length() > 0) {
			var code = {
				"label" => label,
				"value" => value,
				"cachedValue" => cachedValue,
				"cachedData"  => cachedData
			};
			if(value != cachedValue) {
				//loadQRCodeData(code);
			}
			codes.add(code);
		}
	}

	function handleSettings() {
        var app = App.getApp();
        codes = [];
        for(var i=1; i<=8; i++) {
	    	initQRCodeSettings(
	    		app.getProperty("codeEnable"  + i),
	    		app.getProperty("codeLabel"   + i),
	    		app.getProperty("codeValue"   + i),
	    		app.getProperty("cachedValue" + i),
	    		app.getProperty("cachedData"  + i)
	    	);
    	}
    	if(app.getProperty("CustomizeQRCodeGeneratingURL") == false || app.getProperty("QRCodeGeneratingURL") == null || app.getProperty("QRCodeGeneratingURL").length() == 0) {
    		app.setProperty("QRCodeGeneratingURL", Ui.loadResource(Rez.Strings.defaultQRCodeGeneratingURL));
    	}
	}
	
    function initialize() {
        AppBase.initialize();
App.getApp().setProperty("data", "foooo");
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