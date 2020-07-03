using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class QRCodeViewerDelegate extends Ui.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onSelect() {
		var app = App.getApp();
		
		if(app.enabledCodes.size() > 0) {
			var qrCodesMenu = [];
			var menuIndex = 0;
			for(var i=0; i<app.enabledCodes.size(); i++) {
				var code = app.enabledCodes[i];
				if(code.id == Settings.currentId) {
					menuIndex = i;
				}
				qrCodesMenu.add(new DMenuItem(i, code.label, code.value, code.id));
			}
			var view = new DMenu(qrCodesMenu, Ui.loadResource(Rez.Strings.mainMenuTitle));
			if(Settings.retainMenuIndex) {
				view.updateIndex(menuIndex);
			}

			Ui.pushView(view, new DMenuDelegate(view, new QrCodeViewerMenuDelegate()), Ui.SLIDE_IMMEDIATE);
		} else {
			Ui.requestUpdate();
		}
		return true;
	}
	function onMenu() {	return onSelect(); }
	
	function onSwipe(swipeEvent) {
		switch(swipeEvent.getDirection()) {
			case WatchUi.SWIPE_LEFT:
				break;
			default:
				return false;
		}
		var app = App.getApp();
		if(app.enabledCodes.size() == 0) {
			return true;
		}
		
		var index = app.getCodeIndex(Settings.currentId);
		var transition = Ui.SLIDE_IMMEDIATE;
		switch(swipeEvent.getDirection()) {
			case WatchUi.SWIPE_LEFT:
				index++;
				transition = Ui.SLIDE_LEFT;
				break;
		}
		index = (index + app.enabledCodes.size()) % app.enabledCodes.size();
		Settings.setCurrentId(app.enabledCodes[index].id);
		Ui.switchToView(new QRCodeViewerView(), new QRCodeViewerDelegate(), transition);

		return true;
	}
}
