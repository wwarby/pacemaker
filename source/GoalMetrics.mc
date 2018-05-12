using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Calc;
using Globals;

class GoalMetrics {
	
	hidden var goals = new[0];
	
	hidden var customGoal;

	hidden var app;
	
	var metrics;
	
	function initialize(parentMetrics) {
		app = App.getApp();
		metrics = parentMetrics;
		
		addGoal(1000, "1K", "enableGoal1k");
		addGoal(Globals.METERS_IN_MILE, "1MI", "enableGoal1mi");
		addGoal(2000, "2K", "enableGoal2k");
		addGoal(Globals.METERS_IN_MILE * 2, "2MI", "enableGoal2mi");
		addGoal(5000, "5K", "enableGoal5k");
		addGoal(Globals.METERS_IN_MILE * 5, "5MI", "enableGoal5mi");
		addGoal(10000, "10K", "enableGoal10k");
		addGoal(15000, "15K", "enableGoal15k");
		addGoal(Globals.METERS_IN_MILE * 10, "10MI", "enableGoal10mi");
		addGoal(21097.5, Ui.loadResource(Rez.Strings.halfMarathonAbbr), "enableGoalHM");
		addGoal(42195, Ui.loadResource(Rez.Strings.marathonAbbr), "enableGoalMA");
		
		customGoal = new Goal();
		goals.add(customGoal);
		configureCustomGoal();
	}
	
	hidden function addGoal(distance, label, enabledSettingName) {
		var goal = new Goal();
		goal.enabledSettingName = enabledSettingName;
		goal.enabled = app.getProperty(enabledSettingName);
		goal.distance = distance;
		goal.label = label;
		goals.add(goal);
		return goal;
	}
	
	function configureCustomGoal() {
		customGoal.distance = app.getProperty("customGoalDistance");
		customGoal.label = app.getProperty("customGoalLabel");
		customGoal.enabled = customGoal.distance != null && customGoal.distance > 0;
		if (customGoal.label == null || customGoal.label == "") {
			customGoal.label = "CUST";
		}
	}
	
	function compute(info) {
		
		// Ensure goals are configured correctly per user settings
		for (var i = 0; i < goals.size(); i++) {
			if (goals[i].enabledSettingName != null) { 
				goals[i].enabled = app.getProperty(goals[i].enabledSettingName);
			}
		}
		configureCustomGoal();
		
		// Compute values for next goal
		var goal = nextGoal();
		if (goal != null) {
			goal.compute(metrics.distance, metrics.elapsedTime, metrics.speedMetersPerSecond());
		}
		
		// Capture actual time for completed goals
		for (var i = 0; i < goals.size(); i++) {
			if (goals[i].enabled && !goals[i].completed && goals[i].distance <= metrics.distance) {
				goals[i].actualTime = metrics.elapsedTime;
				goals[i].completed = true;
			}
		}
	}
	
	function nextGoal() {
		var goal = null;
		for (var i = 0; i < goals.size(); i++) {
			if (goals[i].enabled && goals[i].distance > metrics.distance && (goal == null || goals[i].distance < goal.distance)) {
				goal = goals[i];
			}
		}
		return goal;
	}
	
	function lastCompletedGoal() {
		var goal = null;
		for (var i = 0; i < goals.size(); i++) {
			if (goals[i].enabled && goals[i].completed && (goal == null || goals[i].distance > goal.distance)) {
				goal = goals[i];
			}
		}
		return goal;
	}
	
}
