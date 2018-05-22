using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using TimeFormat;
using DistanceFormat;
using Calc;
using IconLoader;

class PacemakerView extends Ui.DataField {
	
	hidden var doUpdates = 0;
	
	hidden var round240;
	hidden var round218;
	hidden var semiRound215;
	
	hidden var activityMetrics;
	hidden var goalMetrics;
	
	function initialize() {
		DataField.initialize();
		activityMetrics = new ActivityMetrics();
		goalMetrics = new GoalMetrics();
		readSettings();
	}
	
	function readSettings() {
		var deviceSettings = System.getDeviceSettings();
		round218 = deviceSettings.screenWidth == 218 && deviceSettings.screenShape == System.SCREEN_SHAPE_ROUND;
		round240 = deviceSettings.screenWidth == 240 && deviceSettings.screenShape == System.SCREEN_SHAPE_ROUND;
		semiRound215 = deviceSettings.screenWidth == 215 && deviceSettings.screenShape == System.SCREEN_SHAPE_SEMI_ROUND;
		activityMetrics.readSettings(deviceSettings);
		goalMetrics.readSettings(deviceSettings);
		deviceSettings = null;
	}
	
	function onLayout(dc) { }
	
	function compute(info) {
		activityMetrics.compute(info);
		goalMetrics.compute(info, activityMetrics.currentSpeed, activityMetrics.kmOrMileInMeters);
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
		
		// Set colours
		var backgroundColour = self has :getBackgroundColor ? getBackgroundColor() : Gfx.COLOR_WHITE;
		var darkMode = (backgroundColour == Gfx.COLOR_BLACK);
		var labelColour = darkMode ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_DK_GRAY;
		var valueColour = darkMode ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK;
		var goalColour;
		
		if (App.Properties.getValue(Ui.loadResource(Rez.Strings.colourText)) && activityMetrics.timerTime > 0) {
			goalColour = goalMetrics.onTarget() ?
				darkMode ? Gfx.COLOR_GREEN : Gfx.COLOR_DK_GREEN :
				Gfx.COLOR_RED;
		} else {
			goalColour = valueColour;
		}
		
		IconLoader.setDarkMode(darkMode);
		
		var amw = activityMetrics.weak().get();
		var gmw = goalMetrics.weak().get();
		var dcw = dc.weak().get();
		
		// Format metric data
		var topLeftMetric = new MetricDisplayDetail(App.Properties.getValue(Ui.loadResource(Rez.Strings.topLeftMetric)), false, true, amw, gmw, dcw);
		var topRightMetric = new MetricDisplayDetail(App.Properties.getValue(Ui.loadResource(Rez.Strings.topRightMetric)), false, true, amw, gmw, dcw);
		var middleLeftMetric = new MetricDisplayDetail(App.Properties.getValue(Ui.loadResource(Rez.Strings.middleLeftMetric)), true, false, amw, gmw, dcw);
		var middleRightMetric = new MetricDisplayDetail(App.Properties.getValue(Ui.loadResource(Rez.Strings.middleRightMetric)), true, false, amw, gmw, dcw);
		var bottomMetric = new MetricDisplayDetail(App.Properties.getValue(Ui.loadResource(Rez.Strings.bottomMetric)), false, true, amw, gmw, dcw);
		
		// Calculate positions
		var half = dc.getWidth() / 2;
		var quarter = half / 2;
		var topGridLineY =
			round240 ? 80 :
			round218 ? 73 :
			semiRound215 ? 60 :
			0;
		var topRowY =
			round240 ? (topGridLineY / 2) + 10 :
			round218 ? (topGridLineY / 2) + 8 :
			semiRound215 ? (topGridLineY / 2) + 4 :
			0;
		var topLeftValueX =
			round240 ? 82 :
			round218 ? 76 :
			semiRound215 ? 73 :
			0;
		var iconX =
			round240 ? 18 :
			round218 ? 15 :
			semiRound215 ? 12 :
			0;
		var iconY =
			round240 ? 58 :
			round218 ? 54 :
			semiRound215 ? 40 :
			0;
		var middleRowLabelY =
			round240 ? topGridLineY + 17 :
			round218 ? topGridLineY + 15 :
			semiRound215 ? topGridLineY + 10 :
			0;
		var middleRowValueY =
			round240 ? middleRowLabelY + 32 :
			round218 ? middleRowLabelY + 28 :
			semiRound215 ? middleRowLabelY + 24 :
			0;
		var bottomGridLineY = dc.getHeight() - topGridLineY;
		var bottomRowY = dc.getHeight() - topRowY;
		
		// Uncomment to test realistic max widths
		/*
		topLeftMetric.valueText = "888";
		topRightMetric.valueText = "888";
		middleLeftMetric.valueText = "88:88:88";
		middleRightMetric.valueText = "88:88:88";
		bottomMetric.valueText = "88:88:88";
		topLeftMetric.width = dc.getTextWidthInPixels(topLeftMetric.valueText, Gfx.FONT_NUMBER_MEDIUM);
		topRightMetric.width = dc.getTextWidthInPixels(topRightMetric.valueText, Gfx.FONT_NUMBER_MEDIUM);
		middleLeftMetric.width = dc.getTextWidthInPixels(middleLeftMetric.valueText, Gfx.FONT_NUMBER_MEDIUM);
		middleRightMetric.width = dc.getTextWidthInPixels(middleRightMetric.valueText, Gfx.FONT_NUMBER_MEDIUM);
		bottomMetric.width = dc.getTextWidthInPixels(bottomMetric.valueText, Gfx.FONT_NUMBER_MEDIUM);
		*/
		
		// Render background
		dc.setColor(backgroundColour, backgroundColour);
		dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
		
		// Render grid lines
		drawHorizontalGridLine(dc, topGridLineY);
		drawHorizontalGridLine(dc, bottomGridLineY);
		drawVerticalGridLine(dc, half, 0, bottomGridLineY);
		
		// Render top left metric
		dc.drawBitmap(iconX + (topLeftMetric.icon.getWidth() / 2), iconY - (topLeftMetric.icon.getHeight() / 2), topLeftMetric.icon);
		dc.setColor(topLeftMetric.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(topLeftValueX, topRowY, Gfx.FONT_NUMBER_MEDIUM, topLeftMetric.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		
		// Render top right metric
		dc.drawBitmap(dc.getWidth() - iconX - topRightMetric.icon.getWidth() - (topRightMetric.icon.getWidth() / 2), iconY - (topRightMetric.icon.getHeight() / 2), topRightMetric.icon);
		dc.setColor(topRightMetric.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(dc.getWidth() - topLeftValueX, topRowY, Gfx.FONT_NUMBER_MEDIUM, topRightMetric.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		
		// Render middle left metric
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(quarter, middleRowLabelY, Gfx.FONT_XTINY, middleLeftMetric.labelText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		dc.setColor(middleLeftMetric.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(quarter, middleRowValueY, middleLeftMetric.width + 10 > half ? (middleLeftMetric.isError ? Gfx.FONT_SMALL : Gfx.FONT_NUMBER_MILD) : (middleLeftMetric.isError ? Gfx.FONT_MEDIUM : Gfx.FONT_NUMBER_MEDIUM), middleLeftMetric.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		
		// Render middle right metric
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(half + quarter, middleRowLabelY, Gfx.FONT_XTINY, middleRightMetric.labelText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		dc.setColor(middleRightMetric.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(half + quarter, middleRowValueY, middleRightMetric.width + 10 > half ? (middleRightMetric.isError ? Gfx.FONT_SMALL : Gfx.FONT_NUMBER_MILD) : (middleRightMetric.isError ? Gfx.FONT_MEDIUM : Gfx.FONT_NUMBER_MEDIUM), middleRightMetric.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		
		// Render bottom metric
		var bottomIconOffsetX = Calc.max(0, (130 - bottomMetric.width) / 3);
		var bottomIconOffsetY = 5;
		dc.drawBitmap(iconX + (bottomMetric.icon.getWidth() / 2) + bottomIconOffsetX, dc.getHeight() - iconY + bottomIconOffsetY - (bottomMetric.icon.getHeight() / 2), bottomMetric.icon);
		dc.drawBitmap(dc.getWidth() - iconX - bottomIconOffsetX - bottomMetric.icon.getWidth() - (bottomMetric.icon.getWidth() / 2), dc.getHeight() - iconY + bottomIconOffsetY - (bottomMetric.icon.getHeight() / 2), bottomMetric.icon);
		dc.setColor(bottomMetric.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(half, bottomRowY, bottomMetric.isError ? Gfx.FONT_MEDIUM : Gfx.FONT_NUMBER_MEDIUM, bottomMetric.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		
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
