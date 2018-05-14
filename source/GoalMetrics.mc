using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Calc;
using Globals;

class GoalMetrics {
	
	hidden const MAX_GOALS = 2;
	
	hidden var goals = new[0];
	hidden var metrics;
	hidden var app;
	
	function initialize(parentMetrics) {
		
		metrics = parentMetrics.weak().get();
		app = App.getApp();
		
		// Initialize goals
		for (var i = 1; i < MAX_GOALS + 1; i++) {
			var distance = app.getProperty("goal" + i + "Distance");
			var targetTime = app.getProperty("goal" + i + "TargetTime") * 1000;
			var name = app.getProperty("goal" + i + "Name");
			if (name == null || name.length() == 0) {
				name = nameFromDistance(distance);
			}
			goals.add(new Goal(targetTime, distance, name, i));
		}
	}
	
	function nameFromDistance(distance) {
		return (distance >= 100 && distance % 100 == 0 ? (distance / 1000.0).format("%.1f") + "K" : distance.format("%d") + "M");
	}
	
	function compute(info) {
		
		// Ensure goals are configured correctly per user settings
		for (var i = 0; i < goals.size(); i++) {
			goals[i].distance = app.getProperty("goal" + goals[i].index + "Distance");
			goals[i].targetTime = app.getProperty("goal" + goals[i].index + "TargetTime") * 1000;
			goals[i].name = app.getProperty("goal" + goals[i].index + "Name");
			if (goals[i].name  == null || goals[i].name .length() == 0) {
				goals[i].name = nameFromDistance(goals[i].distance);
			}
		}
		
		// Compute values for next goal
		var goal = nextGoal();
		if (goal != null) {
			goal.compute(metrics.distance, metrics.elapsedTime, metrics.computedSpeed, metrics.kmOrMileInMeters);
		}
		
		// Capture actual time for completed goals
		for (var i = 0; i < goals.size(); i++) {
			if (goals[i].enabled() && !goals[i].completed && goals[i].distance <= metrics.distance) {
				goals[i].actualTime = metrics.elapsedTime;
				goals[i].completed = true;
			} else if (goals[i].distance > metrics.distance) {
				goals[i].actualTime = 0;
				goals[i].completed = false;
			}
		}
	}
	
	function nextGoal() {
		var goal = null;
		for (var i = 0; i < goals.size(); i++) {
			if (goals[i].enabled() && goals[i].distance > metrics.distance && (goal == null || goals[i].distance < goal.distance)) {
				goal = goals[i];
			}
		}
		return goal;
	}
	
	function lastCompletedGoal() {
		var goal = null;
		for (var i = 0; i < goals.size(); i++) {
			if (goals[i].enabled() && goals[i].completed && (goal == null || goals[i].distance > goal.distance)) {
				goal = goals[i];
			}
		}
		return goal;
	}
	
}
