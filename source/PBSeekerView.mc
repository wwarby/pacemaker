using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

class PBSeekerView extends Ui.DataField {

	hidden var backgroundColour = Graphics.COLOR_WHITE;
	hidden var hasBackgroundColourOption = false;
	hidden var darkMode = false;
	
	hidden var heartIcon;
	
	hidden var lightBatteryBackgroundColour = Graphics.COLOR_DK_GRAY;
	hidden var darkBatteryBackgroundColour = Graphics.COLOR_WHITE;
	hidden var batteryBackgroundColour;
	
	hidden var batteryColour = Graphics.COLOR_GREEN;
	hidden var batteryLowColour = Graphics.COLOR_YELLOW;
	hidden var batteryVeryLowColour = Graphics.COLOR_RED;
	
	hidden var textColour;
	hidden var lightTextColour = Graphics.COLOR_BLACK;
	hidden var darkTextColour = Graphics.COLOR_WHITE;
	
	hidden var labelColour;
	hidden var lightLabelColour = Graphics.COLOR_DK_GRAY;
	hidden var darkLabelColour = Graphics.COLOR_LT_GRAY;
	
	hidden var PACE_FONT = Graphics.FONT_NUMBER_MEDIUM;
	hidden var DIST_FONT = Graphics.FONT_NUMBER_MEDIUM;
	hidden var TIME_FONT = Graphics.FONT_NUMBER_MEDIUM;
	hidden var TIME_FONT_HOURS = Graphics.FONT_NUMBER_MILD;
	hidden var GOAL_TIME_FONT = Graphics.FONT_NUMBER_MILD;
	hidden var GOAL_DIST_FONT = Graphics.FONT_NUMBER_MILD;
	hidden var HR_FONT = Graphics.FONT_NUMBER_MEDIUM;
	hidden var LABEL_FONT = Graphics.FONT_XTINY;
	
	hidden var paceLabelStr;
	hidden var distLabelStr;
	hidden var timeLabelStr;
	hidden var goalLabelStr;
	
	hidden var halfMarathonAbbrStr;
	hidden var marathonAbbrStr;
	
	hidden const CENTER = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
	hidden const LEFT = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
	hidden const RIGHT = Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER;
	
	hidden var distanceUnits = System.UNIT_METRIC;
	
	hidden const ZERO_TIME = "0:00";
	hidden const ZERO_DISTANCE = "0.00";
	hidden const METERS_IN_MILE = 1609.34f;
	
	hidden var goalLabelSpace = 5;
	hidden var goalValueSpace = 10;
	hidden var kmOrMileInMeters = 1000.0f;
	hidden var paceData = new DataQueue(10);
	hidden var doUpdates = 0;
	
	hidden var hr = 0;
	hidden var distance = 0;
	hidden var elapsedTime = 0;
	
	var app;
	var goal1k;
	var goal1mi;
	var goal2mi;
	var goal5k;
	var goal10k;
	var goal15k;
	var goal10mi;
	var goalHM;
	var goalMA;
	
	var lastGoalTime;
	
	function initialize() {
		DataField.initialize();
	}

	function onLayout(dc) {
		setDeviceSettingsDependentVariables();
		heartIcon = Ui.loadResource(Rez.Drawables.HeartIcon);
	}
	
	function setDeviceSettingsDependentVariables() {
		
		distanceUnits = System.getDeviceSettings().distanceUnits;
		if (distanceUnits == System.UNIT_METRIC) {
			kmOrMileInMeters = 1000.0f;
			paceLabelStr = "/km";
		} else {
			kmOrMileInMeters = METERS_IN_MILE;
			paceLabelStr = "/mi";
		}
		
		distLabelStr = Ui.loadResource(Rez.Strings.distance);
		timeLabelStr = Ui.loadResource(Rez.Strings.time);
		halfMarathonAbbrStr = Ui.loadResource(Rez.Strings.halfMarathonAbbr);
		marathonAbbrStr = Ui.loadResource(Rez.Strings.marathonAbbr);
	}
	
