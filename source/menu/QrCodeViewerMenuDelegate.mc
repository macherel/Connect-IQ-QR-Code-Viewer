using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class QrCodeViewerMenuDelegate extends Ui.MenuInputDelegate {

	function initialize () {
		MenuInputDelegate.initialize ();
	}

	function onMenuItem (item) {
		System.println("Select code #" + item.userData);
		Settings.setCurrentId(item.userData);
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
}