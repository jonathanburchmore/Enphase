using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;

(:background)
class EnphaseApp extends Application.AppBase {
    var view;
    var production;
    var consumption;
    var total_production;
    var total_consumption;
    
    function initialize() {
        AppBase.initialize();
        
        view = new EnphaseView();
    }

    // onStart() is called on application start up
    function onStart(state) {
        production = getProperty("production");
        total_production = getProperty("total_production");
        
        consumption = getProperty("consumption");
        total_consumption = getProperty("total_consumption");
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        if (production) {
            setProperty("production", production);
        }
        if (total_production) {
            setProperty("total_production", total_production);
        }
        
        if (consumption) {
            setProperty("consumption", consumption);
        }
        if (total_consumption) {
            setProperty("total_consumption", total_consumption);
        }
    }

    // Return the initial view of your application here
    function getInitialView() {
        Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        return [ view ];
    }
    
    function receiveProduction(production, total_production) {
        self.production = production;
        self.total_production = total_production;
        
        WatchUi.requestUpdate();
    }
    
    function receiveConsumption(consumption, total_consumption) {
        self.consumption = consumption;
        self.total_consumption = total_consumption;
        
        WatchUi.requestUpdate();
    }
    
    function getServiceDelegate() {
        return [new BackgroundServiceDelegate()];
}