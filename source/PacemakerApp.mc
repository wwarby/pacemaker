using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class PacemakerApp extends App.AppBase {
	
	var mainView;
	
	function initialize() {
		AppBase.initialize();
	}

	function onStart(state) {}

	function onStop(state) {}
	
	function onSettingsChanged() {
		mainView.readSettings();
		Ui.requestUpdate();
	}
	
	function getInitialView() {
		mainView = new PacemakerView();
		return [mainView];
	}

}