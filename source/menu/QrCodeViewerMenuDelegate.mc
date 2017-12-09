using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Math as Math;
using Toybox.Application as App;

class QrCodeViewerMenuDelegate extends Ui.MenuInputDelegate {

	function initialize () {
		MenuInputDelegate.initialize ();
	}

	function onMenuItem (item) {
		var app = App.getApp();
		app.setProperty("data", item.value);
		app.setProperty("message", item.label);
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
}