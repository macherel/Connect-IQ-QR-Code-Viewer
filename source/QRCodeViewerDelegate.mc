using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;

class QRCodeViewerDelegate extends Ui.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onSelect() {
		var app = App.getApp();
		var codes = app.codes;
		
		if(codes.size() > 0) {
			var qrCodesMenu = [];
			for(var i=0; i<codes.size(); i++) {
				var code = codes[i];
				qrCodesMenu.add(new DMenuItem(i, code["label"], code["data"], code));
			}
			var view = new DMenu(qrCodesMenu, Ui.loadResource(Rez.Strings.mainMenuTitle));
	
			Ui.pushView(view, new DMenuDelegate(view, new QrCodeViewerMenuDelegate()), Ui.SLIDE_IMMEDIATE);
		} else {
			app.setProperty("data", null);
			app.setProperty("message", Ui.loadResource(Rez.Strings.errorNoQRCode));
			Ui.requestUpdate();
		}

		return true;
	}
	function onMenu() {	return onSelect(); }
}
