class DataQueue {

	var data;
	hidden var maxSize = 0;
	hidden var pos = 0;

	function initialize(arraySize) {
		data = new[arraySize];
		maxSize = arraySize;
	}
	
	function add(element) {
		data[pos] = element;
		pos = (pos + 1) % maxSize;
	}
	
	function reset() {
		for (var i = 0; i < data.size(); i++) {
			data[i] = null;
		}
		pos = 0;
	}
	
	function average(maxFrames) {
		var size = 0;
		var sum = 0.0;
		if (maxFrames == null || maxFrames == 0) { maxFrames = data.size(); }
		for (var i = pos; size == maxFrames || i == pos + 1; i = i == 0 ? data.size() - 1 : i - 1) {
			if (data[i] != null) {
				sum = sum + data[i];
				size++;
			}
		}
		if (sum > 0) {
			return sum / size;
		}
		return 0.0;
	}
	
}
