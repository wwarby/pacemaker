using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using TimeFormat;
using DistanceFormat;
using Globals;
using Calc;

class PBSeekerView extends Ui.DataField {
	
	hidden const LABEL_FONT = Gfx.FONT_XTINY;
	hidden const VALUE_FONT = Gfx.FONT_NUMBER_MILD;
	hidden const VALUE_FONT_LARGE = Gfx.FONT_NUMBER_MEDIUM;
	
	hidden const GOAL_LABEL_SPACE = 5;
	hidden const GOAL_VALUE_SPACE = 10;
	
	hidden const BATTERY_BACKGROUND_COLOUR = Gfx.COLOR_LT_GRAY;
	hidden const BATTERY_BACKGROUND_COLOUR_DARK_MODE = Gfx.COLOR_WHITE;
	
	hidden const LABEL_COLOUR = Gfx.COLOR_DK_GRAY;
	hidden const LABEL_COLOUR_DARK_MODE = Gfx.COLOR_LT_GRAY;
	
	hidden const VALUE_COLOUR = Gfx.COLOR_BLACK;
	hidden const VALUE_COLOUR_DARK_MODE = Gfx.COLOR_WHITE;
	
	hidden const SUCCESS_COLOUR = Gfx.COLOR_DK_GREEN;
	
	hidden const BATTERY_COLOUR = Gfx.COLOR_DK_GREEN;
	hidden const BATTERY_COLOUR_LOW = Gfx.COLOR_YELLOW;
	hidden const BATTERY_COLOUR_VERY_LOW = Gfx.COLOR_RED;
	
	hidden var upIcon;
	hidden var downIcon;
	hidden var paceIcon;
	hidden var finishIcon;
	hidden var cadenceIcon;
	hidden var heartRateIcon;
	hidden var darkModeIcons = false;
	
	hidden var darkMode = false;
	hidden var backgroundColour = Gfx.COLOR_WHITE;
	hidden var labelColour;
	hidden var valueColour;
	hidden var batteryBackgroundColour;
	
	hidden var distLabelText;
	hidden var timeLabelText;
	
	hidden var doUpdates = 0;
	
	hidden var device;
	hidden var metrics;
	hidden var goals;
	
	function initialize() {
		DataField.initialize();
		metrics = new ActivityMetrics();
		goals = new GoalMetrics(metrics);
	}

	function onLayout(dc) {
		device = new DeviceDetails();
		setDeviceSettingsDependentVariables(device.settings);
	}
	
	function setDeviceSettingsDependentVariables(deviceSettings) {
		metrics.setDeviceSettingsDependentVariables(deviceSettings);
		distLabelText = Ui.loadResource(Rez.Strings.distance);
		timeLabelText = Ui.loadResource(Rez.Strings.time);
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
		batteryBackgroundColour = darkMode ? BATTERY_BACKGROUND_COLOUR_DARK_MODE : BATTERY_BACKGROUND_COLOUR;
	}
	
	function setIcons() {
		
		if (upIcon == null) {
			upIcon = Ui.loadResource(Rez.Drawables.UpIcon);
		}
		
		if (downIcon == null) {
			downIcon = Ui.loadResource(Rez.Drawables.DownIcon);
		}
		
		if (paceIcon == null || (darkModeIcons && !darkMode)) {
			paceIcon = Ui.loadResource(Rez.Drawables.PaceIcon);
		}
		
		if (paceIcon == null || (!darkModeIcons && darkMode)) {
			paceIcon = Ui.loadResource(Rez.Drawables.PaceDarkModeIcon);
		}
		
		if (finishIcon == null || (darkModeIcons && !darkMode)) {
			finishIcon = Ui.loadResource(Rez.Drawables.FinishIcon);
		}
		
		if (finishIcon == null || (!darkModeIcons && darkMode)) {
			finishIcon = Ui.loadResource(Rez.Drawables.FinishDarkModeIcon);
		}
		
		if (cadenceIcon == null || (darkModeIcons && !darkMode)) {
			cadenceIcon = Ui.loadResource(Rez.Drawables.CadenceIcon);
		}
		
		if (cadenceIcon == null || (!darkModeIcons && darkMode)) {
			cadenceIcon = Ui.loadResource(Rez.Drawables.CadenceDarkModeIcon);
		}
		
		if (heartRateIcon == null) {
			heartRateIcon = Ui.loadResource(Rez.Drawables.HeartRateIcon);
		}
		
		darkModeIcons = darkMode;
	}
	
