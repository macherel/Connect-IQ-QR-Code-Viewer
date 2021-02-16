using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Communications as Comm;

class QRCodeViewerApp extends App.AppBase {

	var enabledCodes = [];
	var loadingCache = 0;
	var latlng = null;
	var status = :UNKNOWN;

	////////////////////////////////////////////////////////////////
	// Callbacks
	////////////////////////////////////////////////////////////////

	function onReceive(responseCode, data) {
		System.println("Receiving data (" + responseCode + "): " + data);
		var app = App.getApp();
		loadingCache--;
		if (responseCode == 200) {
			var id = data["id"];
			app.setProperty("cacheValue" + id, data["data"]);
			app.setProperty("cacheData"  + id, data["response"]);
			System.println("Cache data #" + id + " loaded");
		} else {
			System.println("Error while loading data : " + responseCode);
			// nothing to do, data will be store next time
		}
		if(loadingCache==0) {
			Ui.requestUpdate();
		}
	}

	////////////////////////////////////////////////////////////////
	// Private methods
	////////////////////////////////////////////////////////////////
	
	function getCodeIndex(id) {
		for(var i=0; i<enabledCodes.size(); i++) {
			if(enabledCodes[i].id == id) {
				return i;
			}
		}
		return -1;
	}

	function loadQRCodeData(code) {
		var id = code.id;
		System.println("Initialize QR code #" + id);
		var app = App.getApp();
		if(Settings.cacheEnabled) {
			loadingCache++;
			var strUrl = "https://data-manager-api.qrcode.macherel.fr/codes/";
			strUrl += "?id=" + Communications.encodeURL(id.format("%d"));
			strUrl += "&text=" + Communications.encodeURL(code.value);
			strUrl += "&bcid=" + Communications.encodeURL(code.type);
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
		var code = Code.fromSettings(id);
		System.println("Initialize code " + code);
		var cacheValue = code.cache;
		if(code.enabled && !isNullOrEmpty(code.label) && !isNullOrEmpty(code.value)) {
			// The QR Code exist, we have to handle with it
			if(code.value != null && code.cache == null) {
				loadQRCodeData(code);
			}
			System.println("Add QR code #" + id);
			enabledCodes.add(code);
		} else if(Settings.currentId == id) {
			System.println("Reset currentId");
			Settings.setCurrentId(null);
		} else  {
			System.println("Code not loaded");
		}
	}

	function initQRCodes() {
		System.println("init QR codes...");
		enabledCodes = [];
		for(var i=1; i<=8; i++) {
			initQRCodeSettings(i);
		}
		if(loadingCache==0) {
			setStatus(:READY);
			Ui.requestUpdate();
		}
	}

	function handleSettings() {
		System.println("Handle settings...");
		Settings.load();
		System.println(
			"Settings = {"
			+ "barcodeHeight: " + Settings.barcodeHeight
			+ ", cacheEnabled: " + Settings.cacheEnabled
			+ ", currentId: " + Settings.currentId
			+ ", displayLabel: " + Settings.displayLabel
			+ ", offsetY: " + Settings.offsetY
			+ ", retainMenuIndex: " + Settings.retainMenuIndex
			+ ", size: " + Settings.size
			+ "}"
		);
		
		var app = App.getApp();
		initQRCodes();
	}

	function setStatus(newStatus) {
		if(status == newStatus) {
			return;
		}
		System.println("set status : " + newStatus);
		status = newStatus;
		Ui.requestUpdate();
	}

	function orderCodes() {
	}

	////////////////////////////////////////////////////////////////
	// Public methods
	////////////////////////////////////////////////////////////////

	function initialize() {
		System.println("App initialization...");
		AppBase.initialize();
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