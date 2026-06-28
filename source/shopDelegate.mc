import Toybox.Lang;
import Toybox.WatchUi;

class shopDelegate extends WatchUi.BehaviorDelegate {
    var app;
    function initialize(app) {
        BehaviorDelegate.initialize();
        self.app = app;
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        if (keyEvent.getKey() == 4) {
        
            if (app.buyUpgrade()) {
                
                WatchUi.pushView(new SimpleMessageView(app, "Upgrade\nbought!", "You now get +1\ncurrency per step."), null, WatchUi.SLIDE_LEFT);
                Application.Storage.setValue("Money", app.getCurrency());
                Application.Storage.setValue("Multiplier", app.getCurrencyPerStep());

            } else {
                
                WatchUi.pushView(new SimpleMessageView(app, "Not enough\ncurrency!", "Keep walking to\nearn more!"), null, WatchUi.SLIDE_LEFT);
            }


        }

        else if (keyEvent.getKey() == 5) {
        WatchUi.pushView(new HikingLegendsView(self.app), new testDelegate(self.app), WatchUi.SLIDE_RIGHT);
        
        }
        
        return true;
    }

}