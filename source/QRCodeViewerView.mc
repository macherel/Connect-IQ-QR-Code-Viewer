using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class QRCodeViewerView extends Ui.View {

	var maxWidth  = 0;
	var maxHeight = 0;

	var requestCounter = 0;
	var image = null;

	 // Set up the responseCallback function to return an image or null
	function onReceiveImage(responseCode, data) {
		requestCounter--;
		if(requestCounter==0) { // handle only the last request
			var app = App.getApp();
	
			if (responseCode == 200) {
				image = data;
			} else {
				image = null;
				app.setProperty("message", responseCode.format("%d"));
			}
			Ui.requestUpdate();
		}
	}

	function initialize() {
		View.initialize();
	}

	// Load your resources here
	function onLayout(dc) {
		maxWidth = dc.getWidth()  * 0.8;
		maxHeight= dc.getHeight() * 0.8;
		if(maxWidth == maxHeight) {
			// For round device... Otherwise image is hidden in corner
			maxWidth = maxWidth * 0.8;
			maxHeight = maxHeight * 0.8;
		}

	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
		var app = App.getApp();
		var data  = app.getProperty("data");

		if(data != null) {
			image = null;
			data = Communications.encodeURL(data);
			var strUrl = app.getProperty("QRCodeGeneratingURL");
			var size = app.getProperty("size");
			if(size == 0) {
				size = maxWidth<maxHeight?maxWidth:maxHeight;
				app.setProperty("size", size);
			}
			var sizeStr = size.format("%d");
			strUrl = stringReplace(strUrl, "${DATA}", data);
			strUrl = stringReplace(strUrl, "${SIZE}", sizeStr);
			strUrl = stringReplace(strUrl, "${MARGIN}", 0);
			requestCounter++;
			Comm.makeImageRequest(
				strUrl,
				{},
				{
					:maxWidth => size,
					:maxHeight=> size
				},
				method(:onReceiveImage)
			);
		}
	}

	// Update the view
	function onUpdate(dc) {
		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
		
		var app = App.getApp();
		var message = app.getProperty("message");
		var data    = app.getProperty("data");

		if(message != null) {
			dc.setColor (Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
			dc.drawText(
				(dc.getWidth()) / 2,
				(dc.getHeight()) / 2,
				Gfx.FONT_MEDIUM,
				message,
				Gfx.TEXT_JUSTIFY_CENTER
			);
		}
		if(data != null && image != null) {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
			dc.clear();
			dc.drawBitmap(
				(dc.getWidth() - image.getWidth() ) / 2,
				(dc.getHeight() - image.getHeight()) / 2,
				image
			);
		}
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
	}

}
