using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Communications as Comm;

class QRCodeViewerApp extends App.AppBase {

	var enabledCodeIds = [];
	var loadingCache = 0;
	var latlng = null;

	function isNullOrEmpty(str) {
		return str == null || str.length() == 0;
	}

	function hasToken() {
		var app = App.getApp();
			return !isNullOrEmpty(app.getProperty("token"));
	}

	function canUseExternalData() {
		var app = App.getApp();
		return app.getProperty("externalDatasEnabled") && hasToken();
	}
	function canUseExternalDataWithPosition() {
		var app = App.getApp();
		return app.getProperty("usePosition")
			&& canUseExternalData();
	}

	function onPosition(info) {
		System.println("Position received : " + info);
		var myLocation = info.position.toDegrees();
		latlng = {
			:lat => myLocation[0],
			:lng => myLocation[1]
		};
		loadQRCodes();
	}

	function onReceive(responseCode, data) {
		System.println("Receiving data (" + responseCode + "): " + data);
		var app = App.getApp();
		loadingCache--;
		if (responseCode == 200) {
			var id = data["id"];
			app.setProperty("cacheValue" + id, data["data"]);
			app.setProperty("cacheData"  + id, data["response"]);
			System.println("Cache data #" + id + " loaded");
		} else if (responseCode == 401 && !isNullOrEmpty(data["id"])) {
			var id = data["id"];
			app.setProperty("cacheValue" + id, null);
			app.setProperty("cacheData"  + id, null);
			System.println("Invalid token while loading data #" + id);
		} else {
			System.println("Error while loading data");
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
		var token = app.getProperty("token");
		if(app.getProperty("cacheEnabled") && (!isNullOrEmpty(token) || id==1)) {
			loadingCache++;
			var type = app.getProperty("codeType" + id);
			if(isNullOrEmpty(type)) {
				type = "qrcode";
			}
			var strUrl = "https://data-manager-api.qrcode.macherel.fr/codes/";
			strUrl += "?id=" + Communications.encodeURL(id.format("%d"));
			strUrl += "&text=" + Communications.encodeURL(app.getProperty("codeValue" + id));
			strUrl += "&bcid=" + Communications.encodeURL(type);
			strUrl += "&token=" + Communications.encodeURL(token);
			System.println("Loading cached data #" + id + " from " + strUrl);
			Comm.makeWebRequest(
				strUrl,
				{},
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
			// Reset cached value
			cacheValue = null;
			app.setProperty("cacheData" + id, null);
		}
		if(enable && !isNullOrEmpty(label) && !isNullOrEmpty(value)) {
			// The QR Code exist, we have to handle with it
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
				app.setProperty("codeEnable" + id, true);
				app.setProperty("codeLabel"  + id, qrCodes[i]["name"]);
				app.setProperty("codeType"   + id, qrCodes[i]["type"]);
				app.setProperty("codeValue"  + id, qrCodes[i]["value"]);
				app.setProperty("cacheValue" + id, qrCodes[i]["value"]);
				app.setProperty("cacheData"  + id, qrCodes[i]["encodedData"]);
				System.println("QR code #" + id + " \"" + qrCodes[i]["name"] + "\" received.");
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
		if(!canUseExternalData()) {
			return;
		}

		System.println("Loading QR codes...");
		var app = App.getApp();
		var strUrl = "https://data-manager-api.qrcode.macherel.fr/users/" + app.getProperty("token");
		if(latlng != null && canUseExternalDataWithPosition()) {
			strUrl += "?lat=" + latlng[:lat];
			strUrl += "&lng=" + latlng[:lng];
		}
		System.println("Loading QR codes from " + strUrl);
		Comm.makeWebRequest(
			strUrl,
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
		if(canUseExternalDataWithPosition()) {
			System.println("Requesting position...");
			Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
		} else if(canUseExternalData()) {
			loadQRCodes();
		}
		if(app.getProperty("CustomizeQRCodeGeneratingURL") == false || isNullOrEmpty(app.getProperty("QRCodeGeneratingURL"))) {
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
		System.println("onStart : " + state);
	}

	// onStop() is called when your application is exiting
	function onStop(state) {
		System.println("onStop : " + state);
	}

	// Return the initial view of your application here
	function getInitialView() {
		return [ new QRCodeViewerView(), new QRCodeViewerDelegate() ];
	}

}