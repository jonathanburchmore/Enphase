using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Background;
using Toybox.System;

(:background)
class EnphaseApp extends Application.AppBase {
    var apikey;
    var userid;
    var systemid;
    
    var production;
    var max_production;
    var total_production;
    
    var consumption;
    var max_consumption;
    var total_consumption;
    
    var last_update_hour;
    var last_update_min;
    
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        apikey = getProperty("apikey");
        userid = getProperty("UserID");
        systemid = getProperty("SystemID");

        if (userid.equals("")) {
            userid = getProperty("DefaultUserID");
        }

        if (systemid.equals("")) {
            systemid = getProperty("DefaultSystemID");
        }

        production = getProperty("production");
        max_production = getProperty("max_production");
        total_production = getProperty("total_production");
        consumption = getProperty("consumption");
        max_consumption = getProperty("max_consumption");
        total_consumption = getProperty("total_consumption");
        last_update_hour = getProperty("last_update_hour");
        last_update_min = getProperty("last_update_min");
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        apikey = WatchUi.loadResource(Rez.Strings.APIKey);

        setProperty("apikey", apikey);
        setProperty("DefaultUserID", WatchUi.loadResource(Rez.Strings.DefaultUserID));
        setProperty("DefaultSystemID", WatchUi.loadResource(Rez.Strings.DefaultSystemID));
        
        Background.registerForTemporalEvent(Time.now());

        return [new EnphaseMainView(), new EnphaseMainDelegate()];
    }
    
    function getServiceDelegate() {
        return [new EnphaseBackgroundServiceDelegate(apikey, userid, systemid)];
    }
    
    function onBackgroundData(data) {
        if (data.get("success") == true) {
	        production = data.get("production");
	        max_production = data.get("max_production");
	        total_production = data.get("total_production");
	        
	        consumption = data.get("consumption");
	        max_consumption = data.get("max_consumption");
	        total_consumption = data.get("total_consumption");
	        
	        last_update_hour = data.get("last_update_hour");
	        last_update_min = data.get("last_update_min");

            setProperty("production", production);
            setProperty("max_production", max_production);
            setProperty("total_production", total_production);
            setProperty("consumption", consumption);
            setProperty("max_consumption", max_consumption);
            setProperty("total_consumption", total_consumption);
            setProperty("last_update_hour", last_update_hour);
            setProperty("last_update_min", last_update_min);
	        
	        WatchUi.requestUpdate();
	    }
    }
}