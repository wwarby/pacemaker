using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Calc;

class GoalMetrics {
	
	var goalDistance;
	var goalTargetTime;
	
	var predictedTime;
	var remainingDistance;
	var requiredSpeed;
	var requiredPace;
	var remainingTime;
	var completedTime;
	
	function initialize() {
		predictedTime = goalTargetTime;
		remainingDistance = goalDistance;
	}
	
	function readSettings(deviceSettings) {
		
		goalDistance = App.Properties.getValue("d");
		if (goalDistance != null && goalDistance <= 0) {  goalDistance = null; }
		
		
		try {
			var time = App.Properties.getValue("t").toString();
			if (time == null || time.length() == 0) {
				goalTargetTime = null;
			} else if (time.find(":") == null) { // Seconds
				goalTargetTime = time.toNumber();
			} else if (time.length() == 4) { // m:ss
				goalTargetTime = (time.substring(0, 1).toNumber() * 60) + time.substring(2, 4).toNumber();
			} else if (time.length() == 5) { // mm:ss
				goalTargetTime = (time.substring(0, 2).toNumber() * 60) + time.substring(3, 5).toNumber();
			} else if (time.length() == 7) { // h:mm:ss
				goalTargetTime = (time.substring(0, 1).toNumber() * 3600) + (time.substring(2, 4).toNumber() * 60) + time.substring(5, 7).toNumber();
			} else if (time.length() == 8) { // hh:mm:ss
				goalTargetTime = (time.substring(0, 2).toNumber() * 3600) + (time.substring(3, 5).toNumber() * 60) + time.substring(6, 8).toNumber();
			} else if (time.length() == 9) { // hhh:mm:ss
				goalTargetTime = (time.substring(0, 3).toNumber() * 3600) + (time.substring(4, 6).toNumber() * 60) + time.substring(7, 9).toNumber();
			}
		} catch(ex) {
		    // System.println(ex.getErrorMessage());
			goalTargetTime = null;
		}
		
		if (goalTargetTime != null) {
			if (goalTargetTime > 999999) {
				goalTargetTime = null;
			} else if (goalTargetTime > 0) { 
				goalTargetTime *= 1000.0;
			}
		}
	}
	
	function goalSet() {
		return goalDistance != null && goalTargetTime != null;
	}
	
	function goalCompleted() {
		return completedTime != null;
	}
	
	function checkReset(info) {
		// Goal not set or activity not started
		if (!goalSet() || (info != null && (info.elapsedDistance == null || info.timerTime == null))) {
			predictedTime = null;
			remainingDistance = null;
			requiredSpeed = null;
			requiredPace = null;
			remainingTime = null;
			completedTime = null;
			return;
		}
	}
	
	function compute(info, currentSpeed, kmOrMileInMeters) {
		
		readSettings(null);
		checkReset(info);
		
		remainingDistance = goalDistance != null ? Calc.max(0, goalDistance - (info.elapsedDistance == null ? 0 : info.elapsedDistance)) : null;
		
		// Goal completed or not moving
		if (completedTime != null || currentSpeed == null || currentSpeed == 0 || info.elapsedDistance == null || !goalSet()) { return; }
		
		// Capture goal finish time
		if (goalDistance <= info.elapsedDistance) {
			completedTime = info.timerTime;
			predictedTime = completedTime;
			remainingTime = null;
			requiredSpeed = null;
			requiredPace = null;
		} else {
			// Compute goal metrics
			predictedTime = (info.timerTime + ((remainingDistance / currentSpeed) * 1000.0)).toNumber();
			remainingTime = goalTargetTime - info.timerTime;
			requiredSpeed = remainingDistance / (remainingTime / 1000.0);
			if (requiredSpeed != null && requiredSpeed > 0.2) {
				requiredPace = kmOrMileInMeters / requiredSpeed;
			} else {
				requiredPace = null;
			}
		}
	}
	
	function delta() {
		if (!goalSet() || (predictedTime == null && completedTime == null)) { return 0; }
		return (completedTime != null ? completedTime : predictedTime) - goalTargetTime;
	}
	
	function paceDelta(currentPace) {
		if (!goalSet() || requiredPace == null) { return 0; }
		return completedTime != null ? currentPace : currentPace - requiredPace;
	}
	
	function onTarget() {
		return delta() <= 0;
	}
	
}
