using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class QRCodeViewerView extends Ui.View {

	var app = App.getApp();
	var qrCodeFont = Ui.loadResource(Rez.Fonts.qrcode);
	var maxWidth  = 0;
	var maxHeight = 0;
	var offsetHeight = 0;
	var size = 0;

	var requestCounter = 0;
	var image = null;

	 // Set up the responseCallback function to return an image or null
	function onReceive(responseCode, data) {
		requestCounter--;
		if(requestCounter==0) { // handle only the last request	
			if (responseCode == 200) {
			    app.setProperty("data", data);
			} else {
			    app.setProperty("data", null);
				app.setProperty("message", "error: " + responseCode.format("%d"));
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

		if(app.getProperty("displayLabel")) {
			var fontHeight = Gfx.getFontHeight(Gfx.FONT_MEDIUM);
			var marginBottom = (dc.getHeight() - maxHeight) / 2;
			if(marginBottom < fontHeight) {
				offsetHeight = fontHeight - marginBottom;
				maxHeight = maxHeight - offsetHeight;
			}
		}
		size = app.getProperty("size");
		if(size == 0) {
			size = maxWidth<maxHeight?maxWidth:maxHeight;
		}
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
		var value = app.getProperty("value");

		if(value != null) {
            app.setProperty("data", null);
            requestCounter++;
            Comm.makeWebRequest(
                "https://qrcode.alwaysdata.net/phpqrcode/",
				{
				    "data" => value
				},
				{
					:methods => Comm.HTTP_REQUEST_METHOD_GET,
					:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
				},
				method(:onReceive)
			);
		}
	}

	// Update the view
	function onUpdate(dc) {
		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
		
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
		if(data != null) {
			var error = null;
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
			dc.clear();
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
			drawQRCode(dc, data, 0, 0, 0);
			if(app.getProperty("displayLabel") && message != null && false) { // FIXME: fix "false" condition
				dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
				dc.drawText(
					(dc.getWidth()) / 2,
					(dc.getHeight() + image.getHeight()) / 2 - offsetHeight - app.getProperty("offsetY"),
					Gfx.FONT_MEDIUM,
					message,
					Gfx.TEXT_JUSTIFY_CENTER
				);
			}
//*/
//			dc.drawBitmap(
//				(dc.getWidth() - image.getWidth() ) / 2,
//				(dc.getHeight() - image.getHeight()) / 2 - offsetHeight - app.getProperty("offsetY"),
//				image
//			);
		}
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
	}

	function drawQRCode(dc, encodedLines, moduleSize, offsetX, offsetY) {
		System.println(encodedLines);
		var nbLines = encodedLines.size();
		var offsetY = (dc.getHeight() - (nbLines-1) * 16) / 2;
		for(var i=0; i<nbLines; i++) {
			dc.drawText(
					(dc.getWidth()) / 2,
					offsetY + (i * 16),
					qrCodeFont,
					encodedLines[i],
					Gfx.TEXT_JUSTIFY_CENTER
			);
		}
	}
}
