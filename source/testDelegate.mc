import Toybox.Lang;
import Toybox.WatchUi;

class testDelegate extends WatchUi.BehaviorDelegate {
    var app;
    function initialize(app) {
        BehaviorDelegate.initialize();
        self.app = app;
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        if (keyEvent.getKey() == 4) {
        WatchUi.pushView(new ShopMenu(self.app), new ShopMenuDelegate(self.app), WatchUi.SLIDE_LEFT);
        
        }
        else if (keyEvent.getKey() == 5) {
        Application.Storage.setValue("Money", app.getCurrency());
        Application.Storage.setValue("stepsStart", app.getSteps());
        Application.Storage.setValue("Multiplier", app.getCurrencyPerStep());
        app.exit();
    }
        
        return true;
    }

}