	function onUpdate(dc) {
		
		if (doUpdates == false) { return; }
		
		setColours();
		setIcons();
		
		// Format values
		var paceText =  TimeFormat.formatTime(metrics.computedPace * 1000);
		var distText = DistanceFormat.formatDistance(metrics.distance, metrics.kmOrMileInMeters);
		var timeText =  TimeFormat.formatTime(metrics.elapsedTime);
		
		// Format goal values
		var goal = goals.nextGoal();
		var goalLabelText;
		var goalTimeText;
		var goalDistText;
		var goalCompleted = false;
		if (goal != null) {
			goalLabelText = goal.name;
			goalTimeText = TimeFormat.formatTime(goal.predictedTime);
			goalDistText = DistanceFormat.formatDistance(goal.remainingDistance, metrics.kmOrMileInMeters);
		} else {
			goal = goals.lastCompletedGoal();
			if (goal != null) {
				goalLabelText = goal.name;
				goalTimeText = TimeFormat.formatTime(goal.actualTime);
				goalDistText = null;
				goalCompleted = true;
			} else {
				goalLabelText = "NO GOAL SET";
				goalTimeText = null;
				goalDistText = null;
			}
		}
		
		// Calculate positions
		var center = dc.getWidth() / 2;
		var leftQuadrant = center / 2;
		var rightQuadrant = center + leftQuadrant;
		var topGridLineY =
			device.round240 ? 56 :
			device.round218 ? 50 :
			0;
		var topRowY = topGridLineY / 2;
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
		
		// Render background
		dc.setColor(backgroundColour, backgroundColour);
		dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
		
		// Render pace
		//paceText = "88:88"; // Uncomment to test realistic max width
		var paceTextWidth = dc.getTextWidthInPixels(paceText, VALUE_FONT_LARGE);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(center, topRowY, VALUE_FONT_LARGE, paceText, Globals.VCENTER);
		
		// Render runner icon
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
		//distText = "88.88"; // Uncomment to test realistic max width
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(leftQuadrant, secondRowLabelsY, LABEL_FONT, distLabelText, Globals.VCENTER);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(leftQuadrant, secondRowValuesY, VALUE_FONT_LARGE, distText, Globals.VCENTER);
				
		// Render elapsed time
		//timeText = "88:88:88"; // Uncomment to test realistic max width
		var timeTextWidth = dc.getTextWidthInPixels(timeText, VALUE_FONT_LARGE);
		var timeFont = timeTextWidth < 100 ? VALUE_FONT_LARGE : VALUE_FONT;
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(rightQuadrant, secondRowLabelsY, LABEL_FONT, timeLabelText, Globals.VCENTER);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(rightQuadrant, secondRowValuesY, timeFont, timeText, Globals.VCENTER);
		
		// Render middle grid line
		drawHorizontalGridLine(dc, middleGridLineY);
		
		// Render goal
		var goalLabelTextWidth = dc.getTextWidthInPixels(goalLabelText, LABEL_FONT);
		var goalTimeTextWidth = goalTimeText == null ? 0 : dc.getTextWidthInPixels(goalTimeText, VALUE_FONT);
		var goalDistTextWidth = goalDistText == null ? 0 : dc.getTextWidthInPixels(goalDistText, VALUE_FONT);
		var goalLabelSpace = goalTimeTextWidth > 0 ? GOAL_LABEL_SPACE : 0;
		var goalValueSpace = goalDistTextWidth > 0 ? GOAL_VALUE_SPACE : 0;
		
		var totalGoalWidth = goalLabelTextWidth + goalLabelSpace + goalTimeTextWidth + goalValueSpace + goalDistTextWidth;
		var goalX = (dc.getWidth() - totalGoalWidth) / 2;
		
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(goalX, thirdRowY, LABEL_FONT, goalLabelText, Globals.LEFT_VCENTER);
		goalX += goalLabelTextWidth + goalLabelSpace;
		
		if (goalTimeText != null) {
			dc.setColor(goalCompleted ? SUCCESS_COLOUR : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(goalX, thirdRowY, VALUE_FONT, goalTimeText, Globals.LEFT_VCENTER);
			goalX += goalTimeTextWidth + goalValueSpace;
		}
		
		if (goalDistText != null) {
			dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(goalX, thirdRowY, VALUE_FONT, goalDistText, Globals.LEFT_VCENTER);
		}
		
		// Render bottom grid line
		drawHorizontalGridLine(dc, bottomGridLineY);
		
		// Render bottom vertical grid line
		drawVerticalGridLine(dc, center, bottomGridLineY, device.height);
		
		// Render cadence
		var cadenceText = metrics.computedCadence.format("%d");
		var cadenceTextWidth = dc.getTextWidthInPixels(cadenceText, VALUE_FONT);
		var cadenceIconX = center - cadenceTextWidth - (bottomRowXSpace * 2) - cadenceIcon.getWidth() + 8;
		var cadenceIconY = bottomRowY - (cadenceIcon.getHeight() / 2);
		dc.drawBitmap(cadenceIconX, cadenceIconY, cadenceIcon);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(center - bottomRowXSpace, bottomRowY, VALUE_FONT, cadenceText, Globals.RIGHT_VCENTER);
		
		// Render heart rate
		var heartRateText = metrics.computedHeartRate.format("%d");
		var heartRateTextWidth = dc.getTextWidthInPixels(heartRateText, VALUE_FONT);
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
