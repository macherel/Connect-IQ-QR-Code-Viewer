using Toybox.Application as App;
using Toybox.WatchUi as Ui;

module Settings {

	var barcodeHeight;
	var cacheEnabled;
	var currentId;
	var displayLabel;
	var offsetY;
	var retainMenuIndex;
	var size;

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
		displayLabel = app.getProperty("displayLabel");
		offsetY = app.getProperty("offsetY");
		retainMenuIndex = app.getProperty("retainMenuIndex");
		size = app.getProperty("size");
	}

	function setCurrentId(id) {
		currentId = id;
		App.getApp().setProperty("currentId", currentId);
	}
}