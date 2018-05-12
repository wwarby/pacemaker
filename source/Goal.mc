class Goal {
	
	var enabledSettingName;
	var enabled = false;
	var distance;
	var label;
	var remainingDistance;
	var predictedTime;
	var completed = false;
	var actualTime;
	
	function compute(completedDistance, elapsedTime, speedMetersPerSecond) {
		
		if (completedDistance == null || completedDistance == 0 || elapsedTime == null || elapsedTime == 0 || completed) { return; }
		
		remainingDistance = Calc.max(0, distance - completedDistance);
		
		if (remainingDistance <= 0 && lastGoalTime == null) {
			actualTime = elapsedTime;
			predictedTime = 0;
			completed = true;
		} else {
			var secondsRemainingAtCurrentSpeed = (remainingDistance / speedMetersPerSecond) * 1000;
			predictedTime = (elapsedTime + secondsRemainingAtCurrentSpeed).toNumber();
		}
	}
	
}
