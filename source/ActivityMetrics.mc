using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Calc;

class ActivityMetrics {

	hidden var paceData;
	hidden var cadenceData;
	hidden var heartRateData;
	hidden var powerData;
	
	var kmOrMileInMeters;
	
	var elapsedDistance;
	var timerTime;
	var currentSpeed;
	
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
		
		paceMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.paceMode));
		if (paceMode > 0) {
			paceData = new DataQueue(paceMode);
		} else {
			paceData = null;
		}
		
		cadenceMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.cadenceMode));
		if (cadenceMode > 0) {
			cadenceData = new DataQueue(cadenceMode);
		} else {
			cadenceData = null;
		}
		
		heartRateMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.heartRateMode));
		if (heartRateMode > 0) {
			heartRateData = new DataQueue(heartRateMode);
		} else {
			heartRateData = null;
		}
		
		powerMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.powerMode));
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
		
		computedSpeed = computeSpeed(info);
		computedPace = computePace();
		computedCadence = computeCadence(info);
		computedHeartRate = computeHeartRate(info);
		computedPower = computePower(info);
	}
	
	function computeSpeed(info) {
		if (paceMode == -1) { return info.currentSpeed; }
		if (paceMode == 0) { return info.averageSpeed; }
		if (paceData != null) { return paceData.average(); }
		return null;
	}
	
	function computePace() {
		if (computedSpeed != null && computedSpeed > 0.2) {
			return kmOrMileInMeters / computedSpeed;
		}
		return null;
	}
	
	function computeCadence(info) {
		if (cadenceMode == -1) { return info.currentCadence; }
		if (cadenceMode == 0) { return info.averageCadence; }
		if (cadenceData != null) { return cadenceData.average(); }
		return null;
	}
	
	function computeHeartRate(info) {
		if (heartRateMode == -1) { return info.currentHeartRate; }
		if (heartRateMode == 0) { return info.averageHeartRate; }
		if (heartRateData != null) { return heartRateData.average(); }
		return null;
	}
	
	function computePower(info) {
		if (info has :currentPower) {
			if (powerMode == -1) { return info.currentPower; }
			if (powerMode == 0) { return info.averagePower; }
			if (powerData != null) { return powerData.average(); }
		}
		return null;
	}
	
}
