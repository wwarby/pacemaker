using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using TimeFormat;
using DistanceFormat;
using Calc;

class PacemakerView extends Ui.DataField {
	
	hidden var doUpdates = 0;
	
	hidden var round240;
	hidden var round218;
	hidden var semiRound215;
	
	hidden var metrics;
	
	hidden var kmOrMileInMeters;
	
	hidden var heartRateData;
	hidden var cadenceData;
	hidden var powerData;
	hidden var paceData;
	
	function initialize() {
		DataField.initialize();
		readSettings();
	}
	
	function readSettings() {
		var deviceSettings = System.getDeviceSettings();
		round218 = deviceSettings.screenWidth == 218 && deviceSettings.screenShape == System.SCREEN_SHAPE_ROUND;
		round240 = deviceSettings.screenWidth == 240 && deviceSettings.screenShape == System.SCREEN_SHAPE_ROUND;
		semiRound215 = deviceSettings.screenWidth == 215 && deviceSettings.screenShape == System.SCREEN_SHAPE_SEMI_ROUND;
		kmOrMileInMeters = deviceSettings.distanceUnits == System.UNIT_METRIC ? 1000.0f : 1609.34f;
		deviceSettings = null;
	}
	
	function onLayout(dc) { }
	
	function compute(info) {
		
		// Read from settings which metrics we should be computing
		var metricTypes = [
			App.Properties.getValue(Ui.loadResource(Rez.Strings.topMetric1)),
			App.Properties.getValue(Ui.loadResource(Rez.Strings.topMetric2)),
			App.Properties.getValue(Ui.loadResource(Rez.Strings.middleMetric1)),
			App.Properties.getValue(Ui.loadResource(Rez.Strings.middleMetric2)),
			App.Properties.getValue(Ui.loadResource(Rez.Strings.bottomMetric1)),
			App.Properties.getValue(Ui.loadResource(Rez.Strings.bottomMetric2))
		];
		
		// Create metrics
		metrics = [
			new Metric(metricTypes[1] > 0),
			metricTypes[1] > 0 ? new Metric(true) : null,
			new Metric(false),
			metricTypes[3] > 0 ? new Metric(false) : null,
			new Metric(metricTypes[5] > 0),
			metricTypes[5] > 0 ? new Metric(true) : null
		];
		
		var currentHeartRateMode = null;
		var averageHeartRateMode = null;
//		
//		// Store historic heart rate data, if required by current settings
//		if (metricTypes.indexOf(1) > -1 || metricTypes.indexOf(2) > -1) {
			currentHeartRateMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.currentHeartRateMode));
			averageHeartRateMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.averageHeartRateMode));
//			if (currentHeartRateMode > 0 || averageHeartRateMode > 0) {
//				if (heartRateData == null) {
//					heartRateData = new DataQueue(Calc.max(currentHeartRateMode, averageHeartRateMode));
//				}
//				if (info.currentHeartRate != null) {
//					heartRateData.add(info.currentHeartRate);
//				} else {
//					heartRateData.reset();
//				}
//			} else {
//				heartRateData = null;
//			}
//		} else {
//			heartRateData = null;
//		}
//		
		var currentCadenceMode = null;
		var averageCadenceMode = null;
//		
//		// Store historic cadence data, if required by current settings
//		if (metricTypes.indexOf(4) > -1 || metricTypes.indexOf(5) > -1) {
			currentCadenceMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.currentCadenceMode));
			averageCadenceMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.averageCadenceMode));
//			if (currentCadenceMode > 0 || averageCadenceMode > 0) {
//				if (cadenceData == null) {
//					cadenceData = new DataQueue(Calc.max(currentCadenceMode, averageCadenceMode));
//				}
//				if (info.currentCadence != null) {
//					cadenceData.add(info.currentCadence);
//				} else {
//					cadenceData.reset();
//				}
//			} else {
//				cadenceData = null;
//			}
//		} else {
//			cadenceData = null;
//		}
//		
		var currentPowerMode = null;
		var averagePowerMode = null;
//		
//		if (metricTypes.indexOf(7) > -1 || metricTypes.indexOf(8) > -1) {
			currentPowerMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.currentPowerMode));
			averagePowerMode = App.Properties.getValue(Ui.loadResource(Rez.Strings.averagePowerMode));
