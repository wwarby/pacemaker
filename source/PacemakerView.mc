using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using TimeFormat;
using DistanceFormat;
using Globals;
using Calc;

class PBSeekerView extends Ui.DataField {
	
	hidden const LABEL_FONT = Gfx.FONT_XTINY;
	hidden const VALUE_FONT = Gfx.FONT_NUMBER_MILD;
	hidden const VALUE_FONT_LARGE = Gfx.FONT_NUMBER_MEDIUM;
	
	hidden const LABEL_COLOUR = Gfx.COLOR_DK_GRAY;
	hidden const LABEL_COLOUR_DARK_MODE = Gfx.COLOR_LT_GRAY;
	
	hidden const VALUE_COLOUR = Gfx.COLOR_BLACK;
	hidden const VALUE_COLOUR_DARK_MODE = Gfx.COLOR_WHITE;
	
	hidden const ON_TARGET_COLOUR = Gfx.COLOR_DK_GREEN;
	hidden const OFF_TARGET_COLOUR = Gfx.COLOR_RED;
	
	hidden var app;
	
	hidden var upIcon;
	hidden var downIcon;
	hidden var paceIcon;
	hidden var finishIcon;
	hidden var finishReverseIcon;
	hidden var cadenceIcon;
	hidden var heartRateIcon;
	hidden var darkModeIcons = false;
	
	hidden var darkMode = false;
	hidden var backgroundColour = Gfx.COLOR_WHITE;
	hidden var labelColour;
	hidden var valueColour;
	hidden var onTargetColour;
	hidden var offTargetColour;
	
	hidden var distLabelText;
	hidden var timeLabelText;
	
	hidden var doUpdates = 0;
	
	hidden var device;
	hidden var metrics;
	hidden var goals;
	
	function initialize() {
		DataField.initialize();
		app = App.getApp();
		metrics = new ActivityMetrics();
		goals = new GoalMetrics(metrics);
	}

	function onLayout(dc) {
		device = new DeviceDetails();
		setDeviceSettingsDependentVariables(device.settings);
	}
	
	function setDeviceSettingsDependentVariables(deviceSettings) {
		metrics.setDeviceSettingsDependentVariables(deviceSettings);
		distLabelText = Ui.loadResource(Rez.Strings.distance).toUpper();
		timeLabelText = Ui.loadResource(Rez.Strings.time).toUpper();
	}

	function compute(info) {
		metrics.compute(info);
		goals.compute(info);
	}
	
	function onShow() {
		doUpdates = true;
		return true;
	}
	
	function onHide() {
		doUpdates = false;
	}
	
	function setColours() {
		if (self has :getBackgroundColor) {
			backgroundColour = getBackgroundColor();
		}
		darkMode = (backgroundColour == Gfx.COLOR_BLACK);
		labelColour = darkMode ? LABEL_COLOUR_DARK_MODE : LABEL_COLOUR;
		valueColour = darkMode ? VALUE_COLOUR_DARK_MODE : VALUE_COLOUR;
		
		var colourText = app.getProperty("colourText");
		if (colourText) {
			onTargetColour = ON_TARGET_COLOUR;
			offTargetColour = OFF_TARGET_COLOUR;
		} else {
			onTargetColour = valueColour;
			offTargetColour = valueColour;
		}
	}
	
	function setIcons() {
		
		if (upIcon == null) {
			upIcon = Ui.loadResource(Rez.Drawables.upIcon);
		}
		
		if (downIcon == null) {
			downIcon = Ui.loadResource(Rez.Drawables.downIcon);
		}
		
		if (paceIcon == null || (darkModeIcons && !darkMode)) {
			paceIcon = Ui.loadResource(Rez.Drawables.paceIcon);
		}
		
		if (paceIcon == null || (!darkModeIcons && darkMode)) {
			paceIcon = Ui.loadResource(Rez.Drawables.paceDarkModeIcon);
		}
		
		if (finishIcon == null || (darkModeIcons && !darkMode)) {
			finishIcon = Ui.loadResource(Rez.Drawables.finishIcon);
		}
		
		if (finishIcon == null || (!darkModeIcons && darkMode)) {
			finishIcon = Ui.loadResource(Rez.Drawables.finishDarkModeIcon);
		}
		
		if (finishReverseIcon == null || (darkModeIcons && !darkMode)) {
			finishReverseIcon = Ui.loadResource(Rez.Drawables.finishReverseIcon);
		}
		
		if (finishReverseIcon == null || (!darkModeIcons && darkMode)) {
			finishReverseIcon = Ui.loadResource(Rez.Drawables.finishDarkModeReverseIcon);
		}
		
		if (cadenceIcon == null || (darkModeIcons && !darkMode)) {
			cadenceIcon = Ui.loadResource(Rez.Drawables.cadenceIcon);
		}
		
		if (cadenceIcon == null || (!darkModeIcons && darkMode)) {
			cadenceIcon = Ui.loadResource(Rez.Drawables.cadenceDarkModeIcon);
		}
		
		if (heartRateIcon == null) {
			heartRateIcon = Ui.loadResource(Rez.Drawables.heartRateIcon);
		}
		
		darkModeIcons = darkMode;
	}
	
