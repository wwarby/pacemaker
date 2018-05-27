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
		
		goalDistance = App.Properties.getValue(Ui.loadResource(Rez.Strings.goalDistance));
		if (goalDistance != null && goalDistance <= 0) {  goalDistance = null; }
		
		goalTargetTime = App.Properties.getValue(Ui.loadResource(Rez.Strings.goalTargetTime));
		if (goalTargetTime != null && goalTargetTime > 0) { 
			goalTargetTime *= 1000.0;
		} else {
			goalTargetTime = null;
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
