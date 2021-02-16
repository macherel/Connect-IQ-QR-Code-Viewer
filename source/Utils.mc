function join(array, char) {
	var result = array[0];
	for(var i=1; i<array.size(); i++) {
		result += char + array[i];
	}
	return result;
}

function isNullOrEmpty(str) {
	return str == null || str.length() == 0;
}