	function onUpdate(dc) {
		
		if (doUpdates == false) { return; }
		
		setColours();
		setIcons();
		
		var activityStarted = metrics.elapsedTime > 0;
		
		// Format values
		var paceText =  TimeFormat.formatTime(metrics.computedPace * 1000);
		var distText = DistanceFormat.formatDistance(metrics.distance, metrics.kmOrMileInMeters);
		var timeText =  TimeFormat.formatTime(metrics.elapsedTime);
		var cadenceText = metrics.computedCadence.format("%d");
		var heartRateText = metrics.computedHeartRate.format("%d");
		
		// Format goal values
		var goal = goals.nextGoal();
		var goalPaceDelta;
		var goalTimeDelta;
		var goalLabelText;
		var goalTimeText;
		var goalDistText;
		var goalPaceDeltaText;
		var goalTimeDeltaText;
		var goalCompleted = false;
		var goalOnTarget = true;
		if (goal != null) {
			goalLabelText = goal.name.toUpper();
			goalTimeText = TimeFormat.formatTime(goal.predictedTime);
			goalDistText = DistanceFormat.formatDistance(goal.remainingDistance, metrics.kmOrMileInMeters);
			goalPaceDelta = Calc.min(999, (metrics.computedPace - goal.requiredPace).abs());
			goalTimeDelta = Calc.min(999, Math.ceil(goal.delta().abs()  / 1000.0));
			goalOnTarget = goal.onTarget();
		} else {
			goal = goals.lastCompletedGoal();
			if (goal != null) {
				goalLabelText = goal.name.toUpper();
				goalTimeText = TimeFormat.formatTime(goal.actualTime);
				goalDistText = null;
				goalPaceDelta = 0;
				goalTimeDelta = Calc.min(999, Math.ceil(goal.delta().abs()  / 1000.0));
				goalCompleted = true;
				goalOnTarget = goal.onTarget();
			} else {
				goalLabelText = null;
				goalTimeText = null;
				goalDistText = null;
			}
		}
		var goalSet = goalTimeText != null && !goalCompleted;
		var targetColour =
			metrics.elapsedTime > 0 ?
				goalOnTarget ? onTargetColour : offTargetColour :
				valueColour;
		
		if ((goalSet || goalCompleted) && activityStarted) {
			if (!goalCompleted) {
				goalPaceDeltaText = goalPaceDelta.format("%d");
			} else {
				goalPaceDelta = 0;
			}
			goalTimeDeltaText = goalTimeDelta.format("%d");
		} else {
			goalPaceDelta = 0;
			goalTimeDelta = 0;
		}
		if (goalPaceDeltaText != null && (goalPaceDeltaText.length() == 1 || goalPaceDeltaText.length() == 2)) { goalPaceDeltaText += "s"; }
		if (goalTimeDeltaText != null && (goalTimeDeltaText.length() == 1 || goalTimeDeltaText.length() == 2)) { goalTimeDeltaText += "s"; }
		
		// Calculate positions
		var center = dc.getWidth() / 2;
		var leftQuadrant = center / 2;
		var rightQuadrant = center + leftQuadrant;
		var topGridLineY =
			device.round240 ? 56 :
			device.round218 ? 50 :
			0;
		var topRowY = topGridLineY / 2;
		var topRowYLabelOffset =
			device.round240 ? 9 :
			device.round218 ? 9 :
			0;
		var goalPaceDeltaIconY =
			 device.round240 ? 16 :
			device.round218 ? 16 :
			0;
		var secondRowLabelsY =
			device.round240 ? topGridLineY + 17 :
			device.round218 ? topGridLineY + 15 :
			0;
		var secondRowValuesY =
			device.round240 ? secondRowLabelsY + 30 :
			device.round218 ? secondRowLabelsY + 28 :
			0;
		var middleGridLineY =
			device.round240 ? 132 :
			device.round218 ? 120 :
			0;
		var bottomGridLineY = device.height - topGridLineY;
		var bottomRowY = device.height - ((device.height - bottomGridLineY) / 2) - 5;
		var bottomRowXSpace =
			device.round240 ? 6 :
			device.round218 ? 6 :
			0;
		var thirdRowY = middleGridLineY + ((bottomGridLineY - middleGridLineY) / 2);
		var thirdRowMinX =
		 	device.round240 ? 12 :
			device.round218 ? 12 :
			0;
		var thirdRowValueSpace =
		 	device.round240 ? 6 :
			device.round218 ? 6 :
			0;
		var thirdRowYLabelOffset =
			device.round240 ? 5 :
			device.round218 ? 5 :
			0;
		var goalTimeDeltaIconY =
			 device.round240 ? thirdRowY - 14 :
			device.round218 ? thirdRowY - 14 :
			0;
		var goalTimeDeltaSpace =
			 device.round240 ? 3 :
			device.round218 ? 3 :
			0;
		var finishIconSpace = 5;
		var finishIconY = thirdRowY - (finishIcon.getHeight() / 2);
		
		// Uncomment to test realistic max widths
		/*
		paceText = "88:88";
		goalPaceDeltaText = "888";
		distText = "88.88";
		timeText = "88:88:88";
		goalLabelText = "ABCDEF";
		goalTimeText = "88:88:88";
		goalDistText = "88.88";
		cadenceText = "888";
		heartRateText = "888";
		*/
		
		// Measure text widths
		var paceTextWidth = dc.getTextWidthInPixels(paceText, VALUE_FONT_LARGE);
		var timeTextWidth = dc.getTextWidthInPixels(timeText, VALUE_FONT_LARGE);
		var goalTimeTextWidth = goalTimeText == null ? 0 : dc.getTextWidthInPixels(goalTimeText, VALUE_FONT);
		var goalDistTextWidth = goalDistText == null ? 0 : dc.getTextWidthInPixels(goalDistText, VALUE_FONT);
		var goalPaceDeltaTextWidth = goalPaceDeltaText == null ? 0 : dc.getTextWidthInPixels(goalPaceDeltaText, LABEL_FONT);
		var goalTimeDeltaTextWidth = goalTimeDeltaText == null ? 0 : dc.getTextWidthInPixels(goalTimeDeltaText, LABEL_FONT);
		var cadenceTextWidth = dc.getTextWidthInPixels(cadenceText, VALUE_FONT);
		var heartRateTextWidth = dc.getTextWidthInPixels(heartRateText, VALUE_FONT);
		
		// Render background
		dc.setColor(backgroundColour, backgroundColour);
		dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
		
		// Render pace
		dc.setColor(goalSet ? targetColour : valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(center, topRowY, VALUE_FONT_LARGE, paceText, Globals.VCENTER);
		
		// Render pace delta
		if (goalPaceDelta > 0) {
			var goalPaceDeltaX = center + (paceTextWidth / 2) + 3;
			dc.setColor(targetColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(goalPaceDeltaX, topRowY + topRowYLabelOffset, LABEL_FONT, goalPaceDeltaText, Globals.LEFT_VCENTER);
			dc.drawBitmap(goalPaceDeltaX, goalPaceDeltaIconY, goalOnTarget ? upIcon : downIcon);
		}
		
		// Render pace icon
		var paceIconX = center - (paceTextWidth / 2) - paceIcon.getWidth() - 4;
		var paceIconY =
			device.round240 ? topGridLineY - paceIcon.getHeight() - 10 :
			device.round218 ? topGridLineY - paceIcon.getHeight() - 8 :
			0;
		dc.drawBitmap(paceIconX, paceIconY, paceIcon);
		
		// Render top grid line
		drawHorizontalGridLine(dc, topGridLineY);
		
		// Render bottom vertical grid line
		drawVerticalGridLine(dc, center, topGridLineY, middleGridLineY);
		
		// Render distance
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(leftQuadrant, secondRowLabelsY, LABEL_FONT, distLabelText, Globals.VCENTER);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(leftQuadrant, secondRowValuesY, VALUE_FONT_LARGE, distText, Globals.VCENTER);
				
		// Render elapsed time
		var timeFont = timeTextWidth < 100 ? VALUE_FONT_LARGE : VALUE_FONT;
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(rightQuadrant, secondRowLabelsY, LABEL_FONT, timeLabelText, Globals.VCENTER);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(rightQuadrant, secondRowValuesY, timeFont, timeText, Globals.VCENTER);
		
		// Render middle grid line
		drawHorizontalGridLine(dc, middleGridLineY);
		
		// Render goal label
		if (goalSet || goalCompleted) {
			var goalLabelTextWidth = dc.getTextWidthInPixels(goalLabelText, LABEL_FONT);
			var goalLabelTextHeight = dc.getTextDimensions(goalLabelText, LABEL_FONT)[1];
			dc.setColor(backgroundColour, backgroundColour);
			dc.fillRectangle(center - (goalLabelTextWidth / 2) - 5, middleGridLineY - (goalLabelTextHeight / 2) + 2, goalLabelTextWidth + 10, goalLabelTextHeight - 4);
			dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(center, middleGridLineY, LABEL_FONT, goalLabelText, Globals.VCENTER);
		}
		
		// Render completed goal
		if (goalCompleted) {
			
			var goalTimeDeltaWidth = goalTimeDelta > 0 ? goalTimeDeltaTextWidth + finishIconSpace : 0;
			var totalGoalWidth = goalTimeTextWidth + goalTimeDeltaWidth + (finishIcon.getWidth() * 2) + (finishIconSpace * 2);
			var goalX = (dc.getWidth() - totalGoalWidth) / 2;
			
			dc.drawBitmap(goalX, finishIconY, finishReverseIcon);
			goalX += finishIcon.getWidth() + finishIconSpace;
			
			dc.setColor(targetColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(goalX, thirdRowY, VALUE_FONT, goalTimeText, Globals.LEFT_VCENTER);
			goalX += goalTimeTextWidth;
			
			if (goalTimeDelta > 0) {
				goalX += goalTimeDeltaSpace;
				dc.setColor(targetColour, Gfx.COLOR_TRANSPARENT);
				dc.drawText(goalX, thirdRowY + thirdRowYLabelOffset, LABEL_FONT, goalTimeDeltaText, Globals.LEFT_VCENTER);
				dc.drawBitmap(goalX, goalTimeDeltaIconY, goalOnTarget ? upIcon : downIcon);
				goalX += goalTimeDeltaTextWidth;
			}
			
			goalX += finishIconSpace;
			dc.drawBitmap(goalX, finishIconY, finishIcon);
			
		// Render uncompleted goal
		} else if (goalSet) {
			
			dc.setColor(targetColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(center - thirdRowValueSpace, thirdRowY, VALUE_FONT, goalTimeText, Globals.RIGHT_VCENTER);
			
			var goalTimeDeltaX = center - thirdRowValueSpace - goalTimeTextWidth - goalTimeDeltaTextWidth - goalTimeDeltaSpace;
			
			if (goalTimeDelta > 0 && goalTimeDeltaX > thirdRowMinX) {
				dc.setColor(targetColour, Gfx.COLOR_TRANSPARENT);
				dc.drawText(goalTimeDeltaX, thirdRowY + thirdRowYLabelOffset, LABEL_FONT, goalTimeDeltaText, Globals.LEFT_VCENTER);
				dc.drawBitmap(goalTimeDeltaX, goalTimeDeltaIconY, goalOnTarget ? upIcon : downIcon);
			}
			
			dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(center + thirdRowValueSpace, thirdRowY, VALUE_FONT, goalDistText, Globals.LEFT_VCENTER);
			
			dc.drawBitmap(center + thirdRowValueSpace + goalDistTextWidth + finishIconSpace, finishIconY, finishIcon);
			
		// Render no goal set
		} else {
			dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(center, thirdRowY, LABEL_FONT, Ui.loadResource(Rez.Strings.noGoalSet).toUpper(), Globals.VCENTER);
		}
		
		// Render bottom grid line
		drawHorizontalGridLine(dc, bottomGridLineY);
		
		// Render bottom vertical grid line
		drawVerticalGridLine(dc, center, bottomGridLineY, device.height);
		
		// Render cadence
		var cadenceIconX = center - cadenceTextWidth - (bottomRowXSpace * 2) - cadenceIcon.getWidth() + 8;
		var cadenceIconY = bottomRowY - (cadenceIcon.getHeight() / 2);
		dc.drawBitmap(cadenceIconX, cadenceIconY, cadenceIcon);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(center - bottomRowXSpace, bottomRowY, VALUE_FONT, cadenceText, Globals.RIGHT_VCENTER);
		
		// Render heart rate
		var heartRateIconX = center + heartRateTextWidth + (bottomRowXSpace * 2) - 2;
		var heartRateIconY = bottomRowY - (heartRateIcon.getHeight() / 2);
		dc.drawBitmap(heartRateIconX, heartRateIconY, heartRateIcon);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(center + bottomRowXSpace, bottomRowY, VALUE_FONT, heartRateText, Globals.LEFT_VCENTER);
	}
	
	function drawHorizontalGridLine(dc, y) {
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(0, y, dc.getWidth(), y);
	}
	
	function drawVerticalGridLine(dc, x, yStart, yEnd) {
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(x, yStart, x, yEnd);
	}

}
