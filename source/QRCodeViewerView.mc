using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.Graphics as Gfx;

class QRCodeViewerView extends Ui.View {

	var qrCodeFont = [];
	var dcWidth = 0;
	var dcHeight = 0;
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
		System.println("Receiving image data (" + responseCode + "). Remaining " + requestCounter);
		if(requestCounter==0) { // handle only the last request
			if (responseCode == 200) {
				System.println("QR code image loaded");
				image = data;
			} else {
				image = null;
				var app = App.getApp();
				message = Ui.loadResource(Rez.Strings.error) +": " + responseCode
					+ "\n" + Ui.loadResource(Rez.Strings.errorImage);
				System.println(message);
			}
			Ui.requestUpdate();
		}
	}

	function initialize() {
		System.println("View initialization...");	
		View.initialize();
	}

	// Load your resources here
	function onLayout(dc) {		
		System.println("Loading resources...");	
		dcWidth = dc.getWidth();
		dcHeight = dc.getHeight();

		qrCodeFont = [
			Ui.loadResource(Rez.Fonts.qrcode1),
			Ui.loadResource(Rez.Fonts.qrcode2),
			Ui.loadResource(Rez.Fonts.qrcode3),
			Ui.loadResource(Rez.Fonts.qrcode4),
			Ui.loadResource(Rez.Fonts.qrcode5),
			Ui.loadResource(Rez.Fonts.qrcode6),
			Ui.loadResource(Rez.Fonts.qrcode7),
			Ui.loadResource(Rez.Fonts.qrcode8),
			Ui.loadResource(Rez.Fonts.qrcode9),
			Ui.loadResource(Rez.Fonts.qrcode10),
			Ui.loadResource(Rez.Fonts.qrcode11),
			Ui.loadResource(Rez.Fonts.qrcode12),
			Ui.loadResource(Rez.Fonts.qrcode13),
			Ui.loadResource(Rez.Fonts.qrcode14),
			Ui.loadResource(Rez.Fonts.qrcode15),
			Ui.loadResource(Rez.Fonts.qrcode16)
		];
		System.println("resources loaded.");	
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
		System.println("View.onShow");	
		var app = App.getApp();
		var id = app.getProperty("currentId");
		if(id == null) {
			// nothing to show...
			System.println("View.onShow - nothing to show");	
			return;
		}

		maxWidth = dcWidth  * 0.8;
		maxHeight= dcHeight * 0.8;
		if(maxWidth == maxHeight) {
			// For round device... Otherwise image is hidden in corner
			maxWidth = maxWidth * 0.8;
			maxHeight = maxHeight * 0.8;
		}

		if(app.getProperty("displayLabel")) {
			var fontHeight = Gfx.getFontHeight(Gfx.FONT_MEDIUM);
			var marginTop = (dcHeight - maxHeight) / 2;
			if(marginTop < fontHeight) {
				offsetHeight = fontHeight - marginTop;
				maxHeight = maxHeight - offsetHeight;
			}
		}

		size = app.getProperty("size");
		if(size == 0) {
			size = maxWidth<maxHeight?maxWidth:maxHeight;
		}

		var data = getCachedData(id);
		if(data == null) {
			System.println("No cached data, load image");
			image = null;
			message = app.getProperty("codeLabel" + id);
			data = app.getProperty("codeValue" + id);
			data = Communications.encodeURL(data);
			var strUrl = app.getProperty("QRCodeGeneratingURL");
			var sizeStr = size.format("%d");
			var type = app.getProperty("codeType" + id);
			if(type == null || type.length() == 0) {
				type = "qrcode";
			}
			var token = app.getProperty("token");
			strUrl = stringReplace(strUrl, "${DATA}", data);
			strUrl = stringReplace(strUrl, "${SIZE}", sizeStr);
			strUrl = stringReplace(strUrl, "${MARGIN}", 0);
			strUrl = stringReplace(strUrl, "${TYPE}", type);
			strUrl = stringReplace(strUrl, "${TOKEN}", token);
			requestCounter++;
			System.println("Loading QR code from " + strUrl);
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
		System.println("View.onShow - end");	
	}

	// Update the view
	function onUpdate(dc) {
		System.println("View.onUpdate");	
		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);

		var app = App.getApp();
		var id      = app.getProperty("currentId");
		var data    = getCachedData(id);
		if(id == null || message == null) {
			if(app.enabledCodeIds.size() == 0) {
				message = Ui.loadResource(Rez.Strings.errorNoQRCode);
			} else {
				message = Ui.loadResource(Rez.Strings.selectQRCode);
			}
		}
		dc.setColor (Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
		dc.clear();
		dc.drawText(
			(dc.getWidth()) / 2,
			(dc.getHeight()) / 2,
			Gfx.FONT_MEDIUM,
			message,
			Gfx.TEXT_JUSTIFY_CENTER
		);
		if(id != null && (data != null || image != null)) {
			System.println("Display QR code");
			var error = null;
			var imageFontSize = 1;
			if(data != null) {
				// On round watch barcode can be bigger
				var factor = (maxHeight==maxWidth && data.size()==1) ? 0.8 : 1;			
				for(imageFontSize = 1;
				    imageFontSize < qrCodeFont.size() &&
				    (imageFontSize+1) * data[0].length() <= size/factor+0.001;
				    imageFontSize++
				) {
				}
			}
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
			dc.clear();
			if(app.getProperty("displayLabel")) {
				System.println("Display label");
				dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
				dc.drawText(
					(dc.getWidth()) / 2,
					offsetHeight + app.getProperty("offsetY") - 3,
					Gfx.FONT_MEDIUM,
					app.getProperty("codeLabel" + id),
					Gfx.TEXT_JUSTIFY_CENTER
				);
			}
			if(data != null) {
				System.println("Display cached QR code");
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
				drawQRCode(dc, data, imageFontSize);
			} else {
				System.println("Display QR code image");
				dc.drawBitmap(
					(dc.getWidth() - image.getWidth() ) / 2,
					(dc.getHeight() - image.getHeight()) / 2 + offsetHeight + app.getProperty("offsetY"),
					image
				);
			}
		}
		System.println("View updated.");			
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
		var app = App.getApp();
		var nbLines = datas.size();
		if(nbLines == 1) {
			var barcodeHeight = app.getProperty("barcodeHeight");
			if(barcodeHeight == 0) {
				barcodeHeight = dc.getHeight()/10;
			}
			nbLines = barcodeHeight / moduleSize;
		}
		var offsetY = (dc.getHeight() - (nbLines-1) * 4 * moduleSize) / 2 + offsetHeight + app.getProperty("offsetY");
		for(var i=0; i<nbLines; i++) {
			dc.drawText(
					(dc.getWidth()) / 2,
					offsetY + (i * 4 * moduleSize),
					qrCodeFont[moduleSize-1],
					datas.size() == 1 ? datas[0] : datas[i], // For barcode, repeat the first raw
					Gfx.TEXT_JUSTIFY_CENTER
			);
		}
		if(datas.size() == 1) { // display value for barcode
			dc.setColor (Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
			dc.drawText(
					(dc.getWidth()) / 2,
					offsetY + (nbLines * 4 * moduleSize),
					Gfx.FONT_XTINY,
					app.getProperty("codeValue" + app.getProperty("currentId")),
					Gfx.TEXT_JUSTIFY_CENTER
			);
		}
	}
	
	function getCachedData(id) {
		System.println("Loading cached data for QR code #" + id);
		var app = App.getApp();
		if(app.getProperty("cacheEnabled")) {
			var data = app.getProperty("cacheData" + id);
			System.println("Returing cached data : " + data);
			return data;
		}
		System.println("Cache is disabled.");
		return null;
	}
	
}
