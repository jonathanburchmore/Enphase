using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.Lang;
using Toybox.Communications;

class EnphaseGraphDelegate extends WatchUi.InputDelegate {
    var view;
    
    function initialize(view) {
        InputDelegate.initialize();
        
        self.view = view;
    }
    
    function onKey(keyEvent) {
        if (keyEvent.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        else if (keyEvent.getKey() == WatchUi.KEY_UP) {
            view.scrollLeft();
            return true;
        }
        else if (keyEvent.getKey() == WatchUi.KEY_DOWN) {
            view.scrollRight();
            return true;
        }
        
        return false;
    }
}

class EnphaseGraphView extends WatchUi.View {
    var app;
    var locX;
    var min_locX;
    var locY;
    var height;
    var buffer;
    
    function initialize() {
        View.initialize();
        app = Application.getApp();
    }
    
    function onLayout(dc) {
        height = Math.floor(dc.getHeight() * 0.95);

        if (app.last_update == null || Time.today().value() - app.last_update > 86400) {
            locX = 0;
        }
        else {
            locX = dc.getWidth() - (6 * (Math.floor(96 * ((app.last_update - Time.today().value()) / 86400.0))));
        }

        if (locX > 0) {
            locX = 0;
        }
        min_locX = locX;
        locY = (dc.getHeight() - height) / 2;
        
        buffer = new Graphics.BufferedBitmap( {
            :width => 96 * 6,
            :height => height,
            :palette => [
                Graphics.COLOR_BLACK,
                Graphics.COLOR_DK_BLUE,
                Graphics.COLOR_BLUE,
                Graphics.COLOR_DK_RED,
                Graphics.COLOR_RED
            ]
        } );
        
        updateBuffer();
    }
    
    function scrollLeft() {
        locX = locX + 24;
        if (locX > 0) {
            locX = 0;
        }
        
        requestUpdate();
    }
    
    function scrollRight() {
        locX = locX - 24;
        if (locX < min_locX) {
            locX = min_locX;
        }
        
        requestUpdate();
    }
    
    function scaled_watts(enwh) {
        var max = app.max_production;
        
        if (1000 > max ) {
            max = 1000;
        }
        
        if (app.max_consumption > max) {
            max = app.max_consumption;
        }
        
        return Math.floor((height / 2.0) * ((enwh * 1.0) / max));
    }
    
    function updateBuffer() {
        var dc = buffer.getDc();

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();

        if (app.production == null || app.consumption == null) {
            return;
        }

        var center = height / 2;
        var i;
        var x = 0, line_height;
        var gross_production, net_production, gross_consumption, net_consumption;

        dc.setPenWidth(1);
        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, center, x + dc.getWidth(), center);
        
        for (i = 0; i < 96; i++) {
            gross_production = app.production[i];
            gross_consumption = app.consumption[i];
            net_production = 0;
            net_consumption = 0;
            
            if (gross_production != null && gross_consumption != null && gross_production >= gross_consumption) {
                net_production = gross_production - gross_consumption;
            }
            else if (gross_production != null && gross_consumption != null && gross_production < gross_consumption) {
                net_consumption = gross_consumption - gross_production;
            }
            else if (gross_production != null) {
                net_production = gross_production;
            }
            else if (gross_consumption != null) {
                net_consumption = gross_consumption;
            }
            
            if (gross_production) {
                dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(x, center - scaled_watts(gross_production), 5, scaled_watts(gross_production));
            }
            
            if (net_production) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(x, center - scaled_watts(net_production), 5, scaled_watts(net_production));
            }
            
            if (gross_consumption) {
                dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(x, center, 5, scaled_watts(gross_consumption));
            }
            
            if (net_consumption) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(x, center, 5, scaled_watts(net_consumption));
            }
            
            x = x + 6;
        }
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawBitmap(locX, locY, buffer);
    }
}
