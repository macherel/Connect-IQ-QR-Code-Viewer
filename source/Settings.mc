using Toybox.Application as App;
using Toybox.WatchUi as Ui;

module Settings {

	var barcodeHeight;
	var cacheEnabled;
	var codeGeneratingURL;
	var currentId;
	var customizeQRCodeGeneratingURL;
	var displayLabel;
	var offsetY;
	var retainMenuIndex;
	var size;
	var token;

	function load() {
		var app = App.getApp();

		// Force default value for old version
		if(app.getProperty("liVersion")==null) {
			app.setProperty("liVersion", 0);
			app.setProperty("cacheEnabled", true);
		}
		

		barcodeHeight = app.getProperty("barcodeHeight");
		cacheEnabled = app.getProperty("cacheEnabled");
		currentId = app.getProperty("currentId");
		codeGeneratingURL = app.getProperty("QRCodeGeneratingURL");
		customizeQRCodeGeneratingURL = app.getProperty("CustomizeQRCodeGeneratingURL");
		displayLabel = app.getProperty("displayLabel");
		offsetY = app.getProperty("offsetY");
		retainMenuIndex = app.getProperty("retainMenuIndex");
		size = app.getProperty("size");
		token = app.getProperty("token");

		if(customizeQRCodeGeneratingURL == false || isNullOrEmpty(codeGeneratingURL)) {
			codeGeneratingURL = Ui.loadResource(Rez.Strings.defaultQRCodeGeneratingURL);
			app.setProperty("QRCodeGeneratingURL", codeGeneratingURL);
		}
	}

	function setCurrentId(id) {
		currentId = id;
		App.getApp().setProperty("currentId", currentId);
	}

	function hasToken() {
		var app = App.getApp();
		return !isNullOrEmpty(Settings.token);
	}

	function canUseExternalData() {
		var app = App.getApp();
		return app.getProperty("externalDatasEnabled") && Settings.hasToken();
	}
	function canUseExternalDataWithPosition() {
		var app = App.getApp();
		return app.getProperty("usePosition")
			&& Settings.canUseExternalData();
	}
}