//			if (currentPowerMode > 0 || averagePowerMode > 0) {
//				if (powerData == null) {
//					powerData = new DataQueue(Calc.max(currentPowerMode, averagePowerMode));
//				}
//				if (info.currentPower != null) {
//					powerData.add(info.currentPower);
//				} else {
//					powerData.reset();
//				}
//			} else {
//				powerData = null;
//			}
//		} else {
//			powerData = null;
//		}
//		
//		var currentPaceMode = null;
//		var averagePaceMode = null;
		
		// Calculate metric values
		for (var i = 0; i < metrics.size(); i++) {
			
			// CurrentHeartRate
			if (metricTypes[i] == 1) {
				
				metrics[i].labelText = Ui.loadResource(Rez.Strings.hr);
				metrics[i].setValue(currentHeartRateMode == -1 ? info.currentHeartRate : heartRateData.average(currentHeartRateMode), 1);
			
			// AverageHeartRate
			} else if (metricTypes[i] == 2) {
				
				metrics[i].category = 1;
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.hr) : Ui.loadResource(Rez.Strings.avgHr);
				metrics[i].setValue(averageHeartRateMode == 0 ? info.averageHeartRate : heartRateData.average(averageHeartRateMode), 1);
			
			// MaxHeartRate
			} else if (metricTypes[i] == 3) {
			
				metrics[i].category = 2;
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.hr) : Ui.loadResource(Rez.Strings.maxHr);
				metrics[i].setValue(info.maxHeartRate, 1);
			
			// CurrentCadence
			} else if (metricTypes[i] == 4) {
			
				metrics[i].labelText = Ui.loadResource(Rez.Strings.cad);
				//metrics[i].setValue(currentCadenceMode == -1 ? info.currentCadence : cadenceData.average(currentCadenceMode), 1);
				metrics[i].setValue(info.currentCadence, 1);
			
			// AverageCadence
			} else if (metricTypes[i] == 5) {
				
				metrics[i].category = 1;
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.cad) : Ui.loadResource(Rez.Strings.avgCad);
				metrics[i].setValue(averageCadenceMode == 0 ? info.averageCadence : cadenceData.average(averageCadenceMode), 1);
			
			// MaxCadence
			} else if (metricTypes[i] == 6) {
				
				metrics[i].category = 2;
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.cad) : Ui.loadResource(Rez.Strings.maxCad);
				metrics[i].setValue(info.maxCadence, 1);
			
			// CurrentPower
			} else if (metricTypes[i] == 7) {
				
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.powerShort) : Ui.loadResource(Rez.Strings.power);
				metrics[i].setValue(currentPowerMode == -1 ? info.currentPower : powerData.average(currentPowerMode), 1);
			
			// AveragePower
			} else if (metricTypes[i] == 8) {
				
				metrics[i].category = 1;
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.powerShort) : Ui.loadResource(Rez.Strings.avgPower);
				metrics[i].setValue(averagePowerMode == 0 ? info.averagePower : powerData.average(averagePowerMode), 1);
			
			// MaxPower
			} else if (metricTypes[i] == 9) {
				
				metrics[i].category = 2;
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.powerShort) : Ui.loadResource(Rez.Strings.maxPower);
				metrics[i].setValue(info.maxPower, 1);
			
			// CurrentPace
			} else if (metricTypes[i] == 10) {
				
				metrics[i].labelText = Ui.loadResource(Rez.Strings.pace);
				//metrics[i].valueText = TimeFormat.formatTime((activityMetrics.computedPace == null ? 0 : activityMetrics.computedPace) * 1000);
				//metrics[i].useGoalColour = true;
				//metrics[i].valueText = 
			
			// AveragePace
			} else if (metricTypes[i] == 11) {
				
				metrics[i].category = 1;
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.pace) : Ui.loadResource(Rez.Strings.avgPace);
				//metrics[i].valueText = 
				// TODO: Colouration should be based on target average pace for whole run
			
			// MaxPace
			} else if (metricTypes[i] == 12) {
				
				metrics[i].category = 2;
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.pace) : Ui.loadResource(Rez.Strings.maxPace);
				//metrics[i].valueText = 
			
			// Calories
			} else if (metricTypes[i] == 13) {
				
				metrics[i].labelText = Ui.loadResource(Rez.Strings.cal);
				//metrics[i].metrics[i].valueText = 
			
			// CaloriesPerMinute
			} else if (metricTypes[i] == 14) {
				
				metrics[i].category = 1;
				metrics[i].metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.cal) : Ui.loadResource(Rez.Strings.calMin);
				//metrics[i].metrics[i].valueText = 
			
			// PaceDelta
			} else if (metricTypes[i] == 15) {
				
				metrics[i].labelText = Ui.loadResource(Rez.Strings.pace);
				//metrics[i].valueText = 
			
			// ElapsedDistance
			} else if (metricTypes[i] == 16) {
				
				metrics[i].labelText = Ui.loadResource(Rez.Strings.dist);
				//metrics[i].valueText = DistanceFormat.formatDistance(activityMetrics.elapsedDistance, activityMetrics.kmOrMileInMeters);
			
			// RemainingDistance
			} else if (metricTypes[i] == 17) {
				
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.remainShort) : Ui.loadResource(Rez.Strings.remain);
				//metrics[i].valueText = goalMetrics.goalDistance == null || goalMetrics.goalDistance == 0 ? Ui.loadResource(Rez.Strings.noGoal) : DistanceFormat.formatDistance(goalMetrics.remainingDistance, activityMetrics.kmOrMileInMeters);
				//metrics[i].isError = goalMetrics.goalDistance == null || goalMetrics.goalDistance == 0;
			
			// PredictedTime
			} else if (metricTypes[i] == 18) {
				
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.finishShort) : Ui.loadResource(Rez.Strings.finish);
				//metrics[i].valueText =  goalMetrics.goalSet() ? TimeFormat.formatTime(goalMetrics.predictedTime) : Ui.loadResource(Rez.Strings.noGoal);
				//metrics[i].isError = !goalMetrics.goalSet();
				//metrics[i].useGoalColour = !isError;
			
			// PredictedTimeDelta
			} else if (metricTypes[i] == 19) {
				
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.finishShort) : Ui.loadResource(Rez.Strings.finish);
				//metrics[i].valueText = 
				//metrics[i].isError = !goalMetrics.goalSet();
				//metrics[i].useGoalColour = !isError;
			
			// RemainingTime
			} else if (metricTypes[i] == 20) {
				
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.remainShort) : Ui.loadResource(Rez.Strings.remain);
				//metrics[i].valueText = 
				//metrics[i].isError = goalMetrics.goalDistance == null || goalMetrics.goalDistance == 0;
			
			// TimerTime
			} else if (metricTypes[i] == 21) {
				
				metrics[i].labelText = Ui.loadResource(Rez.Strings.timer);
				//metrics[i].valueText = TimeFormat.formatTime(activityMetrics.timerTime);
			
			// Ascent
			} else if (metricTypes[i] == 22) {
				
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.ascentShort) : Ui.loadResource(Rez.Strings.ascent);
				//metrics[i].valueText = 
			
			// Descent
			} else if (metricTypes[i] == 23) {
				
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.descentShort) : Ui.loadResource(Rez.Strings.descent);
				//metrics[i].valueText = 
			
			// AscentDelta
			} else if (metricTypes[i] == 24) {
				
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.ascentShort) : Ui.loadResource(Rez.Strings.ascent);
				//metrics[i].valueText = 
			
			// TrainingEffect
			} else if (metricTypes[i] == 25) {
				
				metrics[i].labelText = metrics[i].short ? Ui.loadResource(Rez.Strings.effectShort) : Ui.loadResource(Rez.Strings.effect);
				//metrics[i].valueText = 
			
			}
			
		}
		
		
		//activityMetrics.compute(info);
		//goalMetrics.compute(info, activityMetrics.currentSpeed, activityMetrics.kmOrMileInMeters);
		
		
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
		
