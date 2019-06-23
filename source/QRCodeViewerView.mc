using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.Graphics as Gfx;

class QRCodeViewerView extends Ui.View {

	var qrCodeFont = [
		Ui.loadResource(Rez.Fonts.qrcode1),
		Ui.loadResource(Rez.Fonts.qrcode2),
		Ui.loadResource(Rez.Fonts.qrcode3),
		Ui.loadResource(Rez.Fonts.qrcode4),
		Ui.loadResource(Rez.Fonts.qrcode5),
		Ui.loadResource(Rez.Fonts.qrcode6)
	];
	var maxWidth  = 0;
	var maxHeight = 0;
	var offsetHeight = 0;
	var size = 0;

	var requestCounter = 0;
	var image = null;
	var message = null;

	// Set up the responseCallback function to return an image or null
	function onReceiveImage(responseCode, data) {
		requestCounter--;
		if(requestCounter==0) { // handle only the last request
	
			if (responseCode == 200) {
				image = data;
			} else {
				image = null;
				var app = App.getApp();
				message = "Error: " + responseCode.format("%d");
			}
			Ui.requestUpdate();
		}
	}

	function initialize() {
		View.initialize();
	}

	// Load your resources here
	function onLayout(dc) {
		var app = App.getApp();
		maxWidth = dc.getWidth()  * 0.8;
		maxHeight= dc.getHeight() * 0.8;
		if(maxWidth == maxHeight) {
			// For round device... Otherwise image is hidden in corner
			maxWidth = maxWidth * 0.8;
			maxHeight = maxHeight * 0.8;
		}

		if(app.getProperty("displayLabel")) {
			var fontHeight = Gfx.getFontHeight(Gfx.FONT_MEDIUM);
			var marginTop = (dc.getHeight() - maxHeight) / 2;
			if(marginTop < fontHeight) {
				offsetHeight = fontHeight - marginTop;
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
		var app = App.getApp();
		var id = app.getProperty("currentId");

		var data = getCachedData(id);
		if(data == null) {
			image = null;
			message = app.getProperty("codeLabel" + id);
			data = app.getProperty("codeValue" + id);
			data = Communications.encodeURL(data);
			var strUrl = app.getProperty("QRCodeGeneratingURL");
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
		var id      = app.getProperty("currentId");
		var data    = getCachedData(id);
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
		if(data != null || image != null) {
			var error = null;
			var imageHeight;
			var imageFontSize = 1;
			if(data != null) {
				for(imageFontSize = 1;
				    imageFontSize < qrCodeFont.size() &&
				    (imageFontSize+1) * data.size() * 4 < maxHeight+0.001;
				    imageFontSize++
				) {
				}
				imageHeight = imageFontSize * data.size() * 4;
			} else {
				imageHeight = image.getHeight();
			}
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
			dc.clear();
			if(data != null) {
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
				drawQRCode(dc, data, imageFontSize);
			} else {
				dc.drawBitmap(
					(dc.getWidth() - image.getWidth() ) / 2,
					(dc.getHeight() - image.getHeight()) / 2 + offsetHeight + app.getProperty("offsetY"),
					image
				);
			}
			if(app.getProperty("displayLabel")) {
				dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
				dc.drawText(
					(dc.getWidth()) / 2,
					0,
					Gfx.FONT_MEDIUM,
					app.getProperty("codeLabel" + id),
					Gfx.TEXT_JUSTIFY_CENTER
				);
			}
		}
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
	}

	function drawQRCode(dc, datas, moduleSize) {
		if(!(datas instanceof Toybox.Lang.Array)) {
			return;
		}
		var nbLines = datas.size();
		var offsetY = (dc.getHeight() - (nbLines-1) * 4 * moduleSize) / 2;
		for(var i=0; i<nbLines; i++) {
			dc.drawText(
					(dc.getWidth()) / 2,
					offsetY + (i * 4 * moduleSize),
					qrCodeFont[moduleSize-1],
					datas[i],
					Gfx.TEXT_JUSTIFY_CENTER
			);
		}
	}
	
	function getCachedData(id) {
		var app = App.getApp();
		if(app.getProperty("cacheEnabled")) {
			return app.getProperty("cacheData" + id);
		}
		return null;
	}
	
}
