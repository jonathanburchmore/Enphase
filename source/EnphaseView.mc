using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Time;

class EnphaseView extends WatchUi.View {
    var total_production;
    var total_consumption;
    
    var label_total_production;
    var label_total_consumption;
    var label_net;
    
    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));

        label_total_production = View.findDrawableById("TotalProduction");
        label_total_consumption = View.findDrawableById("TotalConsumption");
        label_net = View.findDrawableById("Net");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        if (total_production != null) {
            label_total_production.setText(Lang.format("$1$ produced", [total_production.format("%.1f")]));
        }
        else {
            label_total_production.setText("");
        }

        if (total_consumption != null) {
            label_total_consumption.setText(Lang.format("$1$ consumed", [total_consumption.format("%.1f")]));
        }
        else {
            label_total_consumption.setText("");
        }

        if (total_production != null && total_consumption != null && total_production >= total_consumption) {
            label_net.setColor(Graphics.COLOR_BLUE);
            label_net.setText(Lang.format("$1$ exported", [(total_production - total_consumption).format("%.1f")]));
        }
        else if (total_production != null && total_consumption != null && total_production < total_consumption) {
            label_net.setColor(Graphics.COLOR_RED);
            label_net.setText(Lang.format("$1$ imported", [(total_consumption - total_production).format("%.1f")]));
        }
        else {
            label_net.setText("");
        }

        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    function receiveTotalProduction(total_production) {
        self.total_production = total_production / 1000.0;
        requestUpdate();
    }
    
    function receiveTotalConsumption(total_consumption) {
        self.total_consumption = total_consumption / 1000.0;
        requestUpdate();
    }
}
