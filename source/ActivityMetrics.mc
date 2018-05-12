using Calc;
using Globals;

class ActivityMetrics {

	hidden var paceData = new DataQueue(10);
	
	var kmOrMileInMeters = 1000.0f;
	var distanceUnits = System.UNIT_METRIC;
	var hr = 0;
	var distance = 0;
	var elapsedTime = 0;
	
	function initialize() {}
	
	function setDeviceSettingsDependentVariables() {
		distanceUnits = System.getDeviceSettings().distanceUnits;
		if (distanceUnits == System.UNIT_METRIC) {
			kmOrMileInMeters = 1000.0f;
		} else {
			kmOrMileInMeters = Globals.METERS_IN_MILE;
		}
	}
	
	function compute(info) {
		if (info.currentSpeed != null) {
			paceData.add(info.currentSpeed);
		} else {
			paceData.reset();
		}
		
		elapsedTime = info.timerTime != null ? info.timerTime : 0;		
		hr = info.currentHeartRate != null ? info.currentHeartRate : 0;
		distance = info.elapsedDistance != null ? info.elapsedDistance : 0;
	}
	
	function secondsPerKmOrMile() {
		var speed = speedMetersPerSecond();
		if (speed != null && speed > 0.2) {
			return kmOrMileInMeters / speed;
		}
		return 0;
	}
	
	function speedMetersPerSecond() {
		var size = 0;
		var data = paceData.getData();
		var sumOfData = 0.0;
		for (var i = 0; i < data.size(); i++) {
			if (data[i] != null) {
				sumOfData = sumOfData + data[i];
				size++;
			}
		}
		if (sumOfData > 0) {
			return sumOfData / size;
		}
		return 0.0;
	}

}
