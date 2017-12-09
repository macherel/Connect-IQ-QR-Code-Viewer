function stringReplace(str, oldString, newString)
{
	var result = str;
	var start = result.find(oldString);

	while (start != null) {
		var end = start + oldString.length();
		result = result.substring(0, start) + newString + result.substring(end, result.length());

		start = result.find(oldString);
	}

	return result;
}
