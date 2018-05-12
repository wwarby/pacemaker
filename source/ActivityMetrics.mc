using Toybox.Application as App;
using Calc;
using Globals;

class ActivityMetrics {

	hidden var paceData;
	
	hidden var app;
	
	var kmOrMileInMeters = 1000.0f;
	var distanceUnits = System.UNIT_METRIC;
	var hr = 0;
	var distance = 0;
	var elapsedTime = 0;
	var averageSpeed = 0;
	var currentSpeed = 0;
	var computedPace = 0;
	var computedSpeed = 0;
	var paceMode;
	
	function initialize() {
		app = App.getApp();
	}
	
	function setDeviceSettingsDependentVariables(deviceSettings) {
		distanceUnits = deviceSettings.distanceUnits;
		if (distanceUnits == System.UNIT_METRIC) {
			kmOrMileInMeters = 1000.0f;
		} else {
			kmOrMileInMeters = Globals.METERS_IN_MILE;
		}
		
		paceMode = app.getProperty("paceMode");
		
		if (paceMode == Globals.PACE_MODE_3_SECONDS) {
			paceData = new DataQueue(3);
		} else if (paceMode == Globals.PACE_MODE_10_SECONDS) {
			paceData = new DataQueue(10);
		} else if (paceMode == Globals.PACE_MODE_30_SECONDS) {
			paceData = new DataQueue(30);
		} else {
			paceData = null;
		}
	}
	
	function compute(info) {
		
		elapsedTime = info.timerTime != null ? info.timerTime : 0;		
		hr = info.currentHeartRate != null ? info.currentHeartRate : 0;
		distance = info.elapsedDistance != null ? info.elapsedDistance : 0;
		averageSpeed = info.averageSpeed;
		currentSpeed = info.currentSpeed;
		
		if (paceData != null) {
			if (info.currentSpeed != null) {
				paceData.add(info.currentSpeed);
			} else {
				paceData.reset();
			}
		}
		
		computedSpeed = speedMetersPerSecond();
		computedPace = secondsPerKmOrMile();
	}
	
	hidden function secondsPerKmOrMile() {
		if (computedSpeed != null && computedSpeed > 0.2) {
			return kmOrMileInMeters / computedSpeed;
		}
		return 0;
	}
	
	hidden function speedMetersPerSecond() {
		
		switch (paceMode) {
			case Globals.PACE_MODE_CURRENT:
				return currentSpeed;
			case Globals.PACE_MODE_AVERAGE:
				return averageSpeed;
			case Globals.PACE_MODE_3_SECONDS:
			case Globals.PACE_MODE_10_SECONDS:
			case Globals.PACE_MODE_30_SECONDS:
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
		}
		
		return 0.0;
	}

}