//		if (App.Properties.getValue(Ui.loadResource(Rez.Strings.colourText)) && activityMetrics.timerTime != null && activityMetrics.timerTime > 0) {
//			goalColour = goalMetrics.onTarget() ?
//				darkMode ? Gfx.COLOR_GREEN : Gfx.COLOR_DK_GREEN :
//				Gfx.COLOR_RED;
//		} else {
			goalColour = valueColour;
//		}
		
		// Calculate positions
		var half = dc.getWidth() / 2;
		var quarter = half / 2;
		var horizontalPadding =
			round240 ? 8 :
			round218 ? 6 :
			semiRound215 ? 6 :
			6;
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
		metrics[0].valueText = "88:88";
		metrics[1].valueText = "88:88";
		metrics[2].valueText = "88:88:88";
		metrics[3].valueText = "88:88:88";
		metrics[4].valueText = "88:88";
		metrics[5].valueText = "88:88";
		*/
		
		// Render background
		dc.setColor(backgroundColour, backgroundColour);
		dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
		
		// Render grid lines
		drawHorizontalGridLine(dc, topGridLineY);
		drawHorizontalGridLine(dc, bottomGridLineY);
		drawVerticalGridLine(dc, half, 0, bottomGridLineY);
		
		// Render top metric 1
		dc.setColor(metrics[0].useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(topLeftValueX, topRowY, metrics[0].valueText.length() > 3 ? Gfx.FONT_NUMBER_MILD : Gfx.FONT_NUMBER_MEDIUM, metrics[0].valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		
		if (metrics[1] != null) {
			// Render top metric 2
			dc.setColor(metrics[1].useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(dc.getWidth() - topLeftValueX, topRowY, metrics[1].valueText.length() > 3 ? Gfx.FONT_NUMBER_MILD : Gfx.FONT_NUMBER_MEDIUM, metrics[1].valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		}
		
		// Render middle metric 1
		dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(quarter, middleRowLabelY, Gfx.FONT_XTINY, metrics[2].labelText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		dc.setColor(metrics[2].useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(quarter, middleRowValueY, metrics[2].getWidth(dc) + 10 > half ? Gfx.FONT_NUMBER_MILD : Gfx.FONT_NUMBER_MEDIUM, metrics[2].valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		
		if (metrics[3] != null) {
			// Render middle metric 2
			dc.setColor(labelColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half + quarter, middleRowLabelY, Gfx.FONT_XTINY, metrics[3].labelText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
			dc.setColor(metrics[3].useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
			dc.drawText(half + quarter, middleRowValueY, metrics[3].getWidth(dc) + 10 > half ? Gfx.FONT_NUMBER_MILD : Gfx.FONT_NUMBER_MEDIUM, metrics[3].valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		}
		
		// Render bottom metric 1
		dc.setColor(metrics[4].useGoalColour ? goalColour : valueColour, Gfx.COLOR_TRANSPARENT);
		dc.drawText(half, bottomRowY, Gfx.FONT_NUMBER_MEDIUM, metrics[4].valueText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		
		if (metrics[5] != null) {
			// Render bottom metric 2
			
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
