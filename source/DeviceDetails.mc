class DeviceDetails {
	
	var settings;
	var width = 0;
	var height = 0;
	
	var round240;
	var round218;
	
	function initialize() {
		
		settings = System.getDeviceSettings();
		
		round218 = settings.screenWidth == 218 && settings.screenShape == System.SCREEN_SHAPE_ROUND;
		round240 = settings.screenWidth == 240 && settings.screenShape == System.SCREEN_SHAPE_ROUND;
		width = settings.screenWidth;
		height = settings.screenHeight;
	}
	
}