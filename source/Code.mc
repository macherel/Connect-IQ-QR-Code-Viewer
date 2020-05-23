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
	}
	
	function store() {
		var app = App.getApp();
		var id = self.id;
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
		return new Code(
			id,
			app.getProperty("codeEnable"+ id),
			app.getProperty("codeType"  + id),
			app.getProperty("codeLabel" + id),
			app.getProperty("codeValue" + id),
			app.getProperty("cacheValue"+ id),
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

}