	function setColours() {
		
		hasBackgroundColourOption = self has :getBackgroundColor;
		
		if (hasBackgroundColourOption) {
			backgroundColour = getBackgroundColor();
		}
		
		darkMode = (backgroundColour == Graphics.COLOR_BLACK);
		
		textColour = darkMode ? darkTextColour : lightTextColour;
		labelColour = darkMode ? darkLabelColour : lightLabelColour;
		batteryBackgroundColour = darkMode ? darkBatteryBackgroundColour : lightBatteryBackgroundColour;
	}

	//! The given info object contains all the current workout
	function compute(info) {
		if (info.currentSpeed != null) {
			paceData.add(info.currentSpeed);
		} else {
			paceData.reset();
		}
		
		elapsedTime = info.timerTime != null ? info.timerTime : 0;		
		hr = info.currentHeartRate != null ? info.currentHeartRate : 0;
		distance = info.elapsedDistance != null ? info.elapsedDistance : 0;
	}
	
	function onShow() {
		doUpdates = true;
		return true;
	}
	
	function onHide() {
		doUpdates = false;
	}
	
	function onUpdate(dc) {
		if (doUpdates == false) { return; }
		
		app = App.getApp();
		goal1k = app.getProperty("goal1k");
		goal1mi = app.getProperty("goal1mi");
		goal2mi = app.getProperty("goal2mi");
		goal5k = app.getProperty("goal5k");
		goal10k = app.getProperty("goal10k");
		goal15k = app.getProperty("goal15k");
		goal10mi = app.getProperty("goal10mi");
		goalHM = app.getProperty("goalHM");
		goalMA = app.getProperty("goalMA");
		
		setColours();
		
		// Reset background
		dc.setColor(backgroundColour, backgroundColour);
		dc.fillRectangle(0, 0, 240, 240);
		
		drawValues(dc);
	}
		
