using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class QrCodeViewerMenuDelegate extends Ui.MenuInputDelegate {

	function initialize () {
		MenuInputDelegate.initialize ();
	}

	function onMenuItem (item) {
		App.getApp().setProperty("currentId", item.userData);
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
}