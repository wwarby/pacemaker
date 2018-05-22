using Toybox.WatchUi as Ui;

module IconLoader {

	var iconsDarkMode;
	
	var heartRateIcon;
	var cadenceIcon;
	var powerIcon;
	var paceIcon;
	var distanceIcon;
	var finishIcon;
	var timeIcon;
	
	function setDarkMode(darkMode) {
		if (iconsDarkMode != darkMode) {
			cadenceIcon = null;
			powerIcon = null;
			paceIcon = null;
			distanceIcon = null;
			finishIcon = null;
			timeIcon = null;
		}
		iconsDarkMode = darkMode;
	}
	
	function getIcon(metric) {
		
		if (metric == 0) {
			if (heartRateIcon == null) {
				heartRateIcon = Ui.loadResource(Rez.Drawables.heartRateIcon);
			}
			return heartRateIcon;
		}
		
		if (metric == 1) {
			if (cadenceIcon == null) {
				cadenceIcon = Ui.loadResource(iconsDarkMode ? Rez.Drawables.cadenceDarkModeIcon : Rez.Drawables.cadenceIcon);
			}
			return cadenceIcon;
		}
		
		if (metric == 2) {
			if (powerIcon == null) {
				powerIcon = Ui.loadResource(iconsDarkMode ? Rez.Drawables.powerDarkModeIcon : Rez.Drawables.powerIcon);
			}
			return powerIcon;
		}
		
		if (metric == 3) {
			if (paceIcon == null) {
				paceIcon = Ui.loadResource(iconsDarkMode ? Rez.Drawables.paceDarkModeIcon : Rez.Drawables.paceIcon);
			}
			return paceIcon;
		}
		
		if (metric == 4) {
			if (distanceIcon == null) {
				distanceIcon = Ui.loadResource(iconsDarkMode ? Rez.Drawables.distanceDarkModeIcon : Rez.Drawables.distanceIcon);
			}
			return distanceIcon;
		}
		
		if (metric == 5 || metric == 6) {
			if (finishIcon == null) {
				finishIcon = Ui.loadResource(iconsDarkMode ? Rez.Drawables.finishDarkModeIcon : Rez.Drawables.finishIcon);
			}
			return finishIcon;
		}
		
		if (metric == 7) {
			if (timeIcon == null) {
				timeIcon = Ui.loadResource(iconsDarkMode ? Rez.Drawables.timeDarkModeIcon : Rez.Drawables.timeIcon);
			}
			return timeIcon;
		}
		
		return null;
	}
	
}
