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
			var currentId = app.getProperty("currentId");
			var menuIndex = 0;
			for(var i=0; i<app.enabledCodes.size(); i++) {
				var code = app.enabledCodes[i];
				if(code.id == currentId) {
					menuIndex = i;
				}
				qrCodesMenu.add(new DMenuItem(i, code.label, code.value, code.id));
			}
			var view = new DMenu(qrCodesMenu, Ui.loadResource(Rez.Strings.mainMenuTitle));
			if(app.getProperty("retainMenuIndex")) {
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
		var currentId = app.getProperty("currentId");
		var index = -1;
		for(var i=0; i<app.enabledCodes.size(); i++) {
			var id = app.enabledCodes[i] == null ? -1 : app.enabledCodes[i].id;
			if(id == currentId) {
				index = i;
			}
		}

		var transition = Ui.SLIDE_IMMEDIATE;
		switch(swipeEvent.getDirection()) {
			case WatchUi.SWIPE_LEFT:
				index++;
				transition = Ui.SLIDE_LEFT;
				break;
		}
		index = (index + app.enabledCodes.size()) % app.enabledCodes.size();
		app.setProperty("currentId", app.enabledCodes[index].id);
		Ui.switchToView(new QRCodeViewerView(), new QRCodeViewerDelegate(), transition);

		return true;
	}
}