	function drawValues(dc) {
		
		// Pace
		var paceStr = getMinutesPerKmOrMile(computeAverageSpeed());
		var paceStrWidth = dc.getTextWidthInPixels(paceStr, PACE_FONT);
		dc.setColor(textColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(120, 33, PACE_FONT, paceStr, CENTER);
		dc.setColor(labelColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(120 + (paceStrWidth / 2) + 2, 41, LABEL_FONT, paceLabelStr, LEFT);
		
		// Grid line
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, 58, dc.getWidth(), 58);
		
		// Distance
		dc.setColor(labelColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(70, 74, LABEL_FONT, distLabelStr, CENTER);
		var distStr;
		if (distance > 0) {
			var distanceKmOrMiles = distance / kmOrMileInMeters;
			if (distanceKmOrMiles < 100) {
				distStr = distanceKmOrMiles.format("%.2f");
			} else {
				distStr = distanceKmOrMiles.format("%.1f");
			}
		} else {
			distStr = ZERO_DISTANCE;
		}
		dc.setColor(textColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(70, 104, DIST_FONT, distStr, CENTER);
				
		// Duration
		dc.setColor(labelColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(170, 74, LABEL_FONT, timeLabelStr, CENTER);
		var timeStr;
		var timeFont = TIME_FONT;
		if (elapsedTime != null && elapsedTime > 0) {
			var hours = null;
			var minutes = elapsedTime / 1000 / 60;
			var seconds = elapsedTime / 1000 % 60;
			
			if (minutes >= 60) {
				hours = minutes / 60;
				minutes = minutes % 60;
			}
			
			if (hours == null) {
				timeStr = minutes.format("%d") + ":" + seconds.format("%02d");
			} else {
				timeStr = hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
				timeFont = TIME_FONT_HOURS;
			}
		} else {
			timeStr = ZERO_TIME;
		}
		dc.setColor(textColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(170, 104, timeFont, timeStr, CENTER);
		
		// Grid line
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, 134, dc.getWidth(), 134);
		
		// Goal label
		var goalLabelStr = goalLabel();
		var goalLabelStrWidth = dc.getTextWidthInPixels(goalLabelStr, LABEL_FONT);
		
		// Goal time prediction
		var goalTimeStr;
		var goalTime = goalPredictedTime();
		if (goalTime != null && goalTime > 0) {
			var hours = null;
			var minutes = goalTime / 1000 / 60;
			var seconds = goalTime / 1000 % 60;
			
			if (minutes >= 60) {
				hours = minutes / 60;
				minutes = minutes % 60;
			}
			
			if (hours == null) {
				goalTimeStr = minutes.format("%d") + ":" + seconds.format("%02d");
			} else {
				goalTimeStr = hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
			}
		} else {
			goalTimeStr = ZERO_TIME;
		}
		var goalTimeStrWidth = dc.getTextWidthInPixels(goalTimeStr, GOAL_TIME_FONT);
		
		// Goal distance remaining
		var goalDistStr;
		var goalDist = goalRemainingDistance();
		if (goalDist > 0) {
			var distanceKmOrMiles = goalDist / kmOrMileInMeters;
			if (distanceKmOrMiles < 100) {
				goalDistStr = distanceKmOrMiles.format("%.2f");
			} else {
				goalDistStr = distanceKmOrMiles.format("%.1f");
			}
		} else {
			goalDistStr = ZERO_DISTANCE;
		}
		var goalDistStrWidth = dc.getTextWidthInPixels(goalDistStr, GOAL_DIST_FONT);
		
		// Goal rendering
		var totalGoalWidth = goalLabelStrWidth + goalLabelSpace + goalTimeStrWidth + goalValueSpace + goalDistStrWidth;
		var goalX = (240 - totalGoalWidth) / 2;
		var goalY = 159;
		
		dc.setColor(labelColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(goalX, goalY, LABEL_FONT, goalLabelStr, LEFT);
		goalX += goalLabelStrWidth + goalLabelSpace;
		
		dc.setColor(textColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(goalX, goalY, GOAL_TIME_FONT, goalTimeStr, LEFT);
		goalX += goalTimeStrWidth + goalValueSpace;
		
		dc.setColor(textColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(goalX, goalY, GOAL_DIST_FONT, goalDistStr, LEFT);
		
		// Grid line
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, 184, dc.getWidth(), 184);
		
		// Heart rate
		dc.drawBitmap(62, 200, heartIcon);
		dc.setColor(textColour, Graphics.COLOR_TRANSPARENT);
		dc.drawText(120, 210, HR_FONT, hr.format("%d"), CENTER);
		
		// Battery
		drawBattery(System.getSystemStats().battery, dc, 159, 203, 25, 12);
	}
	
	function getMinutesPerKmOrMile(speedMetersPerSecond) {
		if (speedMetersPerSecond != null && speedMetersPerSecond > 0.2) {
			var metersPerMinute = speedMetersPerSecond * 60.0;
			var minutesPerKmOrMilesDecimal = kmOrMileInMeters / metersPerMinute;
			var minutesPerKmOrMilesFloor = minutesPerKmOrMilesDecimal.toNumber();
			var seconds = (minutesPerKmOrMilesDecimal - minutesPerKmOrMilesFloor) * 60;
			return minutesPerKmOrMilesDecimal.format("%2d") + ":" + seconds.format("%02d");
		}
		return ZERO_TIME;
	}
	
	function computeAverageSpeed() {
		var size = 0;
		var data = paceData.getData();
		var sumOfData = 0.0;
		for (var i = 0; i < data.size(); i++) {
			if (data[i] != null) {
				sumOfData = sumOfData + data[i];
				size++;
			}
		}
		if (sumOfData > 0) {
			return sumOfData / size;
		}
		return 0.0;
	}
	
	function goalDistance() {
		if (distance == null || distance == 0) { return 0; }
		if (goal1k && distance < 1000) { return 1000; }
		if (goal1mi && distance < METERS_IN_MILE) { return METERS_IN_MILE; }
		if (goal2mi && distance < METERS_IN_MILE * 2) { return METERS_IN_MILE * 2; }
		if (goal5k && distance < 5000) { return 5000; }
		if (goal10k && distance < 10000) { return 10000; }
		if (goal15k && distance < 15000) { return 15000; }
		if (goal10mi && distance < METERS_IN_MILE * 10) { return METERS_IN_MILE * 10; }
		if (goalHM && distance < 21097.5) { return 21097.5; }
		if (goalMA && distance < 42195) { return 42195; }
		return 0;
	}
	
	function goalLabel() {
		if (goal1k && distance < 1000) { return "1K"; }
		if (goal1mi && distance < METERS_IN_MILE) { return "1MI"; }
		if (goal2mi && distance < METERS_IN_MILE * 2) { return "2MI"; }
		if (goal5k && distance < 5000) { return "5K"; }
		if (goal10k && distance < 10000) { return "10K"; }
		if (goal15k && distance < 15000) { return "15K"; }
		if (goal10mi && distance < METERS_IN_MILE * 10) { return "10MI"; }
		if (goalHM && distance < 21097.5) { return halfMarathonAbbrStr; }
		if (goalMA && distance < 42195) { return marathonAbbrStr; }
		return "NO GOAL";
	}
	
	function goalPredictedTime() {
		if (distance == null || distance == 0 || elapsedTime == null || elapsedTime == 0) { return 0; }
		if (lastGoalTime != null) { return lastGoalTime; }
		var goal = goalDistance();
		var remainingDistance = goal - distance;
		if (remainingDistance <= 0 && lastGoalTime == null) {
			lastGoalTime = elapsedTime;
			return lastGoalTime;
		}
		var speedMetersPerSecond = computeAverageSpeed();
		var secondsRemainingAtCurrentSpeed = (remainingDistance / speedMetersPerSecond) * 1000;
		var preditctedTime = floatToNumber(elapsedTime + secondsRemainingAtCurrentSpeed);
		return preditctedTime;
	}
	
	function goalRemainingDistance() {
		return max(0, goalDistance() - distance);
	}
	
	function min(num1, num2) {
		return num1 < num2 ? num1 : num2;
	}
	
	function max(num1, num2) {
		return num1 > num2 ? num1 : num2;
	}
	
	function floatToNumber(float) {
		var floor = float.toNumber();
		if (float - floor > 0) {
			return floor + 1;
		}
		return floor;
	}
	
	function drawBattery(battery, dc, x, y, width, height) {
		
		var cornerRadius = 1;
		var connectorCornerRadius = 1;
		var connectorVisibleWidth = 4;
		
		var batteryWidth = width - connectorVisibleWidth;
		
		var connectorX = x + width - connectorVisibleWidth - connectorCornerRadius;
		var connectorY = y + (height / 4);
		var connectorWidth = connectorVisibleWidth + connectorCornerRadius;
		var connectorHeight = height - (height / 2);
		
		dc.setColor(batteryBackgroundColour, Graphics.COLOR_TRANSPARENT);
		dc.fillRoundedRectangle(connectorX, connectorY, connectorWidth, connectorHeight, connectorCornerRadius);
		
		dc.setColor(batteryBackgroundColour, Graphics.COLOR_TRANSPARENT);
		dc.fillRoundedRectangle(x, y, batteryWidth, height, cornerRadius);
		
		if (battery < 10) {
			dc.setColor(batteryVeryLowColour, Graphics.COLOR_TRANSPARENT);
		} else if (battery < 30) {
			dc.setColor(batteryLowColour, Graphics.COLOR_TRANSPARENT);
		} else {
			dc.setColor(batteryColour, Graphics.COLOR_TRANSPARENT);
		}
		
		dc.fillRoundedRectangle(x, y, max(batteryWidth * battery / 100, 3), height, cornerRadius);
			
	}

}
