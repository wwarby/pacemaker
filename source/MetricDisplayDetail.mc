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
			valueText = formatTime((activityMetrics.computedPace == null ? 0 : activityMetrics.computedPace) * 1000);
			useGoalColour = !goalMetrics.goalCompleted();
		} else if (metric == 5) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.pace) : null;
			if (goalMetrics.goalSet()) {
				var delta = goalMetrics.paceDelta(activityMetrics.computedPace) * 1000.0;
				valueText = formatTime(delta.abs());
				if (delta > 0) {
					valueText = "+" + valueText;
				} else if (delta < 0) {
					valueText = "-" + valueText;
				}
			} else {
				valueText = Ui.loadResource(Rez.Strings.noGoal);
			}
			isError = !goalMetrics.goalSet();
			useGoalColour = !isError && !goalMetrics.goalCompleted();
		} else if (metric == 6) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.dist) : null;
			valueText = formatDistance(activityMetrics.elapsedDistance, activityMetrics.kmOrMileInMeters);
		} else if (metric == 7) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.finish) : null;
			valueText = goalMetrics.goalDistance == null || goalMetrics.goalDistance == 0 ? Ui.loadResource(Rez.Strings.noGoal) : formatDistance(goalMetrics.remainingDistance, activityMetrics.kmOrMileInMeters);
			isError = goalMetrics.goalDistance == null || goalMetrics.goalDistance == 0;
		} else if (metric == 8) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.finish) : null;
			valueText =  goalMetrics.goalSet() ? formatTime(goalMetrics.predictedTime) : Ui.loadResource(Rez.Strings.noGoal);
			isError = !goalMetrics.goalSet();
			useGoalColour = !isError;
		} else if (metric == 9) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.finish) : null;
			if (goalMetrics.goalSet()) {
				valueText = formatTime(goalMetrics.delta().abs());
				if (goalMetrics.delta() > 0) {
					valueText = "+" + valueText;
				} else if (goalMetrics.delta() < 0) {
					valueText = "-" + valueText;
				}
			} else {
				valueText = Ui.loadResource(Rez.Strings.noGoal);
			}
			isError = !goalMetrics.goalSet();
			useGoalColour = !isError;
		} else if (metric == 10) {
			labelText = hasLabel ? Ui.loadResource(Rez.Strings.time) : null;
			valueText = formatTime(activityMetrics.timerTime);
		}
		
		width = valueText == null ? 0 : dc.getTextWidthInPixels(valueText, Gfx.FONT_NUMBER_MEDIUM);
	}
	
	function icon() {
		return IconLoader.getIcon(metricId, false);
	}
	
	function iconReverse() {
		return IconLoader.getIcon(metricId, true);
	}
	
	function formatTime(milliseconds) {
		if (milliseconds != null && milliseconds > 0) {
			var hours = null;
			var minutes = Math.floor(milliseconds / 1000 / 60).toNumber();
			var seconds = Math.floor(milliseconds / 1000).toNumber() % 60;
			if (minutes >= 60) {
				hours = minutes / 60;
				minutes = minutes % 60;
			}
			if (hours == null) {
				return minutes.format("%d") + ":" + seconds.format("%02d");
			} else {
				return hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
			}
		} else {
			return Ui.loadResource(Rez.Strings.zeroTime);
		}
	}
	
	function formatDistance(meters, kmOrMileInMeters) {
		if (meters != null && meters > 0) {
			var distanceKmOrMiles = meters / kmOrMileInMeters;
			if (distanceKmOrMiles < 100) {
				return distanceKmOrMiles.format("%.2f");
			} else {
				return distanceKmOrMiles.format("%.1f");
			}
		} else {
			return Ui.loadResource(Rez.Strings.zeroDistance);
		}
	}
	
}
