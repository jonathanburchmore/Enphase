using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setPenWidth(1);
        
        dc.drawLine(0, 49, 240, 49);
        dc.drawLine(120, 0, 120, 49);
        
        dc.drawLine(0, 191, 240, 191);
    }
}
