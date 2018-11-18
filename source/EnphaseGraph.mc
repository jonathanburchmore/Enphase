using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.Lang;
using Toybox.Communications;

class EnphaseGraph extends WatchUi.Drawable {
    var start;
    var production;
    var consumption;
    var max_production;
    var max_consumption;
    var last_stats_update;
    var last_consumption_update;
        
    function initialize(dictionary) {
        dictionary.put(:identifier, "EnphaseGraph");
        Drawable.initialize(dictionary);
        
        start = Time.today().value();
        max_production = 0;
        max_consumption = 0;
        
        queryStats();
        queryConsumptionStats();
    }
    
    function queryStats() {
        if (last_stats_update && Time.now().subtract(last_stats_update).value() < 300) {
            return;
        }

        var url = Lang.format("https://api.enphaseenergy.com/api/v2/systems/$1$/stats", ["1320521"]);
        var params = {
            "key" => "8b2be74a07b3a29bb9b6e1af627646ea",
            "user_id" => "4d5441774f444d7a4d413d3d0a"
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var callback = method(:onReceiveStats);
        
        Communications.makeWebRequest(url, params, options, callback);
    }
    
    function onReceiveStats(responseCode, data) {
        last_stats_update = Time.now();

        if (responseCode != 200) {
            return;
        }
    
        production = new[96];
        max_production = 0;
        
        var intervals = data.get("intervals");
        var size = intervals.size();
        var i, end, index, enwh;
        var total_production = 0;
        
        for (i = 0; i < size; i++) {
            end = intervals[i].get("end_at");
            enwh = intervals[i].get("enwh");
            total_production = total_production + enwh;
            index = (end - start - 1) / 900;

            if (index >= 0 && index < 96) {
	            if (production[index] == null) {
	                production[index] = enwh;
	            }
	            else {
	                production[index] = production[index] + enwh;
	            }
	            
	            if (production[index] > max_production) {
	                max_production = production[index];
	            }
	        }
        }

        Application.getApp().receiveTotalProduction(total_production);
        requestUpdate();
    }

    function queryConsumptionStats() {
        if (last_consumption_update && Time.now().subtract(last_consumption_update).value() < 300) {
            return;
        }
        
        var url = Lang.format("https://api.enphaseenergy.com/api/v2/systems/$1$/consumption_stats", ["1320521"]);
        var params = {
            "key" => "8b2be74a07b3a29bb9b6e1af627646ea",
            "user_id" => "4d5441774f444d7a4d413d3d0a"
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var callback = method(:onReceiveConsumptionStats);
        
        Communications.makeWebRequest(url, params, options, callback);
    }
    
    function onReceiveConsumptionStats(responseCode, data) {
        last_consumption_update = Time.now();

        if (responseCode != 200) {
            return;
        }
        
        consumption = new[96];
        max_consumption = 0;
        
        var intervals = data.get("intervals");
        var size = intervals.size();
        var i, end, index, enwh;
        var total_consumption = 0;
        
        for (i = 0; i < size; i++) {
            end = intervals[i].get("end_at");
            enwh = intervals[i].get("enwh");
            total_consumption = total_consumption + enwh;
            index = (end - start - 1) / 900;
            
            if (index >= 0 && index < 96) {
	            if (consumption[index] == null) {
	                consumption[index] = enwh;
	            }
	            else {
	                consumption[index] = enwh;
	            }
	            
	            if (consumption[index] > max_consumption) {
	                max_consumption = consumption[index];
	            }
	        }
        }

        Application.getApp().receiveTotalConsumption(total_consumption);
        requestUpdate();
    }
    
    function scaled_watts(enwh) {
        var max = max_production;
        if (max_consumption > max) {
            max = max_consumption;
        }
        
        return Math.floor((height / 2.0) * ((enwh * 1.0) / max));
    }

    function draw(dc) {
        var i;
        var center = locY + (height / 2);
        var x = locX, line_height;
        var gross_production, net_production, gross_consumption, net_consumption;
        
        if (production == null || consumption == null) {
            return;
        }

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.setClip(locX, locY, 192, height);
        dc.clear();
        dc.clearClip();

        dc.setPenWidth(1);
        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, center, x + 192, center);
        
        for (i = 0; i < 96; i++) {
            gross_production = production[i];
            gross_consumption = consumption[i];
            net_production = 0;
            net_consumption = 0;
            
            if (gross_production && gross_consumption && gross_production >= gross_consumption) {
                net_production = gross_production - gross_consumption;
            }
            else if (gross_production && gross_consumption && gross_production < gross_consumption) {
                net_consumption = gross_consumption - gross_production;
            }
            else if (gross_production) {
                net_production = gross_production;
            }
            else if (gross_consumption) {
                net_consumption = gross_consumption;
            }
            
            if (gross_production) {
                dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, center, x, center - scaled_watts(gross_production));
            }
            
            if (net_production) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, center, x, center - scaled_watts(net_production));
            }
            
            if (gross_consumption) {
                dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, center, x, center + scaled_watts(gross_consumption));
            }
            
            if (net_consumption) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, center, x, center + scaled_watts(net_consumption));
            }
            
            x = x + 2;
        }
    }
}
