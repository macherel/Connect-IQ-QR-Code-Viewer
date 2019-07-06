using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Communications as Comm;

class QRCodeViewerApp extends App.AppBase {

	var enabledCodeIds = [];
	var loadingCache = 0;

	function onReceive(responseCode, data) {
		var app = App.getApp();
		loadingCache--;
		if (responseCode == 200) {
			var id = data["id"];
			app.setProperty("cacheValue" + id, data["data"]);
			app.setProperty("cacheData"  + id, data["response"]);
			System.println("Cache data #" + id + " loaded");
		} else {
			System.println("Error while loading cache #" + id);
			// nothing to do, data will be store next time
		}
		if(loadingCache==0) {
			Ui.requestUpdate();
		}
	}
	
	function loadQRCodeData(id) {
		System.println("Initialize QR code #" + id);
		var app = App.getApp();
		app.setProperty("cacheValue" + id, null);
		app.setProperty("cacheData"  + id, null);
		if(app.getProperty("cacheEnabled") && (app.getProperty("token") != null || id==1)) {
			System.println("Loading cache data #" + id);
			loadingCache++;
			Comm.makeWebRequest(
				"https://qrcode.macherel.fr/phpqrcode/",
				{
					"id"	=> id,
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
		var cacheValue = app.getProperty("cacheValue" + id);
		if(value == null || !value.equals(cacheValue)) {
			cacheValue = null;
			app.setProperty("cacheData" + id, null);
		}
		if(enable && label != null && label.length() > 0 && value != null && value.length() > 0) {
			if(value != null && !value.equals(cacheValue)) {
				loadQRCodeData(id);
			}
			System.println("Add QR code #" + id);
			enabledCodeIds.add(id);
		} else if(app.getProperty("currentId") == id) {
			app.setProperty("currentId", null);
		}
	}

	function initQRCodes() {
		enabledCodeIds = [];
		for(var i=1; i<=8; i++) {
			initQRCodeSettings(i);
		}
		if(loadingCache==0) {
			Ui.requestUpdate();
		}
	}

	function onReceiveQRCodes(responseCode, data) {
		System.println("Receiving QR codes...");
		var app = App.getApp();
		if (responseCode == 200 && data != null) {
			var qrCodes = data["qrcodes"];
			for(var i=0; i<8 && i<qrCodes.size(); i++) {
				var id = i+1;
				app.setProperty("codeEnable"  + id, true);
				app.setProperty("codeLabel"   + id, qrCodes[i]["name"]);
				app.setProperty("codeValue"   + id, qrCodes[i]["value"]);
				System.println("QR code #" + id + " received.");
			}
			initQRCodes();
		} else {
			System.println("Error while loading QR codes (" + responseCode + ")");
			// nothing to do, data will be loaded next time
		}
	}

	/**
	 * Load QR codes from webservice
	 */
	function loadQRCodes() {
		System.println("Loading QR codes...");
		var app = App.getApp();
		Comm.makeWebRequest(
			"https://data-manager-api.qrcode.macherel.fr/users/" + app.getProperty("token"),
			null,
			{
				:methods => Comm.HTTP_REQUEST_METHOD_GET,
				:headers => {
					"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
				},
				:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
			},
			method(:onReceiveQRCodes)
		);
		System.println("QR codes loaded.");
	}

	function handleSettings() {
		System.println("Handle settings...");
		var app = App.getApp();
		initQRCodes();
		if(app.getProperty("externalDatasEnabled") && app.getProperty("token") != null && !app.getProperty("token").equals("")) {
			loadQRCodes();
		}
		if(app.getProperty("CustomizeQRCodeGeneratingURL") == false || app.getProperty("QRCodeGeneratingURL") == null || app.getProperty("QRCodeGeneratingURL").length() == 0) {
			app.setProperty("QRCodeGeneratingURL", Ui.loadResource(Rez.Strings.defaultQRCodeGeneratingURL));
		}
	}

	function initialize() {
		System.println("App initialization...");
		AppBase.initialize();
		var app = App.getApp();
		// Force default value for old version
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