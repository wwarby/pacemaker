using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class ActivityMetrics {

	hidden var paceData;
	hidden var cadenceData;
	hidden var heartRateData;
	hidden var powerData;
	
	var kmOrMileInMeters;
	
	var elapsedDistance;
	var timerTime;
	var currentSpeed;
	var calories;
	
	var computedSpeed;
	var computedPace;
	var computedCadence;
	var computedHeartRate;
	var computedPower;
	
	var paceMode = -1;
	var cadenceMode = -1;
	var heartRateMode = -1;
	var powerMode = -1;
	
	function initialize() {}
	
	function readSettings(deviceSettings) {
		
		kmOrMileInMeters = deviceSettings.distanceUnits == System.UNIT_METRIC ? 1000.0f : 1609.34f;
		
		paceMode = App.Properties.getValue("pm");
		if (paceMode > 0) {
			paceData = new DataQueue(paceMode);
		} else {
			paceData = null;
		}
		
		cadenceMode = App.Properties.getValue("cm");
		if (cadenceMode > 0) {
			cadenceData = new DataQueue(cadenceMode);
		} else {
			cadenceData = null;
		}
		
		heartRateMode = App.Properties.getValue("hm");
		if (heartRateMode > 0) {
			heartRateData = new DataQueue(heartRateMode);
		} else {
			heartRateData = null;
		}
		
		powerMode = App.Properties.getValue("pwm");
		if (powerMode > 0) {
			powerData = new DataQueue(powerMode);
		} else {
			powerData = null;
		}
	}
	
	function compute(info) {
		
		elapsedDistance = info.elapsedDistance;
		timerTime = info.timerTime;		
		currentSpeed = info.currentSpeed;
		calories = info.calories;
		
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
		
		if (powerData != null && info has :currentPower) {
			if (info.currentPower != null) {
				powerData.add(info.currentPower);
			} else {
				powerData.reset();
			}
		}
		
		computedHeartRate =
			heartRateMode == -1 ? info.currentHeartRate :
			heartRateMode == 0 ? info.averageHeartRate :
			heartRateData != null ? heartRateData.average() :
			null;
		
		computedCadence =
			cadenceMode == -1 ? info.currentCadence :
			cadenceMode == 0 ? info.averageCadence :
			cadenceData != null ? cadenceData.average() :
			null;
		
		computedPower =
			!(info has :currentPower) ? null :
			powerMode == -1 ? info.currentPower :
			powerMode == 0 ? info.averagePower :
			powerData != null ? powerData.average() :
			null;
		
		computedSpeed =
			paceMode == -1 ? info.currentSpeed :
			paceMode == 0 ? info.averageSpeed :
			paceData != null ? paceData.average() :
			null;
		
		computedPace = (computedSpeed != null && computedSpeed > 0.2) ? kmOrMileInMeters / computedSpeed : null;
	}
	
}
