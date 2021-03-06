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

    var updating;
    
    var production;
    var max_production;
    var total_production;
    
    var consumption;
    var max_consumption;
    var total_consumption;
    
    var last_update;
    
    function initialize() {
        AppBase.initialize();
        
        updating = false;
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
        last_update = getProperty("last_update");
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
        
        if (System.getDeviceSettings().connectionAvailable) {
            updating = true;
            Background.registerForTemporalEvent(Time.now());
        }

        return [new EnphaseMainView(), new EnphaseMainDelegate()];
    }
    
    function getServiceDelegate() {
        return [new EnphaseBackgroundServiceDelegate(apikey, userid, systemid)];
    }
    
    function onBackgroundData(data) {
        updating = false;
            
        if (data.get("success") == true) {
	        production = data.get("production");
	        max_production = data.get("max_production");
	        total_production = data.get("total_production");
	        
	        consumption = data.get("consumption");
	        max_consumption = data.get("max_consumption");
	        total_consumption = data.get("total_consumption");
	        
	        last_update = data.get("last_update");

            setProperty("production", production);
            setProperty("max_production", max_production);
            setProperty("total_production", total_production);
            setProperty("consumption", consumption);
            setProperty("max_consumption", max_consumption);
            setProperty("total_consumption", total_consumption);
            setProperty("last_update", last_update);
	        
	        WatchUi.requestUpdate();
	    }
    }
}