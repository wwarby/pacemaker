using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class Metric {
	
	var labelText;
	var valueText = ""; // TODO REMOVE
	var short;
	var useGoalColour = false;
	var category = null;
	
	function initialize(isShort) {
		short = isShort;
	}
	
	function setValue(value, mode) {
		// Integer
		if (mode == 1) {
			valueText = value == null ? Ui.loadResource(Rez.Strings.zero) : value.format("%d");
		// Time
		} else if (mode == 2) {
			
		// Distance
		} else if (mode == 3) {
			
		}
	}
	
	function getDotColour(darkMode) {
		// Average
		if (category == 1) {
			if (short) { dotColour = darkMode ? Gfx.COLOR_BLUE : Gfx.COLOR_DK_BLUE; }
		// Max
		} else if (category == 2) {
			if (short) { dotColour = darkMode ? Gfx.COLOR_ORANGE : Gfx.COLOR_YELLOW; }
		} else {
			return null;
		}
	}
	
	function getWidth(dc) {
		return valueText == null ? 0 : dc.getTextWidthInPixels(valueText, Gfx.FONT_NUMBER_MEDIUM);
	}
	
}
