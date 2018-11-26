using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Time;

class EnphaseMainDelegate extends WatchUi.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }
    
    function onKey(keyEvent) {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            var view = new EnphaseGraphView();
            WatchUi.pushView(view, new EnphaseGraphDelegate(view), WatchUi.SLIDE_LEFT);
            return true;
        }
        
        return false;
    }
}

class EnphaseMainView extends WatchUi.View {
    var app;
    
    var label_total_production;
    var label_total_consumption;
    var label_net;
    var label_lastupdate;
    
    function initialize() {
        View.initialize();
        app = Application.getApp();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));

        label_total_production = View.findDrawableById("TotalProduction");
        label_total_consumption = View.findDrawableById("TotalConsumption");
        label_net = View.findDrawableById("Net");
        label_lastupdate = View.findDrawableById("LastUpdate");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        if (app.total_production != null) {
            label_total_production.setText((app.total_production / 1000.0).format("%.1f"));
        }
        else {
            label_total_production.setText("--");
        }

        if (app.total_consumption != null) {
            label_total_consumption.setText((app.total_consumption / 1000.0).format("%.1f"));
        }
        else {
            label_total_consumption.setText("--");
        }

        if (app.total_production != null && app.total_consumption != null && app.total_production >= app.total_consumption) {
            label_net.setText(Lang.format("+$1$", [((app.total_production - app.total_consumption) / 1000.0).format("%.1f")]));
        }
        else if (app.total_production != null && app.total_consumption != null && app.total_production < app.total_consumption) {
            label_net.setText(Lang.format("-$1$", [((app.total_consumption - app.total_production) / 1000.0).format("%.1f")]));
        }
        else {
            label_net.setText(" --");
        }
        
        if (app.updating) {
            label_lastupdate.setText("Updating");
        }
        else if (app.last_update != null) {
            var updated = Time.Gregorian.info(new Time.Moment(app.last_update), Time.FORMAT_SHORT);
            label_lastupdate.setText(updated.hour.format("%02d") + ":" + updated.min.format("%02d"));
        }
        else {
            label_lastupdate.setText("");
        }

        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
}
