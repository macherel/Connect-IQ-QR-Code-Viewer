using Toybox.Application as App;

class Code {
	var id;
	var enabled;
	var label;
	var type;
	var value;
	var cache;
	var lat;
	var lng;

	function initialize(id, enabled, label, type, value, cache, lat, lng) {
		self.id = id;
		self.enabled = enabled;
		self.label = label;
		self.type = type;
		self.value = value;
		self.cache = cache;
		self.lat = lat;
		self.lng = lng;
		if(isNullOrEmpty(self.type)) {
			self.type = "qrcode";
		}
	}
	
	function store() {
		var app = App.getApp();
		var id = self.id;
		System.println("Store code #" + id);
		System.println("Store code " + self);
		app.setProperty("codeEnable"+ id, self.enabled);
		app.setProperty("codeType"  + id, self.type);
		app.setProperty("codeLabel" + id, self.label);
		app.setProperty("codeValue" + id, self.value);
		app.setProperty("cacheValue"+ id, self.value);
		app.setProperty("cacheData" + id, self.cache);
		app.setProperty("codeLat"   + id, self.lat);
		app.setProperty("codeLng"   + id, self.lng);
	}
	
	function fromSettings(id) {
		var app = App.getApp();
		var value = app.getProperty("codeValue" + id);
		var cacheValue = app.getProperty("cacheValue"+ id);
		if(value == null || !value.equals(cacheValue)) {
			app.setProperty("cacheData"+ id, null);
		}
		System.println("Load code #" + id + " : " + app.getProperty("codeEnable"+ id));
		return new Code(
			id,
			app.getProperty("codeEnable"+ id),
			app.getProperty("codeLabel" + id),
			app.getProperty("codeType"  + id),
			app.getProperty("codeValue" + id),
			app.getProperty("cacheData" + id),
			app.getProperty("codeLat"   + id),
			app.getProperty("codeLng"   + id)
		);
	}

	function fromResponseData(id, data) {
		return new Code(
			id,
			true,
			data["name"],
			data["type"],
			data["value"],
			data["encodedData"],
			data["latlng"]["lat"],
			data["latlng"]["lng"]
		);
	}
	
	function toString() {
		return "Code{"
			+ "id: " + self.id
			+ ", enabled: " + self.enabled
			+ ", label: " + self.label
			+ ", type: " + self.type
			+ ", value: " + self.value
			+ ", cache: " + self.cache
			+ "}";
	}

}
