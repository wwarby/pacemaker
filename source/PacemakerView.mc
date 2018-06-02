using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
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
		
		if (App.Properties.getValue("c") && activityMetrics.timerTime != null && activityMetrics.timerTime > 0) {
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
		var twoTopMetrics = App.Properties.getValue("m2") != null && App.Properties.getValue("m2") != -1;
		var twoMiddleMetrics = App.Properties.getValue("m2") != null && App.Properties.getValue("m4") != -1;
		var twoBottomMetrics = App.Properties.getValue("m6") != null && App.Properties.getValue("m6") != -1;
		var topMetric1 = new MetricDisplayDetail(App.Properties.getValue("m1"), false, true, true, amw, gmw, dcw);
		var topMetric2 = new MetricDisplayDetail(App.Properties.getValue("m2"), false, true, true, amw, gmw, dcw);
		var middleMetric1 = new MetricDisplayDetail(App.Properties.getValue("m3"), true, false, false, amw, gmw, dcw);
		var middleMetric2 = new MetricDisplayDetail(App.Properties.getValue("m4"), true, false, false, amw, gmw, dcw);
		var bottomMetric1 = new MetricDisplayDetail(App.Properties.getValue("m5"), false, true, twoBottomMetrics, amw, gmw, dcw);
		var bottomMetric2 = !twoBottomMetrics ? null : new MetricDisplayDetail(App.Properties.getValue("m6"), false, true, true, amw, gmw, dcw);
		
		// Calculate positions
		var half = dc.getWidth() / 2;
		var quarter = half / 2;
		var iconSize = 20;
		var topGridLineY =
			round240 ? 80 :
			round218 ? 73 :
			semiRound215 ? 60 :
			0;
		var topRowY =
			round240 ? 56 :
			round218 ? 50 :
			semiRound215 ? 37 :
			0;
		var topOrBottomValueOffsetX =
			round240 ? 10 :
			round218 ? 8 :
			semiRound215 ? 8 :
			0;
		var topOrBottomIconOffsetX =
			round240 ? 10 :
			round218 ? 8 :
			semiRound215 ? 68 :
			0;
		var iconX =
			round240 ? 18 :
			round218 ? 15 :
			semiRound215 ? 12 :
			0;
		var iconY =
			round240 ? 10 :
			round218 ? 8 :
			semiRound215 ? 33 :
			0;
		var iconYSingle =
			round240 ? 58 :
			round218 ? 54 :
			semiRound215 ? 44 :
			0;
		var topIconOffsetY = 0;
		var bottomIconOffsetY = 5;
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
		topMetric1.valueText = "888";
		topMetric2.valueText = "888";
		middleMetric1.valueText = "88:88:88";
		middleMetric2.valueText = "88:88:88";
		bottomMetric1.valueText = "+88:88";
		if (bottomMetric2 != null) { bottomMetric2.valueText = "88.88"; }
		topMetric1.width = dc.getTextWidthInPixels(topMetric1.valueText, Gfx.FONT_NUMBER_MEDIUM);
		topMetric2.width = dc.getTextWidthInPixels(topMetric2.valueText, Gfx.FONT_NUMBER_MEDIUM);
		middleMetric1.width = dc.getTextWidthInPixels(middleMetric1.valueText, Gfx.FONT_NUMBER_MEDIUM);
		middleMetric2.width = dc.getTextWidthInPixels(middleMetric2.valueText, Gfx.FONT_NUMBER_MEDIUM);
		bottomMetric1.width = dc.getTextWidthInPixels(bottomMetric1.valueText, Gfx.FONT_NUMBER_MEDIUM);
		if (bottomMetric2 != null) { bottomMetric2.width = dc.getTextWidthInPixels(bottomMetric2.valueText, Gfx.FONT_NUMBER_MEDIUM); }
		*/
		
		// Render background
		dc.setColor(backgroundColour, backgroundColour);
		dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
		
		// Render horizontal grid lines
		drawHorizontalGridLine(dc, topGridLineY);
		drawHorizontalGridLine(dc, bottomGridLineY);
		
		// Render vertical grid lines
		if (twoTopMetrics) {
			drawVerticalGridLine(dc, half, 0, topGridLineY);
		}
		if (twoMiddleMetrics) {
			drawVerticalGridLine(dc, half, topGridLineY, bottomGridLineY);
		}
		if (twoBottomMetrics) {
			drawVerticalGridLine(dc, half, bottomGridLineY, dc.getHeight());
		}
		
		if (!twoTopMetrics) {
			// Render top metric 1 in full width mode
			var topIconOffsetX = Calc.max(0, (130 - topMetric1.width) / 3);
			dc.drawBitmap(iconX + (iconSize / 2) + topIconOffsetX, iconYSingle + topIconOffsetY - (iconSize / 2), topMetric1.iconReverse());
			dc.drawBitmap(dc.getWidth() - iconX - topIconOffsetX - iconSize - (iconSize / 2), iconYSingle + topIconOffsetY - (iconSize / 2), topMetric1.icon());
			dc.setColor(topMetric1.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half, topRowY, topMetric1.isError ? Gfx.FONT_MEDIUM : Gfx.FONT_NUMBER_MEDIUM, topMetric1.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		} else {
			// Render top metric 1 in half width mode
			dc.drawBitmap(half - topOrBottomIconOffsetX - iconSize, iconY, topMetric1.icon());
			dc.setColor(topMetric1.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half - topOrBottomValueOffsetX, topRowY, topMetric1.valueText.length() > 3 ? Gfx.FONT_NUMBER_MILD : Gfx.FONT_NUMBER_MEDIUM, topMetric1.valueText, Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER);
			
			// Render top metric 2 in half width mode
			dc.drawBitmap(half + topOrBottomIconOffsetX, iconY, topMetric2.icon());
			dc.setColor(topMetric2.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half + topOrBottomValueOffsetX, topRowY, topMetric2.valueText.length() > 3 ? Gfx.FONT_NUMBER_MILD : Gfx.FONT_NUMBER_MEDIUM, topMetric2.valueText, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
		}
		
		if (!twoMiddleMetrics) {
			// Render middle metric 1 in full width mode
			dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half, middleRowLabelY, Gfx.FONT_XTINY, middleMetric1.labelText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
			dc.setColor(middleMetric1.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half, middleRowValueY, middleMetric1.isError ? Gfx.FONT_MEDIUM : Gfx.FONT_NUMBER_MEDIUM , middleMetric1.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		} else {
			// Render middle metric 1 in half width mode
			dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(quarter, middleRowLabelY, Gfx.FONT_XTINY, middleMetric1.labelText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
			dc.setColor(middleMetric1.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(quarter, middleRowValueY, middleMetric1.width + 10 > half ? (middleMetric1.isError ? Gfx.FONT_SMALL : Gfx.FONT_NUMBER_MILD) : (middleMetric1.isError ? Gfx.FONT_MEDIUM : Gfx.FONT_NUMBER_MEDIUM), middleMetric1.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
			
			// Render middle metric 2 in half width mode
			dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half + quarter, middleRowLabelY, Gfx.FONT_XTINY, middleMetric2.labelText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
			dc.setColor(middleMetric2.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half + quarter, middleRowValueY, middleMetric2.width + 10 > half ? (middleMetric2.isError ? Gfx.FONT_SMALL : Gfx.FONT_NUMBER_MILD) : (middleMetric2.isError ? Gfx.FONT_MEDIUM : Gfx.FONT_NUMBER_MEDIUM), middleMetric2.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		}
		
		if (!twoBottomMetrics) {
			// Render bottom metric 1 in full width mode
			var bottomIconOffsetX = Calc.max(0, (130 - bottomMetric1.width) / 3);
			dc.drawBitmap(iconX + (iconSize / 2) + bottomIconOffsetX, dc.getHeight() - iconYSingle + bottomIconOffsetY - (iconSize / 2), bottomMetric1.iconReverse());
			dc.drawBitmap(dc.getWidth() - iconX - bottomIconOffsetX - iconSize - (iconSize / 2), dc.getHeight() - iconYSingle + bottomIconOffsetY - (iconSize / 2), bottomMetric1.icon());
			dc.setColor(bottomMetric1.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half, bottomRowY, bottomMetric1.isError ? Gfx.FONT_MEDIUM : Gfx.FONT_NUMBER_MEDIUM, bottomMetric1.valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		} else {
			// Render bottom metric 1 in half width mode
			dc.drawBitmap(half - topOrBottomIconOffsetX - iconSize, dc.getHeight() - iconY - iconSize, bottomMetric1.icon());
			dc.setColor(bottomMetric1.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half - topOrBottomValueOffsetX, bottomRowY, bottomMetric1.valueText.length() > 3 ? Gfx.FONT_NUMBER_MILD : Gfx.FONT_NUMBER_MEDIUM, bottomMetric1.valueText, Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER);
			
			//Render bottom metric 2 in half width mode
			dc.drawBitmap(half + topOrBottomIconOffsetX, dc.getHeight() - iconY - iconSize, bottomMetric2.icon());
			dc.setColor(bottomMetric2.useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half + topOrBottomValueOffsetX, bottomRowY, bottomMetric2.valueText.length() > 3 ? Gfx.FONT_NUMBER_MILD : Gfx.FONT_NUMBER_MEDIUM, bottomMetric2.valueText, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
		}
		
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
