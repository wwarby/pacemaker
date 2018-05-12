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
	
	hidden var heartIcon;
	hidden var tickIcon;
	
	hidden var darkMode = false;
	hidden var backgroundColour = Gfx.COLOR_WHITE;
	hidden var labelColour;
	hidden var valueColour;
	hidden var batteryBackgroundColour;
	
	hidden var paceLabelText;
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
		heartIcon = Ui.loadResource(Rez.Drawables.HeartIcon);
		tickIcon = Ui.loadResource(Rez.Drawables.TickIcon);
	}
	
	function setDeviceSettingsDependentVariables(deviceSettings) {
		
		metrics.setDeviceSettingsDependentVariables(deviceSettings);
		
		if (metrics.distanceUnits == System.UNIT_METRIC) {
			paceLabelText = "/km";
		} else {
			paceLabelText = "/mi";
		}
		
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
	
	function onUpdate(dc) {
		
		if (doUpdates == false) { return; }
		
		setColours();
		
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
			goalLabelText = goal.label;
			goalTimeText = TimeFormat.formatTime(goal.predictedTime);
			goalDistText = DistanceFormat.formatDistance(goal.remainingDistance, metrics.kmOrMileInMeters);
		} else {
			goal = goals.lastCompletedGoal();
			if (goal != null) {
				goalLabelText = goal.label;
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
		var bottomRowY = device.height - ((device.height - bottomGridLineY) / 2);
		var thirdRowY = middleGridLineY + ((bottomGridLineY - middleGridLineY) / 2);
		
		// Render background
		dc.setColor(backgroundColour, backgroundColour);
		dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
		
		// Render pace
		//paceText = "88:88"; // Uncomment to test realistic max width
		var paceTextWidth = dc.getTextWidthInPixels(paceText, VALUE_FONT_LARGE);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(center, topRowY, VALUE_FONT_LARGE, paceText, Globals.VCENTER);
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(center + (paceTextWidth / 2) + 2, topRowY - 4, LABEL_FONT, paceLabelText, Globals.LEFT);
		
		// Grid line
		drawHorizontalGridLine(dc, topGridLineY);
		
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
		
		// Grid line
		drawHorizontalGridLine(dc, middleGridLineY);
		
		// Goal rendering
		var goalLabelTextWidth = dc.getTextWidthInPixels(goalLabelText, LABEL_FONT);
		var goalTimeTextWidth = goalTimeText == null ? 0 : dc.getTextWidthInPixels(goalTimeText, VALUE_FONT);
		var goalDistTextWidth = goalDistText == null ? 0 : dc.getTextWidthInPixels(goalDistText, VALUE_FONT);
		var goalCompletedTickWidth = !goalCompleted ? 0 : tickIcon.getWidth();
		var goalLabelSpace = goalTimeTextWidth > 0 ? GOAL_LABEL_SPACE : 0;
		var goalValueSpace = goalDistTextWidth > 0 ? GOAL_VALUE_SPACE : 0;
		var goalCompletedTickSpace = !goalCompleted ? 0 : GOAL_LABEL_SPACE;
		
		var totalGoalWidth = goalLabelTextWidth + goalLabelSpace + goalTimeTextWidth + goalValueSpace + goalDistTextWidth + goalCompletedTickSpace + goalCompletedTickWidth;
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
		
		if (goalCompleted) {
			goalX += goalDistTextWidth + goalLabelSpace;
			dc.drawBitmap(goalX, thirdRowY - (tickIcon.getHeight() / 2), tickIcon);
		}
		
		// Grid line
		drawHorizontalGridLine(dc, bottomGridLineY);
		
		// Heart rate
		var hrText = metrics.hr.format("%d");
		var hrTextWidth = dc.getTextWidthInPixels(hrText, VALUE_FONT_LARGE);
		var heartIconX = center - (hrTextWidth / 2) - 12 - (heartIcon.getWidth() / 2);
		var heartIconY = bottomRowY - (heartIcon.getHeight() / 2) + 2;
		dc.drawBitmap(heartIconX, heartIconY, heartIcon);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(center, bottomRowY, VALUE_FONT_LARGE, hrText, Globals.VCENTER);
		
		// Battery
		var batteryX = center + (hrTextWidth / 2) + 5;
		var batteryY = bottomRowY - 6;
		drawBattery(System.getSystemStats().battery, dc, batteryX, batteryY, 25, 12);
	}
	
	function drawHorizontalGridLine(dc, y) {
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(0, y, dc.getWidth(), y);
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
		
		dc.setColor(batteryBackgroundColour, Gfx.COLOR_TRANSPARENT);
		dc.fillRoundedRectangle(connectorX, connectorY, connectorWidth, connectorHeight, connectorCornerRadius);
		
		dc.setColor(batteryBackgroundColour, Gfx.COLOR_TRANSPARENT);
		dc.fillRoundedRectangle(x, y, batteryWidth, height, cornerRadius);
		
		if (battery < 10) {
			dc.setColor(BATTERY_COLOUR_VERY_LOW, Gfx.COLOR_TRANSPARENT);
		} else if (battery < 30) {
			dc.setColor(BATTERY_COLOUR_LOW, Gfx.COLOR_TRANSPARENT);
		} else {
			dc.setColor(BATTERY_COLOUR, Gfx.COLOR_TRANSPARENT);
		}
		
		dc.fillRoundedRectangle(x, y, Calc.max(batteryWidth * battery / 100, 3), height, cornerRadius);
			
	}

}
