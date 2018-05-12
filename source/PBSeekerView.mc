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
	
	hidden const BATTERY_BACKGROUND_COLOUR = Gfx.COLOR_DK_GRAY;
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
	
	hidden var metrics;
	hidden var goals;
	
	function initialize() {
		DataField.initialize();
		metrics = new ActivityMetrics();
		goals = new GoalMetrics(metrics);
	}

	function onLayout(dc) {
		setDeviceSettingsDependentVariables();
		heartIcon = Ui.loadResource(Rez.Drawables.HeartIcon);
		tickIcon = Ui.loadResource(Rez.Drawables.TickIcon);
	}
	
	function setDeviceSettingsDependentVariables() {
		
		metrics.setDeviceSettingsDependentVariables();
		
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
		
		// Render background
		dc.setColor(backgroundColour, backgroundColour);
		dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
		
		// Render pace
		var paceTextWidth = dc.getTextWidthInPixels(paceText, VALUE_FONT_LARGE);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(dc.getWidth() / 2, 33, VALUE_FONT_LARGE, paceText, Globals.CENTER);
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(dc.getWidth() / 2 + (paceTextWidth / 2) + 2, 41, LABEL_FONT, paceLabelText, Globals.LEFT);
		
		// Grid line
		drawHorizontalGridLine(dc, 58);
		
		// Render distance
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(70, 74, LABEL_FONT, distLabelText, Globals.CENTER);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(70, 104, VALUE_FONT_LARGE, distText, Globals.CENTER);
				
		// Render elapsed time
		var timeTextWidth = dc.getTextWidthInPixels(timeText, VALUE_FONT_LARGE);
		var timeFont = timeTextWidth < 100 ? VALUE_FONT_LARGE : VALUE_FONT;
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(170, 74, LABEL_FONT, timeLabelText, Globals.CENTER);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(170, 104, timeFont, timeText, Globals.CENTER);
		
		// Grid line
		drawHorizontalGridLine(dc, 134);
		
		// Goal rendering
		var goalLabelTextWidth = dc.getTextWidthInPixels(goalLabelText, LABEL_FONT);
		var goalTimeTextWidth = goalTimeText == null ? 0 : dc.getTextWidthInPixels(goalTimeText, VALUE_FONT);
		var goalDistTextWidth = goalDistText == null ? 0 : dc.getTextWidthInPixels(goalDistText, VALUE_FONT);
		var goalCompletedTickWidth = !goalCompleted ? 0 : tickIcon.getWidth();
		var goalLabelSpace = goalTimeTextWidth > 0 ? GOAL_LABEL_SPACE : 0;
		var goalValueSpace = goalDistTextWidth > 0 ? GOAL_VALUE_SPACE : 0;
		var goalCompletedTickSpace = !goalCompleted ? 0 : GOAL_LABEL_SPACE;
		
		var totalGoalWidth = goalLabelTextWidth + goalLabelSpace + goalTimeTextWidth + goalValueSpace + goalDistTextWidth + goalCompletedTickSpace + goalCompletedTickWidth;
		var goalX = (240 - totalGoalWidth) / 2;
		var goalY = 159;
		
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(goalX, goalY, LABEL_FONT, goalLabelText, Globals.LEFT);
		goalX += goalLabelTextWidth + goalLabelSpace;
		
		if (goalTimeText != null) {
			dc.setColor(goalCompleted ? SUCCESS_COLOUR : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(goalX, goalY, VALUE_FONT, goalTimeText, Globals.LEFT);
			goalX += goalTimeTextWidth + goalValueSpace;
		}
		
		if (goalDistText != null) {
			dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(goalX, goalY, VALUE_FONT, goalDistText, Globals.LEFT);
		}
		
		if (goalCompleted) {
			goalX += goalDistTextWidth + goalLabelSpace;
			dc.drawBitmap(goalX, goalY - (tickIcon.getHeight() / 2), tickIcon);
		}
		
		// Grid line
		drawHorizontalGridLine(dc, 184);
		
		// Heart rate
		dc.drawBitmap(62, 200, heartIcon);
		dc.setColor(valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(dc.getWidth() / 2, 210, VALUE_FONT_LARGE, metrics.hr.format("%d"), Globals.CENTER);
		
		// Battery
		drawBattery(System.getSystemStats().battery, dc, 159, 203, 25, 12);
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
