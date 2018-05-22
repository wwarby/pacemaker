using Toybox.WatchUi as Ui;
using Toybox.Math;

module TimeFormat {
	
	function formatTime(milliseconds) {
		
		if (milliseconds != null && milliseconds > 0) {
			var hours = null;
			var minutes = Math.floor(milliseconds / 1000 / 60).toNumber();
			var seconds = Math.floor(milliseconds / 1000).toNumber() % 60;
			
			if (minutes >= 60) {
				hours = minutes / 60;
				minutes = minutes % 60;
			}
			
			if (hours == null) {
				return minutes.format("%d") + ":" + seconds.format("%02d");
			} else {
				return hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
			}
		} else {
			return Ui.loadResource(Rez.Strings.zeroTime);
		}
		
	}
	
}