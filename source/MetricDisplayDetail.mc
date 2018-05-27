using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using IconLoader;

class MetricDisplayDetail {

	var labelText;
	var valueText;
	var width;
	var useGoalColour = false;
	var isError = false;
	var metricId;
	
	function initialize(metric, hasLabel, hasIcon, activityMetrics, goalMetrics, dc) {
		
		metricId = metric;
		
		if (metric == 0) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.hr) : null;
			valueText = (activityMetrics.computedHeartRate == null ? 0 : activityMetrics.computedHeartRate).format("%d");
		} else if (metric == 1) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.cad) : null;
			valueText = (activityMetrics.computedCadence == null ? 0 : activityMetrics.computedCadence).format("%d");
		} else if (metric == 2) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.power) : null;
			valueText = (activityMetrics.computedPower == null ? 0 : activityMetrics.computedPower).format("%d");
		} else if (metric == 3) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.cal) : null;
			valueText = (activityMetrics.calories == null ? 0 : activityMetrics.calories).format("%d");
		} else if (metric == 4) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.pace) : null;
			valueText = TimeFormat.formatTime((activityMetrics.computedPace == null ? 0 : activityMetrics.computedPace) * 1000);
			useGoalColour = !goalMetrics.goalCompleted();
		} else if (metric == 5) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.dist) : null;
			valueText = DistanceFormat.formatDistance(activityMetrics.elapsedDistance, activityMetrics.kmOrMileInMeters);
		} else if (metric == 6) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.finish) : null;
			valueText = goalMetrics.goalDistance == null || goalMetrics.goalDistance == 0 ? Ui.loadResource(Rez.Strings.noGoal) : DistanceFormat.formatDistance(goalMetrics.remainingDistance, activityMetrics.kmOrMileInMeters);
			isError = goalMetrics.goalDistance == null || goalMetrics.goalDistance == 0;
		} else if (metric == 7) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.finish) : null;
			valueText =  goalMetrics.goalSet() ? TimeFormat.formatTime(goalMetrics.predictedTime) : Ui.loadResource(Rez.Strings.noGoal);
			isError = !goalMetrics.goalSet();
			useGoalColour = !isError;
		} else if (metric == 8) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.time) : null;
			valueText = TimeFormat.formatTime(activityMetrics.timerTime);
		}
		
		width = valueText == null ? 0 : dc.getTextWidthInPixels(valueText, Gfx.FONT_NUMBER_MEDIUM);
	}
	
	function icon() {
		return IconLoader.getIcon(metricId, false);
	}
	
	function iconReverse() {
		return IconLoader.getIcon(metricId, true);
	}
	
}
