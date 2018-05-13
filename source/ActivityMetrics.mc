using Toybox.Application as App;
using Calc;
using Globals;

class ActivityMetrics {

	hidden var paceData;
	hidden var cadenceData;
	hidden var heartRateData;
	
	hidden var app;
	
	var kmOrMileInMeters = 1000.0f;
	var distanceUnits = System.UNIT_METRIC;
	
	var distance = 0;
	var elapsedTime = 0;
	var averageSpeed = 0;
	var currentSpeed = 0;
	var averageCadence = 0;
	var currentCadence = 0;
	var averageHeartRate = 0;
	var currentHeartRate = 0;
	
	var computedSpeed = 0;
	var computedPace = 0;
	var computedCadence = 0;
	var computedHeartRate = 0;
	
	var paceMode = Globals.PACE_MODE_CURRENT;
	var cadenceMode = Globals.CADENCE_MODE_CURRENT;
	var heartRateMode = Globals.HEART_RATE_MODE_CURRENT;
	
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
		
		if (app.getProperty("paceMode") == null) {
			paceMode = app.getProperty("paceMode");
		}
		
		if (paceMode == Globals.PACE_MODE_3_SECONDS) {
			paceData = new DataQueue(3);
		} else if (paceMode == Globals.PACE_MODE_5_SECONDS) {
			paceData = new DataQueue(5);
		} else if (paceMode == Globals.PACE_MODE_10_SECONDS) {
			paceData = new DataQueue(10);
		} else if (paceMode == Globals.PACE_MODE_30_SECONDS) {
			paceData = new DataQueue(30);
		} else {
			paceData = null;
		}
		
		if (app.getProperty("cadenceMode") == null) {
			cadenceMode = app.getProperty("cadenceMode");
		}
		
		if (cadenceMode == Globals.CADENCE_MODE_3_SECONDS) {
			cadenceData = new DataQueue(3);
		} else if (cadenceMode == Globals.CADENCE_MODE_5_SECONDS) {
			cadenceData = new DataQueue(5);
		} else if (cadenceMode == Globals.CADENCE_MODE_10_SECONDS) {
			cadenceData = new DataQueue(10);
		} else if (cadenceMode == Globals.CADENCE_MODE_30_SECONDS) {
			cadenceData = new DataQueue(30);
		} else {
			cadenceData = null;
		}
		
		if (app.getProperty("heartRateMode") == null) {
			heartRateMode = app.getProperty("heartRateMode");
		}
		
		if (heartRateMode == Globals.HEART_RATE_MODE_3_SECONDS) {
			heartRateData = new DataQueue(3);
		} else if (heartRateMode == Globals.HEART_RATE_MODE_5_SECONDS) {
			heartRateData = new DataQueue(5);
		} else if (heartRateMode == Globals.HEART_RATE_MODE_10_SECONDS) {
			heartRateData = new DataQueue(10);
		} else if (heartRateMode == Globals.HEART_RATE_MODE_30_SECONDS) {
			heartRateData = new DataQueue(30);
		} else {
			heartRateData = null;
		}
	}
	
	function compute(info) {
		
		distance = info.elapsedDistance != null ? info.elapsedDistance : 0;
		elapsedTime = info.timerTime != null ? info.timerTime : 0;		
		averageSpeed = info.averageSpeed != null ? info.averageSpeed : 0;
		currentSpeed = info.currentSpeed != null ? info.currentSpeed : 0;
		currentCadence = info.currentCadence != null ? info.currentCadence : 0;
		averageCadence = info.averageCadence != null ? info.averageCadence : 0;
		currentHeartRate = info.currentHeartRate != null ? info.currentHeartRate : 0;
		averageHeartRate = info.averageHeartRate != null ? info.averageHeartRate : 0;
		
		
		if (paceData != null) {
			if (info.currentSpeed != null) {
				paceData.add(info.currentSpeed);
			} else {
				paceData.reset();
			}
		}
		
		if (cadenceData != null) {
			if (info.currentCadence != null) {
				cadenceData.add(info.currentCadence);
			} else {
				cadenceData.reset();
			}
		}
		
		if (heartRateData != null) {
			if (info.currentHeartRate != null) {
				heartRateData.add(info.currentHeartRate);
			} else {
				heartRateData.reset();
			}
		}
		
		computedSpeed = computeSpeed();
		computedPace = computePace();
		computedCadence = computeCadence();
		computedHeartRate = computeHeartRate();
	}
	
	function computeSpeed() {
		switch (paceMode) {
			case Globals.PACE_MODE_CURRENT:
				return currentSpeed;
			case Globals.PACE_MODE_AVERAGE:
				return averageSpeed;
			case Globals.PACE_MODE_3_SECONDS:
			case Globals.PACE_MODE_5_SECONDS:
			case Globals.PACE_MODE_10_SECONDS:
			case Globals.PACE_MODE_30_SECONDS:
				return paceData.average();
		}
		return 0.0;
	}
	
	function computePace() {
		if (computedSpeed != null && computedSpeed > 0.2) {
			return kmOrMileInMeters / computedSpeed;
		}
		return 0;
	}
	
	function computeCadence() {
		switch (cadenceMode) {
			case Globals.CADENCE_MODE_CURRENT:
				return currentCadence;
			case Globals.CADENCE_MODE_AVERAGE:
				return averageCadence;
			case Globals.CADENCE_MODE_3_SECONDS:
			case Globals.CADENCE_MODE_5_SECONDS:
			case Globals.CADENCE_MODE_10_SECONDS:
			case Globals.CADENCE_MODE_30_SECONDS:
				return cadenceData.average();
		}
		return 0.0;
	}
	
	function computeHeartRate() {
		switch (heartRateMode) {
			case Globals.HEART_RATE_MODE_CURRENT:
				return currentHeartRate;
			case Globals.HEART_RATE_MODE_AVERAGE:
				return averageHeartRate;
			case Globals.HEART_RATE_MODE_3_SECONDS:
			case Globals.HEART_RATE_MODE_5_SECONDS:
			case Globals.HEART_RATE_MODE_10_SECONDS:
			case Globals.HEART_RATE_MODE_30_SECONDS:
				return heartRateData.average();
		}
		return 0.0;
	}
	
	
}
