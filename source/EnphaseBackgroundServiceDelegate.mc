using Toybox.System;
using Toybox.Time;
using Toybox.Lang;
using Toybox.Background;
using Toybox.Communications;

(:background)
class EnphaseBackgroundServiceDelegate extends System.ServiceDelegate {
    var apikey;
    var userid;
    var systemid;
    
    var pass;
    
    var last_energy_at;
    
    var production;
    var max_production;
    var total_production;
    
    var consumption;
    var max_consumption;
    var total_consumption;
    
    function initialize(apikey, userid, systemid) {
        System.ServiceDelegate.initialize();
        
        self.apikey = apikey;
        self.userid = userid;
        self.systemid = systemid;
        
        production = new[96];
        max_production = 0;
        total_production = 0;
        
        consumption = new[96];
        max_consumption = 0;
        total_consumption = 0;
    }
    
    function onTemporalEvent() {
        System.println(Lang.format("Beginning update at: $1$", [Time.now().value()]));

        pass = 1;
        last_energy_at = Time.now().value() - 900;
        
        queryStats();
    }

    function queryStats() {
        var start_at = Time.today().value() + (12000 * (pass - 1));
        var end_at = Time.today().value() + (12000 * pass);
        
        if (end_at > last_energy_at) {
            end_at = null;
        }

        var url = Lang.format("https://api.enphaseenergy.com/api/v2/systems/$1$/stats", [systemid]);
        var params = {
            "key" => apikey,
            "user_id" => userid,
            "start_at" => start_at
        };
        if (end_at != null) {
            params.put("end_at", end_at);
        }
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var callback = method(:onReceiveStats);
        
        System.println(Lang.format("queryStats: params: $1$", [params]));
        
        Communications.makeWebRequest(url, params, options, callback);
    }
    
    function onReceiveStats(responseCode, data) {
        if (!processStats(responseCode, data)) {
            return;
        }
        
        if (Time.today().value() + (12000 * pass) >= last_energy_at)
        {
            pass = 1;
            queryConsumptionStats();
        }
        else
        {
            pass = pass + 1;
            queryStats();
        }
    }

    function processStats(responseCode, data) {
        System.println(Lang.format("processStats: responseCode: $1$", [responseCode]));
        
        if (responseCode != 200) {
            Background.exit({
                "success" => false
            });

            return false;
        }

        last_energy_at = data.get("meta").get("last_energy_at");

        var start = Time.today().value();
        var intervals = data.get("intervals");
        var size = intervals.size();
        var i, end, index, enwh;
        
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

        return true; 
    }

    function queryConsumptionStats() {
        var start_at = Time.today().value() + (43200 * (pass - 1));
        var end_at = Time.today().value() + (43200 * pass);
        
        if (end_at > last_energy_at) {
            end_at = null;
        }

        var url = Lang.format("https://api.enphaseenergy.com/api/v2/systems/$1$/consumption_stats", [systemid]);
        var params = {
            "key" => apikey,
            "user_id" => userid,
            "start_at" => start_at
        };
        if (end_at != null) {
            params.put("end_at", end_at);
        }
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var callback = method(:onReceiveConsumptionStats);
        
        System.println(Lang.format("queryConsumptionStats: params: $1$", [params]));

        Communications.makeWebRequest(url, params, options, callback);
    }
    
    function onReceiveConsumptionStats(responseCode, data) {
        if (!processConsumptionStats(responseCode, data)) {
            return;
        }
        
        if (Time.today().value() + (43200 * pass) >= last_energy_at)
        {
	        Background.exit( {
                "success" => true,
	           
	            "production" => production,
	            "max_production" => max_production,
	            "total_production" => total_production,
	            
	            "consumption" => consumption,
	            "max_consumption" => max_consumption,
	            "total_consumption" => total_consumption,
	            
	            "last_update" => Time.now().value(),
	        } );
        }
        else
        {
            pass = pass + 1;
            queryConsumptionStats();
        }
    }
    
    function processConsumptionStats(responseCode, data) {
        System.println(Lang.format("processConsumptionStats: responseCode: $1$", [responseCode]));
        
        if (responseCode != 200) {
            Background.exit({
                "success" => false
            });

            return false;
        }
        
        last_energy_at = data.get("meta").get("last_energy_at");
        
        var start = Time.today().value();
        var intervals = data.get("intervals");
        var size = intervals.size();
        var i, end, index, enwh;
        
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
        
        return true;
    }
}