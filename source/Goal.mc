class Goal {

	var name;
	var index;
	var distance  = 0;
	var remainingDistance = 0;
	var requiredSpeed = 0;
	var requiredPace = 0;
	var targetTime = 0;
	var predictedTime = 0;
	var actualTime = 0;
	var remainingTime = 0;
	var completed = false;
	
	function initialize(t, d, n, i) {
		targetTime = t;
		distance = d;
		name = n;
		index = i;
	}
	
	function compute(completedDistance, elapsedTime, speedMetersPerSecond, kmOrMileInMeters) {
		
		if (
			completedDistance == null ||
			completedDistance == 0 ||
			elapsedTime == null ||
			elapsedTime == 0 ||
			completed ||
			speedMetersPerSecond == null ||
			speedMetersPerSecond == 0
		) { return; }
		
		remainingDistance = Calc.max(0, distance - completedDistance);
		
		if (remainingDistance <= 0) {
			actualTime = elapsedTime;
			predictedTime = 0;
			remainingTime = 0;
			requiredSpeed = 0;
			requiredPace = 0;
			completed = true;
		} else {
			var secondsRemainingAtCurrentSpeed = (remainingDistance / speedMetersPerSecond) * 1000;
			predictedTime = (elapsedTime + secondsRemainingAtCurrentSpeed).toNumber();
			remainingTime = targetTime - elapsedTime;
			requiredSpeed = remainingDistance / (remainingTime / 1000);
			if (requiredSpeed != null && requiredSpeed > 0.2) {
				requiredPace = kmOrMileInMeters / requiredSpeed;
			} else {
				requiredPace = 0;
			}
		}
	}
	
	function enabled() {
		return distance != null && distance > 0 && targetTime != null && targetTime > 0;
	}
	
	function delta() {
		return (completed ? actualTime : predictedTime) - targetTime;
	}
	
	function onTarget() {
		return delta() <= 0;
	}
	
}
