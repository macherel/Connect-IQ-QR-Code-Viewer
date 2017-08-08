using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class QRCodeViewerView extends Ui.View {

	var maxWidth;
	var maxHeight;

	var image;

	 // Set up the responseCallback function to return an image or null
	function onReceiveImage(responseCode, data) {
	
		if (responseCode == 200) {
			image = data;
		} else {
			image = null;
			App.getApp().setProperty("message", responseCode.format("%d"));
		}
		Ui.requestUpdate();
	}

	function initialize() {
		View.initialize();
	}

	// Load your resources here
	function onLayout(dc) {
		maxWidth = dc.getWidth();
		maxHeight= dc.getHeight();
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
		
		var data = app.getProperty("data");
		if(data != null) {
			image = null;
			data = Communications.encodeURL(data);
			var strUrl = "https://chart.googleapis.com/chart";
			Comm.makeImageRequest(
				strUrl,
				{
					"cht" => "qr",
					"chl" => data,
					"chs" => "500x500",
					"choe" => "UTF-8",
					"chld" => "L|2"
				},
				{
					:maxWidth => maxWidth,
					:maxHeight=> maxHeight
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
		if(App.getApp().getProperty("data") != null && image != null) {
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
