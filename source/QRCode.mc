class QRCode {
	enum {
		NUMERIC = 1,
		ALPHANUMERIC = 2,
		BYTE = 4,
		KANJI = 8
	}
	enum {
		L,
		M,
		Q,
		H
	}

	function initialize(data) {
		this.correction = QRCode.L;
		this.version = 1;
		this.mode = QRCode.BYTE;
		this.data = data;
		this.count = data.size();
	}

}