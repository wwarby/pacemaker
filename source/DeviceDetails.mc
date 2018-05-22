class DeviceDetails {
	
	var round240;
	var round218;
	
	function initialize(width, shape) {
		round218 = width == 218 && shape == System.SCREEN_SHAPE_ROUND;
		round240 = width == 240 && shape == System.SCREEN_SHAPE_ROUND;
	}
	
}