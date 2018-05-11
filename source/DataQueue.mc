class DataQueue {

    hidden var data;
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
    
    function getData() {
        return data;
    }
    
}