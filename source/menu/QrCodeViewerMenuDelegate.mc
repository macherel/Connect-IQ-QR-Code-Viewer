using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class QrCodeViewerMenuDelegate extends Ui.MenuInputDelegate {

	function initialize () {
		MenuInputDelegate.initialize ();
	}

	function onMenuItem (item) {
		var app = App.getApp();
		var id = item.userData;
		app.setProperty("currentId", id);
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
}