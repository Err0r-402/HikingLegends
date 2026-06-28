using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.ActivityMonitor;

class HikingLegendsView extends WatchUi.View {

    var app;


    var stepsStart = 0;
    var stepsLastUpdate = 0;
    var currentSteps = 0;

    function initialize(app) {
        View.initialize();
        self.app = app;
        
        var info = ActivityMonitor.getInfo();
        
        if (info != null && info.steps != null) {
        currentSteps = info.steps;
        stepsStart = info.steps;
        }
        System.println(WatchUi has :IconMenuItem);
        
       
       
    }

   function onShow() {
        System.println("onShow triggered");
        
    
       WatchUi.requestUpdate();
       
    }

    

    function onUpdate(dc) {
        
        var info = ActivityMonitor.getInfo();
         currentSteps = 0;
        if (info != null && info.steps != null) {
        currentSteps = info.steps;
        }



        var stepsDelta = currentSteps - stepsStart;
        if (stepsDelta > stepsLastUpdate) {
            var newSteps = stepsDelta - stepsLastUpdate;
            app.addCurrency((newSteps * app.getCurrencyPerStep()).toLong());
            stepsLastUpdate = stepsDelta;
        }
        
        


        
        dc.clear();
        dc.drawScaledBitmap(0, 0, dc.getWidth(), dc.getHeight(), WatchUi.loadResource(Rez.Drawables.FRONT_PAGE));
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);

        drawNumberText(dc, 160, 160, abbreviateNumber(currentSteps), 75);
        drawNumberText(dc, 160, 205, "$" + abbreviateNumber(app.getCurrency()), 75);
        drawNumberText(dc, 230, 250, commaSeparate(app.getCurrencyPerStep())+"x", 75);

        WatchUi.requestUpdate();

    }

    function onKey(key) {
        if (key == WatchUi.KEY_START) {
            System.println("Start key pressed");
           WatchUi.pushView(new ShopMenu(app),null,WatchUi.SLIDE_LEFT);
        }
    }
}


class ShopMenu extends WatchUi.Menu2 {

    var app;

    function initialize(app) {
        Menu2.initialize({
        :title => "RANKS"
    });
        self.app = app;

        var upgrades = getUpgrades();
        for (var i = 0; i < upgrades.size(); i++) {
            var upgrade = upgrades[i];
            var id = upgrade.get(:id);

            addItem(new WatchUi.IconMenuItem(
                upgrade.get(:name),
                subLabelFor(id, upgrade),
                id,
                new WatchUi.Bitmap({:rezId => getMenuShopIcon(id)}),
                null
            ));
        }
    }

    // Refreshes each row's sub-label so it reflects the current
    // owned/equipped/price state whenever the menu becomes visible again.
    function onShow() {
        var upgrades = getUpgrades();
        for (var i = 0; i < upgrades.size(); i++) {
            var upgrade = upgrades[i];
            getItem(i).setSubLabel(subLabelFor(upgrade.get(:id), upgrade));
        }
        WatchUi.requestUpdate();
    }

    function subLabelFor(id, upgrade) {
        var equippedItem = app.getEquippedItem();
        if (equippedItem != null && equippedItem.equals(id)) {
            return "Equipped";
        } else if (app.isPurchased(id)) {
            return "Owned";
        }
        return "$" + abbreviateNumber(upgrade.get(:cost));
    }

}

class ShopView extends WatchUi.View {

    var app;

    function initialize(app) {
        View.initialize();
        self.app = app;
    }

    function onShow() {
        
    }

    function onUpdate(dc) {
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        dc.drawText(227, 20, Graphics.FONT_LARGE, "Shop",Graphics.TEXT_JUSTIFY_CENTER);
        var cost = 100 * app.getCurrencyPerStep();
        dc.drawText(227, 150, Graphics.FONT_SMALL, "Upgrade Cost: " + cost.toString(),Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(227, 200, Graphics.FONT_SMALL, "Your Currency: " + app.getCurrency().toString(),Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(227, 280, Graphics.FONT_TINY, "Press Start to Buy",Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(227, 330, Graphics.FONT_TINY, "Press Back to Exit",Graphics.TEXT_JUSTIFY_CENTER);
        
        WatchUi.requestUpdate();
    }

    function onKey(keyEvent) {
        if (keyEvent.getKey() == 4) {
            if (app.buyUpgrade()) {
                
                WatchUi.pushView(new SimpleMessageView(app, "Upgrade bought!", "You now get +1 currency per step."), null, WatchUi.SLIDE_RIGHT);

            } else {
                
                WatchUi.pushView(new SimpleMessageView(app, "Not enough currency", "Keep walking to earn more!"), null, WatchUi.SLIDE_RIGHT);
            }
        } else if (keyEvent.getKey() == 5) {
            WatchUi.switchToView(new HikingLegendsView(app),null,WatchUi.SLIDE_LEFT);
        }
        System.println("Key pressed in ShopView: " + keyEvent.getKey().toString());
    }
}




class SimpleMessageView extends WatchUi.View {
    var message;
    var subMessage;
    var app;

    function initialize(app, message, subMessage) {
        View.initialize();
        self.app = app;
        self.message = message;
        self.subMessage = subMessage;
    }

    function onUpdate(dc) {
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(227, 40, Graphics.FONT_MEDIUM, message, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(227, 180, Graphics.FONT_SMALL, subMessage, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(227, 330, Graphics.FONT_TINY, "Press back...", Graphics.TEXT_JUSTIFY_CENTER);
        WatchUi.requestUpdate();
    }

    function onKey(key) {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

// Full-screen purchase result splash (bought / already owned / insufficient funds).
// Dismissed by pressing any key.
class ShopResultView extends WatchUi.View {
    var app;
    var image;

    function initialize(app, rezId) {
        View.initialize();
        self.app = app;
        image = WatchUi.loadResource(rezId);
    }

    function onUpdate(dc) {
        dc.clear();
        dc.drawScaledBitmap(0, 0, 454, 454, image);
        WatchUi.requestUpdate();
    }

    function onKey(key) {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
